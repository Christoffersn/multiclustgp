function [Means, GPParameters, TerminationFlag] = GRADIENT_DESCENT_COORDINATE(Labels, ...
    Image, Means, GPParameters, Model, Algorithm, useCUDA)
%  Perform gradient descent to update means using coordinate descent
%
%   Labels              = Current labeling
%   Image               = Input data
%   Means               = Current means
%   Model               = Model parameters
%   Algorithm           = Algorithm parameters
%   currentLayerRun     = The current layer
%   useCUDA             = Whether to use GPU acceleration (Nvidia only)

FlatFeatures = Image.FlatFeatures;
ImageSize = size(FlatFeatures,1);

NumberOfLabelsPerLayer = Model.NumberOfLabelsPerLayer;
NumberOfLayers = Model.NumberOfLayers;

NumberOfCombinations = NumberOfLabelsPerLayer ^ NumberOfLayers;
FlatLabels = reshape(Labels, size(Labels,1)*size(Labels,2),1);

NumberOfDimensions = Image.NumberOfDimensions;
Frames = Image.Frames;


OldEnergy = OBSERVATION_POTENTIAL(FlatLabels, FlatFeatures, Frames, ImageSize, Means, NumberOfLabelsPerLayer, NumberOfLayers, useCUDA);
NewMeans = Means;
NewGPParameters = GPParameters;

TerminationFlag = 0;
xValues= linspace(1,Frames,Frames); %[1 2 3 ... frameCount]

PixelsInEachCluster = zeros(NumberOfLayers, NumberOfLabelsPerLayer);
rngLayerOrder = randperm(NumberOfLayers);

PixelSums = zeros(1,NumberOfDimensions,Frames,NumberOfCombinations);
for k = 1: NumberOfCombinations  
    A = FlatFeatures;
    A(FlatLabels(:)~=k,:,:) = 0;
    PixelSums(1,:,:,k) = sum(A, 1);
end

for l_=1:Model.NumberOfLayers
    RandomLayer = rngLayerOrder(l_);
    rngLabelOrder = randperm(NumberOfLabelsPerLayer);
    for c_=1:Model.NumberOfLabelsPerLayer
        RandomCluster = rngLabelOrder(c_);
        
        SumOfErrors = zeros(1,NumberOfDimensions,Frames,NumberOfCombinations);
        %For every combination of cluster indices, then compute the error
        %(features - means) for all pixels with the given mean combination
        for k = 1: NumberOfCombinations
            mlindex = SL_IND_TO_ML_IND(k, NumberOfLayers, NumberOfLabelsPerLayer); %contains a row vector of cluster indices in each layer
            pixelsInCombination = sum(FlatLabels(:)==k);

            %subtract each cluster mean in the combination from all the pixels
            for d = 1 : NumberOfDimensions
                MeansConvolution = zeros(1,1,Frames, 1);
                for l = 1 : NumberOfLayers
                    MeansConvolution = MeansConvolution + reshape(NewMeans(l,mlindex(1,l),d,:), [1 1 Frames, 1]);
                end
                SumOfErrors(1,d,:,k) = PixelSums(1,d,:,k) - (pixelsInCombination * MeansConvolution);
            end
            for l = 1 : NumberOfLayers
                PixelsInEachCluster(l, mlindex(1,l)) = PixelsInEachCluster(l, mlindex(1,l)) + pixelsInCombination;
            end
        end
        
        MeanErrorUpdate = zeros(NumberOfLayers, NumberOfLabelsPerLayer, NumberOfDimensions, Frames);
        
        for k = 1 : NumberOfCombinations
            mlindex = SL_IND_TO_ML_IND(k, NumberOfLayers, NumberOfLabelsPerLayer);
            
            %MeanErrorUpdate is the mean difference that is going to be applied
            %Every mean difference vector contains the sum of errors, summed over every
            %combination that mean is in
            for l=1 : NumberOfLayers
                for d = 1 : NumberOfDimensions
                    MeanErrorUpdate(l, mlindex(1,l),d,:) = MeanErrorUpdate(l, mlindex(1,l),d,:) + reshape(SumOfErrors(1,d,:,k), [1 1 1 Frames]);
                end
            end
        end
        
        for l = 1 : NumberOfLayers
            for c = 1 : NumberOfLabelsPerLayer
                pixelsUsingThisCluster = PixelsInEachCluster(l,c);
                
                if pixelsUsingThisCluster ~= 0
                    MeanErrorUpdate(l,c,:,:) = MeanErrorUpdate(l,c,:,:) / pixelsUsingThisCluster;
                end
            end
        end
        
        MeansWithError = NewMeans + MeanErrorUpdate;
        
       
        meantype = Algorithm.MeanType;
        %Now we want to fit each dimension for the current mean with the
        %other means locked
        if (strcmp(meantype, 'fixed-continues-piecewise'))
            knots = Algorithm.knots;
            degree = Algorithm.degree;
            slm = NewGPParameters.slm;
            parfor d=1:NumberOfDimensions
                dataVector = reshape(MeansWithError(RandomLayer,RandomCluster,d,:), [1 Frames]);
                slm(RandomLayer,RandomCluster,d) = ...
                    FIT_SLM_MEAN(xValues, dataVector, knots, degree);
            end
            NewGPParameters.slm(RandomLayer,RandomCluster,:) = ...
                slm(RandomLayer,RandomCluster,:);
        end
        if (strcmp(meantype, 'any-degree-poly'))
            cofficients = NewGPParameters.cofficients;
            polyDegree = NewGPParameters.polyDegree;
            parfor d=1:NumberOfDimensions
                dataVector = reshape(MeansWithError(RandomLayer,RandomCluster,d,:), [1 Frames]);
                cofficients(RandomLayer,RandomCluster,d,:) = ... 
                    FIT_POLYNOMIAL_MEAN(xValues, dataVector,polyDegree);
            end
            NewGPParameters.cofficients(RandomLayer,RandomCluster,:,:) =...
                cofficients(RandomLayer,RandomCluster,:,:);
        end
        if (strcmp(Algorithm.MeanType, 'free-discontinues-piecewise'))
           for d=1:NumberOfDimensions
               dataVector = reshape(MeansWithError(RandomLayer,RandomCluster,d,:), [1 Frames]); 
               NewGPParameters = FIT_DISC_PIECEWISE_LIN(dataVector, NewGPParameters,RandomLayer,RandomCluster,d );
           end  
        end
        
        NewMeans = CALC_MEANS(NewGPParameters, Image, Algorithm.MeanType);
        
    end
end

NewEnergy = OBSERVATION_POTENTIAL(FlatLabels, FlatFeatures, Frames, ImageSize, NewMeans, NumberOfLabelsPerLayer, NumberOfLayers, useCUDA);

if (OldEnergy >= NewEnergy)
    Means = NewMeans;
    GPParameters = NewGPParameters;
    if (OldEnergy - NewEnergy < 10000)
        display('termating not enough energy change');
        TerminationFlag = 1;
    end
else
    display('new energy higher - terminating');
    TerminationFlag = 1;
end

end
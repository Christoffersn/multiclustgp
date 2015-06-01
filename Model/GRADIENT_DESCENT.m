function [Means, GPParameters, TerminationFlag] = GRADIENT_DESCENT(Labels, ...
    Image, Means, GPParameters, Model, Algorithm, useCUDA)
%  Perform gradient descent to update means
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

PixelErrors = zeros(ImageSize, NumberOfDimensions, Frames, NumberOfCombinations);
PixelsInEachCluster = zeros(NumberOfLayers, NumberOfLabelsPerLayer);

%For every combination of cluster indices, then compute the error
%(features - means) for all pixels with the given mean combination
for k = 1: NumberOfCombinations
    mlindex = SL_IND_TO_ML_IND(k, NumberOfLayers, NumberOfLabelsPerLayer); %contains a row vector of cluster indices in each layer
    pixelsInCombination = sum(FlatLabels(:)==k);
    
    A = FlatFeatures;
    %subtract each cluster mean in the combination from all the pixels
    for d = 1 : NumberOfDimensions
        MeansConvolution = zeros(1,1,Frames);
        for l = 1 : NumberOfLayers
            MeansConvolution = MeansConvolution + reshape(Means(l,mlindex(1,l),d,:), [1 1 Frames]);
        end
        A(:,d,:) = bsxfun(@minus, A(:,d,:), MeansConvolution);
    end
    for l = 1 : NumberOfLayers
        PixelsInEachCluster(l, mlindex(1,l)) = PixelsInEachCluster(l, mlindex(1,l)) + pixelsInCombination;
    end
    PixelErrors(:,:,:,k) = A;
    PixelErrors(FlatLabels(:)~=k,:,:,k) = 0; %remove the pixels error values for pixels that are not labeled with that combination
end

%this is the sum of errors for every dimension for every combination (actually multiplied by -2)
SumOfErrors = sum(PixelErrors,1);

clear A;
clear PixelErrors;

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
        
        if MeanErrorUpdate(l,c,:,:) ~= 0
            MeanErrorUpdate(l,c,:,:) = MeanErrorUpdate(l,c,:,:) / pixelsUsingThisCluster;
        end
    end
end

OldEnergy = OBSERVATION_POTENTIAL(FlatLabels, FlatFeatures, Frames, ImageSize, Means, NumberOfLabelsPerLayer, NumberOfLayers, useCUDA);

StepSizeFactor = 1;
TerminationFlag = 0;
xValues= linspace(1,Frames,Frames); %[1 2 3 ... frameCount]
MeansWithError = Means + MeanErrorUpdate;

while (StepSizeFactor >= 1/4)
    ParametersConverged = 1;
    NewParameters.a = zeros(NumberOfLayers, NumberOfLabelsPerLayer, NumberOfDimensions);
    NewParameters.b = zeros(NumberOfLayers, NumberOfLabelsPerLayer, NumberOfDimensions);
    
    %Now we have the datapoints, we want to fit the model
    for l=1:Model.NumberOfLayers
        for c=1:Model.NumberOfLabelsPerLayer
            for d=1:NumberOfDimensions
                dataVector = reshape(MeansWithError(l,c,d,:), [1 Frames]);
                P = polyfit(xValues, dataVector, 1); %fit to first degree polynomial
                a = P(1,1);
                b = P(1,2);
                
                NewParameters.a(l,c,d) = GPParameters.a(l,c,d) + (Algorithm.GradientStepSize * (a - GPParameters.a(l,c,d)));
                NewParameters.b(l,c,d) = GPParameters.b(l,c,d) + (Algorithm.GradientStepSize * StepSizeFactor * (b - GPParameters.b(l,c,d)));
                
                if (abs(NewParameters.a(l,c,d) - GPParameters.a(l,c,d)) > 0.01 || abs(NewParameters.b(l,c,d) - GPParameters.b(l,c,d)) > 0.01)
                    ParametersConverged = 0;
                end
            end
        end
    end
    
    if (ParametersConverged == 1)
        TerminationFlag = 1;
        return;
    end
    
    NewMeans = CALC_MEANS(NewParameters,Image);
    NewEnergy = OBSERVATION_POTENTIAL(FlatLabels, FlatFeatures, Frames, ImageSize, NewMeans, NumberOfLabelsPerLayer, NumberOfLayers, useCUDA);
    
    if (OldEnergy > NewEnergy)
        Means = NewMeans;
        GPParameters.a = NewParameters.a;
        GPParameters.b = NewParameters.b;
        OldEnergy = NewEnergy;
        StepSizeFactor = StepSizeFactor * 2;
        if (StepSizeFactor == 1/4 && (OldEnergy - NewEnergy) < 10000)
            TerminationFlag = 1;
            return;
        end
    end
    
    if (OldEnergy <= NewEnergy)
        StepSizeFactor = StepSizeFactor / 2;
    end
end

return

%--------------Covariance function length-scale gradient descent----------------

%Assumes that these variables are already set
%CurrentEnergy = observation potential from above
%L already exists because it is saved between iterations
%lenght scale parameter for every feature in every cluster

frames = 300; % set properly
featuresPerFrame = 3; % set properly

covarianceMatrices = zeros(NumberOfLayers, NumberOfLabelsPerLayer, featuresPerFrame, frames, frames);

for layer = 1 : NumberOfLayers
    for label = 1 : NumberOfLabelsPerLayer
        for feature = 1 : featuresPerFrame
            for i = 1 : frames
                for j = 1 : frames
                    covarianceMatrices(layer,label,feature,i,j) = SquaredExponentialKernel(i,j,l);
                end
            end
        end
    end
end

%Compute cholesky decompositions of convoluted covariance matrices for
%small changes in length scale in two directions
L1 = zeros(NumberOfCombinations, featuresPerFrame, frames, frames);
L2 = zeros(NumberOfCombinations, featuresPerFrame, frames, frames);

%every change of length scale in a cluster changes multiple L for more than one combinations
for combination = 1 : NumberOfCombinations
    for feature = 1 : featuresPerFrame
        mlind = SL_IND_TO_ML_IND(k, NumberOfLayers, NumberOfLabelsPerLayer); 
        
        convolutedCovariance = zeros(featuresPerFrame, frames, frames); 
    end
end

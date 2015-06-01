function [Labels, GPParameters] = INITIALIZATION(NumberOfLabelsPerLayer, ...
    NumberOfLayers, Algorithm,Model, Image, InitializationMethod)
%  Initialization of labels and cluster means
%
%   NumberOfLabelsPerLayer  = Number of clusters in each segmentation
%   NumberOfLayers          = Number of segmentations
%   Image                   = Image struct
%   InitializationMethod    = 'random' or 'kmeans'
%
% Output:
%   Labels  = Initialized 2D labels
%   Means   = Initialized cluster means
rng('shuffle');
NumberOfDimensions = Image.NumberOfDimensions;

if isfield(Model, 'NeighbourWeightPerFrame')
    Model.NeighbourWeight = Model.NeighbourWeightPerFrame / Image.Frames;
end
D1 = Image.D1;
D2 = Image.D2;
NumberOfPixels = D1 * D2;
if (strcmp(Algorithm.MeanType, 'any-degree-poly'))
    GPParameters.polyDegree = Algorithm.polyDegree;
    GPParameters.cofficients = zeros(NumberOfLayers, NumberOfLabelsPerLayer, NumberOfDimensions,GPParameters.polyDegree+1);
end
if (strcmp(Algorithm.MeanType, 'fixed-continues-piecewise'))
    knots = Algorithm.knots;
    degree = Algorithm.degree;
end
if (strcmp(Algorithm.MeanType, 'free-discontinues-piecewise'))
    GPParameters.epsilon = Algorithm.epsilon;
end

%If it's the first run or we are not increasing layers just do
%random initilization of assignments
NumberOfCombinations = NumberOfLabelsPerLayer ^ NumberOfLayers;
IDX = randi(NumberOfCombinations, NumberOfPixels, 1);
Labels = reshape(IDX, D1, D2);



%Random initialization of the length scale paramter for the covariance
%function
for i=1 : NumberOfLayers
    GPParameters.l(i,:,:) = ((randi(10, NumberOfLabelsPerLayer, NumberOfDimensions))'...
        /NumberOfLayers)';
end

%Random-vectors simply computes random means
if (strcmpi(InitializationMethod, 'random-vectors'));
    for i=1 : NumberOfLayers
        GPParameters.cofficients(i,:,:,GPParameters.polyDegree+1) = ((randi(255, NumberOfLabelsPerLayer, NumberOfDimensions))'...
            /NumberOfLayers)';
    end
    %Random initialization of the remaining parameters for the mean function
    factor = 128/Image.Frames;
    for j = 0 : GPParameters.polyDegree-1
        for i=1 : NumberOfLayers
            GPParameters.cofficients(i,:,:,GPParameters.polyDegree-j) = (rand(NumberOfLabelsPerLayer, NumberOfDimensions)-0.5).*factor;
        end
    end
    %Random pixels select random pixels and use them for means
elseif ( strncmpi(InitializationMethod, 'temporal', 8))
    
    pixelsNeeded = NumberOfLabelsPerLayer;
    pixelsTaken = zeros(pixelsNeeded, NumberOfDimensions, Image.Frames);
    r = randperm(NumberOfPixels);
    pixelsTakenSoFar = 0;
    
    for i = 1 : NumberOfPixels
        row = ceil(r(i) / D2);
        column = mod(r(i)-1, D2) + 1;
        
        pixelvector = reshape(Image.Features(row,column,:,:), NumberOfDimensions, Image.Frames);
        
        pixelIsDifferent = true;
        
        for j = 1 : pixelsTakenSoFar
            if (all(pixelvector == reshape(pixelsTaken(j,:,:), NumberOfDimensions, Image.Frames), 2))
                pixelIsDifferent = false;
            end
        end
        
        if (pixelIsDifferent)
            pixelsTaken(pixelsTakenSoFar + 1, :, :) = pixelvector;
            pixelsTakenSoFar = pixelsTakenSoFar + 1;
            if pixelsTakenSoFar == pixelsNeeded
                break;
            end
        end
    end
    
    
    if (pixelsTakenSoFar < pixelsNeeded)
        for i=1 : NumberOfLayers
            GPParameters.cofficients(i,:,:,GPParameters.polyDegree+1) = ((randi(255, NumberOfLabelsPerLayer, NumberOfDimensions))' /NumberOfLayers)';
        end
        %Random initialization of the remaining parameters for the mean function
        factor = 128/Image.Frames;
        for j = 0 : GPParameters.polyDegree-1
            for i=1 : NumberOfLayers
                GPParameters.cofficients(i,:,:,GPParameters.polyDegree-j) = (rand(NumberOfLabelsPerLayer, NumberOfDimensions)-0.5).*factor;
            end
        end
    else
        
        ratioNumbers = ones(1,NumberOfLayers)/NumberOfLayers;
        for i = 1 : NumberOfLabelsPerLayer
            if (strcmpi(InitializationMethod, 'temporal-weighted'))
                % Get a random ratio/weight for each layer
                for j=1 : NumberOfLayers
                    ratioNumbers(j) = rand();
                end
                
                ratioNumbers(NumberOfLayers) = 1.0;
                ratioNumbers = sort(ratioNumbers);
                prev = 0;
                for j=1 : NumberOfLayers
                    ratioNumbers(j) = ratioNumbers(j)-prev;
                    prev = ratioNumbers(j)+prev;
                end
            end
            
            for j = 1 : NumberOfLayers
                xValues = linspace(1, Image.Frames, Image.Frames);
                if (strcmp(Algorithm.MeanType, 'any-degree-poly'))
                    for k = 1 : size(pixelsTaken,2)
                        dataVector = reshape(pixelsTaken(i, k, :), [1 Image.Frames]);
                        GPParameters.cofficients(j,i,k,:) = polyfit(xValues,dataVector,GPParameters.polyDegree); %fit to polynomialGPParameters.cofficients
                        GPParameters.cofficients(j,i,k,:) = GPParameters.cofficients(j,i,k,:).*ratioNumbers(j);
                    end
                end
                if (strcmp(Algorithm.MeanType, 'fixed-continues-piecewise'))
                    for k = 1 : size(pixelsTaken,2)
                        n = Image.Frames;
                        x2 = linspace(1,n,n)';
                        y2 = reshape(pixelsTaken(i, k, :), [1 Image.Frames]);
                        slm = slmengine(x2,y2,'degree',degree,'interiorknots','free', 'knots', knots);
                        slm.coef = slm.coef * ratioNumbers(j);
                        GPParameters.slm(j,i,k) = slm;
                    end
                end
                if (strcmp(Algorithm.MeanType, 'free-discontinues-piecewise'))
                    for k = 1 : size(pixelsTaken,2)
                        dataVector = reshape(pixelsTaken(i, k, :), [1 Image.Frames]);
                        p = polyfit(xValues,dataVector,1);
                        p = p * ratioNumbers(j);
                        GPParameters.x1(j,i,k,1) = 1;
                        GPParameters.x2(j,i,k,1) = Image.Frames;
                        GPParameters.a(j,i,k,1) = p(1);
                        GPParameters.b(j,i,k,1) = p(2);
                    end
                end
            end
        end      
    end  
else
    disp(strcat('ERROR - Unknown initialization: ', initializationMethod));
end

end


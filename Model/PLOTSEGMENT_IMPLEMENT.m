function PLOTSEGMENT_IMPLEMENT(Labels, NumberOfLayers,NumberOfLabelsPerLayer, currentEMStep, Means, Output, Description, currentRun, Energy)
% Obtains observation potential for a solution
%
% FlatLabels                = Current labelings
% FlatFeatures              = Feature vector
% Size                      = Total count of the input data
% Means                     = The current means
% NumberOfLabelsPerLayer    = Number of labels for the solution
% NumberOfLayers            = Number of layers for the solution
% useCUDA                   = Whether to use CUDA for gpu acceleration (only nvidia hw)

if (Output.FLAG_PLOT_MEANS)
    NumberOfVisualisations = 1 + size(Means, 1);
else
    NumberOfVisualisations = 1;
end

X_LayersPNG3 = ones(size(Labels,1), size(Labels,2), 3, NumberOfVisualisations);

SIZE = size(Labels,1) * size(Labels,2);
D1 = size(Labels,1) ;
global Path_Output;

IndexMatrix = zeros(NumberOfLabelsPerLayer^NumberOfLayers, NumberOfLayers);
count = 0;
% We are simulating X nested loops of size Y where X = NumberOfLayers and
% Y = NumberOfLabelsPerLayer
loopSize = NumberOfLabelsPerLayer^NumberOfLayers;
for i=1 : loopSize
    count = count +1;
    for j=1 : NumberOfLayers
       IndexMatrix(count,j) = mod(floor((i-1)/(NumberOfLabelsPerLayer^(j-1))), NumberOfLabelsPerLayer)+1;
    end
end

%Visualisation of means
normalisedMeans = [];
for i = 1 : NumberOfLayers
maxMean = max(max(Means(:,:,i)));
minMean = min(min(Means(:,:,i)));
normalisedMeans = cat(3, normalisedMeans, arrayfun(@(mean) ((mean - minMean) / (maxMean - minMean)) * 255.0, Means(:,:,i)));
end

for ind = 1 : SIZE
    [i, j ] = ind2ij(ind,D1);
    label = Labels(i,j,:);
    for k=1 : NumberOfLayers
        X_LayersPNG3(i,j,:,k,1) = IndexMatrix(label,k)*30*ones(3,1);
    end
    
    for v = 2 : NumberOfVisualisations
        for k=1 : NumberOfLayers
            cluster = mod(IndexMatrix(label,k) - 1, NumberOfLabelsPerLayer) + 1;
            meanValue = normalisedMeans(v-1, cluster, k);
            for rbg = 1:3
                X_LayersPNG3(i,j,rbg,k,v) = meanValue;
            end
        end
    end
end

% Plot images
if (Output.FLAG_PLOT_ALL_ITERATIONS == 1)
    imagePath = strcat(Path_Output, '/', Description, sprintf('-E%d-Run%d-EM%d.png', Energy, currentRun, currentEMStep));
else
    imagePath = strcat(Path_Output, '/', Description, sprintf('-E%d-Run%d.png', Energy, currentRun));
end

%Concatenate mean visualisations
bigimage = [];
for k=1 : NumberOfLayers
    bigimagerow = [];
    for v = 1 : NumberOfVisualisations
        bigimagerow = cat(2,bigimagerow,uint8(X_LayersPNG3(:,:,:,k,v)));
    end
    bigimage = cat(1,bigimage,bigimagerow);
end

imwrite(bigimage,imagePath);

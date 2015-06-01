function [ObservationPotential] = OBSERVATION_POTENTIAL(FlatLabels, FlatFeatures, Frames, Size, Means,  NumberOfLabelsPerLayer, NumberOfLayers, useCUDA)
% Obtains observation potential for a solution
%
% FlatLabels                = Current labelings
% FlatFeatures              = Feature vector
% Size                      = Total count of the input data
% Means                     = The current means
% NumberOfLabelsPerLayer    = Number of labels for the solution
% NumberOfLayers            = Number of layers for the solution
% useCUDA                   = Whether to use CUDA for gpu acceleration (only nvidia hw)

NumberOfCombinations = NumberOfLabelsPerLayer  ^ NumberOfLayers;
dataCosts = zeros(Size, NumberOfCombinations);

parfor k = 1: NumberOfCombinations
    curFlatLabels = FlatLabels;
    curFlatFeatures = FlatFeatures;
    curMeans = Means;
    dataCost = zeros(Size,1);
    
    MLidx = SL_IND_TO_ML_IND(k, NumberOfLayers, NumberOfLabelsPerLayer);

    for framenumber = 1:Frames

        A = curFlatFeatures(:,:,framenumber);

        for i = 1 : NumberOfLayers
            A = bsxfun(@minus, A, reshape(curMeans(i,MLidx(i), :,framenumber),[1 size(A,2)]) );
        end

        A = sum(abs(A).^2,2);

        dataCost  = dataCost(:) + A;

    end

    dataCost(curFlatLabels(:)~=k) = 0;
    dataCosts(:,k) = dataCost;
end

ObservationPotential = sum(sum(dataCosts, 1),2);

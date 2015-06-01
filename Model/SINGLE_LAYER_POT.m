function [DM] = SINGLE_LAYER_POT(NumberOfLayers, NumberOfLabelsPerLayer)
% Computes the pots model for a single layer markov field
%
% NumberOfLabelsPerLayer    = Number of labels for the solution
% NumberOfLayers            = Number of layers for the solution

NumberOfCombinations = NumberOfLabelsPerLayer ^ NumberOfLayers;


DM = zeros(NumberOfCombinations, NumberOfCombinations);

for i = 1 : NumberOfCombinations
    
    index1 = SL_IND_TO_ML_IND(i, NumberOfLayers, NumberOfLabelsPerLayer);
    
    for j = 1: NumberOfCombinations
        
        index2 = SL_IND_TO_ML_IND(j, NumberOfLayers, NumberOfLabelsPerLayer);
        
        D =  bsxfun(@ne, index1, index2);
        P = sum(D,2);
        
        DM(i, j) = P;
    end
end
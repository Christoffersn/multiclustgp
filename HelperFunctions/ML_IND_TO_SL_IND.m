function[x] = ML_IND_TO_SL_IND(index, NumberOfLayers, NumberOfLabelsPerLayer)
%  Converts multilayer index to singlelayer index
%
% index                     = The multilayer index to convert
% NumberOfLayers            = The number of layers in the model
% NumberOfLabelsPerLayer    = The number of labels in each layer

x = 0;
for i=1 : NumberOfLayers
    x = x + NumberOfLabelsPerLayer^(i-1) * index(NumberOfLayers - (i-1));
end

% For Number of Layers = 3, Number of labels = 2 then
%
% 1 1 1 = 1
% 1 1 2 = 2
% 1 2 1 = 3
% 1 2 2 = 4
% 2 1 1 = 5
% 2 1 2 = 6   
% 2 2 1 = 7
% 2 2 2 = 8
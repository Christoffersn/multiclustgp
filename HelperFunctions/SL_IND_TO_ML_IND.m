function [IND]  = SL_IND_TO_ML_IND(index, NumberOfLayers, NumberOfLabelsPerLayer)
%  Converts singlelayer index to multilayerlayer index
% 
% index                     = The singlelayer index to convert
% NumberOfLayers            = The number of layers in the model
% NumberOfLabelsPerLayer    = The number of labels in each layer

IND = zeros(1,NumberOfLayers);
%Extract the index components from the single number
for i=1 : NumberOfLayers
   IND(1,i) = mod(floor((index-1)/(NumberOfLabelsPerLayer^(i-1))), NumberOfLabelsPerLayer)+1;
end
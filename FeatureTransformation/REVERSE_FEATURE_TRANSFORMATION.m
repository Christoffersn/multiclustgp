function transformedMeans = REVERSE_FEATURE_TRANSFORMATION(Means, Components, NumberOfLabelsPerLayer, NumberOfLayers)
% Reverses feature transformation back from space used for PCA
%
% Means                    = Means of the solution
% Components               = principal components
% NumberOfLabelsPerLayer   = Number of labels in the model
% NumberOfLayers           = Number of layers in the model

    for i = 1:NumberOfLabelsPerLayer
        for j = 1:NumberOfLayers
            transformedMeans(:,i,j) = Components * Means(:,i,j);
        end
    end
end
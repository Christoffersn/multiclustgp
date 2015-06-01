function [transformedFeatures, components] = FEATURE_TRANSFORMATION(features, Algorithm)
% Transforms features into a space used for PCA
%
% features                  = The features to transform
% Algorithm                 = Struct of algorithm parameter

    flatFeatures = double(reshape(features, size(features, 1) * size(features, 2), size(features, 3)));
    [COEFF, ~, ~, ~, EXPLAINED] = pca(flatFeatures,'Algorithm','svd','Economy',false);
    varianceCoverage = 0;
    componentsNeeded = 0;
    while (varianceCoverage < Algorithm.pctVarianceCovered)
        componentsNeeded = componentsNeeded + 1;
        varianceCoverage = varianceCoverage + EXPLAINED(componentsNeeded);
    end
    components = COEFF(:,1:componentsNeeded);
    dimensions = sprintf(' %d', size(features, 3));
    reducedDimensions = sprintf(' %d', componentsNeeded);
    disp(strcat('Feature dimensionality was reduced from ',dimensions, ' to ', reducedDimensions));
    transformedFeatures = flatFeatures * components;
    transformedFeatures = reshape(transformedFeatures, size(features, 1), size(features, 2), size(transformedFeatures, 2));

end


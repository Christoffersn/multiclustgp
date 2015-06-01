function matrix = NORMALIZE_FEATURES(A)
% Normalizes the matrix 
%
% Performs min-max normalization
% Uses the global min and max of all values in the matrix
% 
% A     = Matrix to normalize

maxVal = max(A(:));
minVal = min(A(:));
matrix = arrayfun(@(x)NORMALIZE_FEATURES_HELPER(x,minVal,maxVal),A);

end

function new = NORMALIZE_FEATURES_HELPER(element, min, max)
    if (max-min) > 0
        new = ((element-min)/(max-min))*255;
    else
        new = 0;
    end
end


function matrix = NORMALIZE_FEATURES_PER(A)
% Normalizes the matrix per feature (paralellized)
%
% Performs min-max normalization
% Uses the feature-local min and max of all values in the matrix
% 
% A     = Matrix to normalize

distcomp.feature( 'LocalUseMpiexec', false );
%Assuming frames,rows,columns,feature
matrix = zeros(size(A,1),size(A,2),size(A,3), size(A,4));
parfor i=1 : size(A,4)
    mat = A(:,:,:,i);
    mx = max(mat(:));
    mn = min(mat(:));
    mat = arrayfun(@(x)NORMALIZE_FEATURES_HELPER(x,mn,mx),mat);
    matrix(:,:,:,i) = mat;
end

end

function new = NORMALIZE_FEATURES_HELPER(element, min, max)
    new = (element-min)/(max-min);
end
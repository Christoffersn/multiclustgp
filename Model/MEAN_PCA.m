function [ princomps, eigs ] = MEAN_PCA( means )
% Obtains principal components and eigenvalues of means using PCA

    eigs = zeros(size(means,1),size(means,3));
    princomps = zeros(size(means,1),size(means,3));
    for segmentation = 1:size(means,3)
        [COEFF, SCORES, EIG] = pca(means(:,:,segmentation)','Algorithm','svd','Economy',false);
        princomps(:,segmentation) = abs(COEFF(:,1));
        eigs(:,segmentation) = EIG;
    end

end


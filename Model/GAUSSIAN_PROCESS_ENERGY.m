% L is the cholesky decomposition of the convoluted covariance matrix for
% every label combination. Size is featuresPerFrame * frames * frames

% data is assumed to be zero meaned. Size featuresPerFrame * frames

function totalEnergy = GAUSSIAN_PROCESS_ENERGY(data, L)

totalEnergy = 0;

featuresPerFrame = size(data, 1);

for v = 1 : featuresPerFrame
    y = data(v,:);
    alpha = L(:,:,v)' \ (L(:,:,v) \ y);
    
    dataTerm = 0.5 * y' * alpha;
    
    complexityTerm = 0;
    for i = 1 : size(L,1)
        complexityTerm = complexityTerm + log(L(i,i,v));
    end
    
    totalEnergy = totalEnergy + dataTerm + complexityTerm;
end

end
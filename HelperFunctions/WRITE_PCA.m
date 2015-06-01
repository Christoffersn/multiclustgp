function [ ] = WRITE_PCA( GPParameters, featurenames, energy, writeVariance, description)
% Writes PCA coeffiecients to disk
%
% This function calculates the coefficients of the first principal
% component, where the means are the variables and each cluster
% is a sample. The higher the coefficient, the more influence that
% particular feature has on that segmentation.
%
% Means                     = The means for which calculate PCA
% featurenames              = List of names of the features for reference
% energy                    = energy of the solution, used for filename for easy lookup
% writeVariance             = Whether to write the variance of PCA
% description               = A description of the current solution    

    global Path_Root;

    gpCofficients = zeros(GPParameters.polyDegree+1);
    for i = 1 : GPParameters.polyDegree+1
        gpCofficients(i) = permute(GPParameters.a, [3,2,1]);
        gpCofficients(i) = gpCofficients(i)./max(abs(gpCofficients(i)(:)));    
    end
    means = gpCofficients;
    
    %Means should be a Matrix in the form (feature,label,layer)
    [scores, variance] = MEAN_PCA(means);

    
    if(writeVariance == true)
        dlmwrite(strcat(Path_Root, '/ImagesW/PCAvariance/var',...
        num2str(energy),'.csv'),variance,';');
    end

    rankedFeatures = {};
   % for i =1 : size(scores,2)
   %     score = num2cell(scores(:,i));
   %     score = [featurenames, score];
   %     for j =1:size(GPParameters.a,2)
   %         ab = cat(1,squeeze(GPParameters.a(i,j,:)) , squeeze(GPParameters.b(i,j,:)));
   %         
   %         score = [score, num2cell(ab)];
   %     end
   %     score =  sortrows(score,-2);
   %     rankedFeatures = [rankedFeatures,score];
   % end
    
    
   % cell2csv(strcat(Path_Root, '/ImagesW/featurescores/scores',...
   %    '-', description, '-', num2str(energy),'.csv'),rankedFeatures,';');


end


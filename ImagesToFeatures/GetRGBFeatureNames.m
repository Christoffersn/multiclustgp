function featureNames = GetRGBFeatureNames(RGB)
% Returns a vector of featurenames for RGB features (per frame)
%
% RGB   = Matrix of size imgWidth*imgHeight*(frameCount*3) with RGB values

featureNames = {};

for i = 1:(size(RGB,3)/3)
    featureName = {strcat('red',num2str(i)); strcat('green',num2str(i)); strcat('blue',num2str(i))};
    featureNames = cat(1,featureNames, featureName);
end
    
end


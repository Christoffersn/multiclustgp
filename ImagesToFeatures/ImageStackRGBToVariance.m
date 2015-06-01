function [Variance, VarianceFeatureNames] = ImageStackRGBToVariance(RGB)
% Returns a vector of featurenames for RGB features (per frame)
%
% RGB   = Matrix of size imgWidth*imgHeight*(frameCount*3) with RGB values

D1 = size(RGB, 1);
D2 = size(RGB, 2);
Variance = zeros(D1, D2, 3);

for i = 1:D1
    for j = 1:D2
       red = RGB(i, j, 1:3:end);
       green = RGB(i, j, 2:3:end);
       blue = RGB(i, j, 3:3:end);
       
       %Write variance into the first three indexes and then cut of the
       %rest at the end
       Variance(i, j, 1) = std(red);
       Variance(i, j, 2) = std(green);
       Variance(i, j, 3) = std(blue);
    end
end

max_variance = max(max(max(Variance)));
Variance = Variance./ max_variance;
Variance = Variance.* 255;
Variance = round(Variance);

VarianceFeatureNames = {'ImageVarianceRed';'ImageVarianceGreen';'ImageVarianceBlue'};

end


function [RGBMeans, RGBFeatureNames] = ImageStackRGBToRGBMean(RGB)
% Averages RGB values over frames and returns the mean RGB for each pixel
%
% RGB   = Matrix of size imgWidth*imgHeight*(frameCount*3) with RGB values

RGBMeans = zeros(size(RGB,1),size(RGB,2),3);

RGBMeans(:, :, 1) = mean(RGB(:, :, 1:3:end),3);
RGBMeans(:, :, 2) = mean(RGB(:, :, 2:3:end),3);
RGBMeans(:, :, 3) = mean(RGB(:, :, 3:3:end),3);


RGBMeans = round(RGBMeans);
RGBFeatureNames = {'RGBMeanRed'; 'RGBMeanGreen'; 'RGBMeanBlue'};
end


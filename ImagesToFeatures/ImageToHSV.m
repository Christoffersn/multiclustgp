function HSV = ImageToHSV(imagePath)
% Converts an image to Hue Saturation Value format
%
% imagePath     = Path to the image

global Path_Input;

%reading png / rgb image
RGB = imread(strcat(Path_Input, imagePath));
HSV = double(rgb2hsv(RGB))*255;


end
function RGB = ImageToRGB(imagePath)
% Reads an image into an RGB matrix

global Path_Input;

%reading png / rgb image
RGB = imread(strcat(Path_Input, imagePath));
RGB = double(RGB);

end
function RGB = TIFImageStackToRGB(imagePath, startIndex, endIndex, numberlength)
global Path_Input;

%Initializing I with correct size
formatstring = strcat('%0',int2str(numberlength),'d');
img = imread(strcat(Path_Input, imagePath , num2str(startIndex, formatstring), '.tif'), 'tif');
img(:,:,4) = [];
RGB = zeros(size(img,1), size(img,2), (endIndex-startIndex+1)*3); % pixel dimensions , number of images
j = 1;

%reading image stack
for i = startIndex : endIndex
        img = imread(strcat(Path_Input, imagePath, num2str(i, formatstring), '.tif'), 'tif');
        img(:,:,4) = [];
        RGB(:,:,j:j+2) = img;
        j = j+3;
end

RGB = double(RGB);
end

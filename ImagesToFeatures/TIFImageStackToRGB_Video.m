function RGB = TIFImageStackToRGB_Video(imagePath, startIndex, skip, endIndex, numberlength)
global Path_Input;

%Initializing I with correct size
formatstring = strcat('%0',int2str(numberlength),'d');
img = imread(strcat(Path_Input, imagePath , num2str(startIndex, formatstring), '.tif'), 'tif');
img(:,:,4) = [];
RGB = zeros(size(img,1), size(img,2), 3,(endIndex-startIndex+1) / skip); % pixel dimensions , number of images

%reading image stack
frame = 1;
for i = startIndex : skip : endIndex
        img = imread(strcat(Path_Input, imagePath, num2str(i, formatstring), '.tif'), 'tif');
        img(:,:,4) = [];
        RGB(:,:,:,frame) = img;
        frame = frame + 1;
end

RGB = double(RGB);
end

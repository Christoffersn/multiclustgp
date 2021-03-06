function RGB = PNGImageStackToRGB(imagePath, startIndex, endIndex, numberlength)
% Obtains RGB features for an imagestack for png files
%
% imagePath     = Directory of the imagestack/frames
% startIndex    = The starting frame index to use
% endIndex      = The ending frame index to use
% numberlength  = The number of digits in image names e.g. for myimage0001.png we have 4

global Path_Input;
formatstring = strcat('%0',int2str(numberlength),'d');
%Initializing I with correct size
[O, map] = imread(strcat(Path_Input, imagePath , num2str(startIndex, formatstring), '.png'), 'png', 'Back', 'none');
if (size(O,3) == 3)
    img = O;
else
    img = ind2rgb(O, map);
end
RGB = zeros(size(img,1), size(img,2), (endIndex-startIndex+1)*3); % pixel dimensions , number of images
j = 1;

%reading image stack
for i = startIndex : endIndex
        [O, map] = imread(strcat(Path_Input, imagePath, num2str(i, formatstring), '.png'), 'png', 'Back', 'none');
        if (size(O,3) == 3)
            img = O;
            img = double(img);
            img = img./ 255;
        else
            img = ind2rgb(O, map);
        end
        RGB(:,:,j:j+2) = img;
        j = j+3;
end
RGB = RGB.* 255;
RGB = round(RGB);

RGB= double(RGB);
end
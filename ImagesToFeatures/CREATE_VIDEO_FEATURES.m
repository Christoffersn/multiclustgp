function Image = CREATE_VIDEO_FEATURES(files, startIndex, skip, endIndex, digitCount, filetype, varargin)

useRGB = false;
useSift = false;
useSFTA = false;
vectorLength = 0;

nVarargs = length(varargin);
for i = 1:nVarargs
    if strcmp(varargin{i}, 'rgb')
        useRGB = true;
    end
    if strcmp(varargin{i}, 'sift')
        useSift = true;
    end
    if strcmp(varargin{i}, 'sfta')
        useSFTA = true;
    end
end

featureVector = false;
featureNames = false;
RGB = false;

if useRGB
    display('Generating RGB features.');
    RGB = GetRGBIfNotYetRetrieved(RGB, files, startIndex, skip, endIndex, digitCount, filetype);
    if featureVector == false
        featureNames = {'reda';'greena';'bluea';'redb';'greenb';'blueb'};
        featureVector = RGB;
    else
        locfeatureVector = RGB;
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames,  {'red';'green';'blue'});
    end    
end
if useSift
    display('Generating SIFT features.');
    if featureVector == false
        [featureVector, featureNames] = ImageStackToSIFT_Video(files, startIndex,skip, endIndex, digitCount, filetype, false);
    else
        [locfeatureVector, locfeatureNames] = ImageStackToSIFT_Video(files, startIndex,skip, endIndex,digitCount, filetype, false);
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end
end
if useSFTA
    display('Generating SFTA Texture features.');
    if featureVector == false
        [featureVector, featureNames] = ImageStackToSFTA_Video(files, startIndex,skip, endIndex, digitCount, filetype);
    else
        [locfeatureVector, locfeatureNames] = ImageStackToSFTA_Video(files, startIndex,skip, endIndex,digitCount, filetype);
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end
end

display('Done creating features.');

Image.Features = featureVector;
Image.FeatureNames = featureNames;

end

function RGB = GetRGBIfNotYetRetrieved(currentRGB, files, startIndex, skip, endIndex, digitCount, filetype)
    if currentRGB == false
        if filetype == 'tif'
            RGB = TIFImageStackToRGB_Video(files, startIndex, skip, endIndex,digitCount);
        else
            RGB = PNGImageStackToRGB_Video(files, startIndex, skip, endIndex,digitCount);
        end
    else
       RGB = currentRGB; 
    end
end

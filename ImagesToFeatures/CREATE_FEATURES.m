function Image = CREATE_FEATURES(files, startIndex, endIndex, digitCount, filetype, varargin)

useSiftBins = false;
useMeanSift = false;
useTrajectories = false;
useMeanRGB = false;
useVariance = false;
useSFTA = false;
useRGB = false;

vectorLength = 0;

nVarargs = length(varargin);
for i = 1:nVarargs
    if strcmp(varargin{i}, 'siftbins')
        useSiftBins = true;
    end
    if strcmp(varargin{i}, 'meansift')
        useMeanSift = true;
    end
    if strcmp(varargin{i}, 'trajectories')
        useTrajectories = true;
    end
    if strcmp(varargin{i}, 'meanrgb')
        useMeanRGB = true;
    end
    if strcmp(varargin{i}, 'variance')
        useVariance = true;
    end
    if strcmp(varargin{i}, 'sfta')
        useSFTA = true;
    end
    if strcmp(varargin{i}, 'rgb')
        useRGB = true;
    end
end

featureVector = false;
featureNames = false;
RGB = false;
if useSiftBins
    display('Generating SIFT bin features.');
    if featureVector == false
        [featureVector, featureNames] = ImageStackToSIFTBins(files, startIndex, endIndex, digitCount, filetype, true, false);
    else
        [locfeatureVector, locfeatureNames] = ImageStackToSIFTBins(files, startIndex, endIndex,digitCount, filetype, true, false);
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end
end
if useMeanSift
    display('Generating mean SIFT vector features');
    if featureVector == false
        [featureVector, featureNames] = ImageStackToSIFT(files, startIndex, endIndex, digitCount, filetype, false);
    else
        [locfeatureVector, locfeatureNames] = ImageStackToSIFT(files, startIndex, endIndex,digitCount, filetype, false);
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end
end
if useMeanRGB
    display('Generating RGB mean features.');
    RGB = GetRGBIfNotYetRetrieved(RGB, files, startIndex, endIndex, digitCount, filetype);
    if featureVector == false
        [featureVector, featureNames] = ImageStackRGBToRGBMean(RGB);
    else
        [locfeatureVector, locfeatureNames] = ImageStackRGBToRGBMean(RGB);
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end
end
if useVariance
    display('Generating Variance features.');
    RGB = GetRGBIfNotYetRetrieved(RGB, files, startIndex, endIndex, digitCount, filetype);
    if featureVector == false
        [featureVector, featureNames] = ImageStackRGBToVariance(RGB);
    else
        [locfeatureVector, locfeatureNames] =  ImageStackRGBToVariance(RGB);
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end    
end
if useTrajectories
    display('Generating Trajectory features.');
    RGB = GetRGBIfNotYetRetrieved(RGB, files, startIndex, endIndex, digitCount, filetype);
    if featureVector == false
        [totalvector, tenvectors, trajeclengths, featureNames] = ImageStackRGBToTrajectory(RGB);
        featureVector = cat(3,totalvector,tenvectors,trajeclengths);
    else
        [totalvector, tenvectors, trajeclengths, locfeatureNames] = ImageStackRGBToTrajectory(RGB);
        locfeatureVector = cat(3,totalvector,tenvectors,trajeclengths);
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end    
end
if useSFTA
    display('Generating SFTA Texture features.');
    if featureVector == false
        [featureVector, featureNames] = ImageStackToSFTA(files, startIndex, endIndex, digitCount, filetype);
    else
        [locfeatureVector, locfeatureNames] = ImageStackToSFTA(files, startIndex, endIndex,digitCount, filetype);
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end
end
if useRGB
    display('Generating RGB features.');
    RGB = GetRGBIfNotYetRetrieved(RGB, files, startIndex, endIndex, digitCount, filetype);
    if featureVector == false
        featureNames = GetRGBFeatureNames(RGB);
        featureVector = RGB;
    else
        locfeatureNames = GetRGBFeatureNames(RGB);
        locfeatureVector = RGB;
        featureVector = cat(3,featureVector, locfeatureVector);
        featureNames = cat(1,featureNames, locfeatureNames);
    end    
end

display('Done creating features.');

Image.Features = featureVector;
Image.FeatureNames = featureNames;

end

function RGB = GetRGBIfNotYetRetrieved(currentRGB, files, startIndex, endIndex, digitCount, filetype)
    if currentRGB == false
        if filetype == 'tif'
            RGB = TIFImageStackToRGB(files, startIndex, endIndex,digitCount);
        else
            RGB = PNGImageStackToRGB(files, startIndex, endIndex,digitCount);
        end
    else
       RGB = currentRGB; 
    end
end

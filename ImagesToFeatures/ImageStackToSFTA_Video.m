function [features, STFAFeatureNames] = ImageStackToSFTA(imagePath, startIndex,skip, endIndex, numberlength, fileFormat)
% Calculates SFTA texture features for an imagestack
%
% imagePath     = Directory of the imagestack/frames
% startIndex    = The starting frame index to use
% endIndex      = The ending frame index to use
% numberlength  = The number of digits in image names e.g. for myimage0001.png we have 4
% fileFormat    = The image format e.g. 'tif', 'png'

global Path_Input;
global Path_Output;
distcomp.feature( 'LocalUseMpiexec', false );
%For performance reasons, this algorithm calculates the texture
%features in overlapping grids and not per pixel

pixelFilter = fspecial('gaussian', 10, 4);

%The size of each grid cell
GRID_SIZE = 20;
HALF_GRID_SIZE = GRID_SIZE/2;

%Set default value for threshCount (algorithm parameter)
threshCount = 4;
%Size of feature vector per pixel
featureVecSize = threshCount*6;
frameCount = endIndex - startIndex+1;

formatstring = strcat('%0',int2str(numberlength),'d');

%Get image dimensions
img = imread(strcat(Path_Input, imagePath, num2str(startIndex, formatstring), ['.', fileFormat]), fileFormat);
[rows, columns, color] = size(img);

%The feature vector per pixel per frame (we take the mean over frames as a final step)
features = zeros(rows,columns,featureVecSize, frameCount);
display(size(features));
%Calculate number of rows of columns of the grid. Multiply by 2 due to
%half-overlap
gridrows = ceil(2*rows/GRID_SIZE);
gridcols = ceil(2*columns/GRID_SIZE);
    
%Loop over each frame
for i = startIndex : endIndex-1
    localval = zeros(rows,columns,featureVecSize);
    %Read the current frame image
    [img2, map] = imread(strcat(Path_Input, imagePath, num2str(i, formatstring), ['.', fileFormat]), fileFormat);
    
    %Remove alpha values for image 
    if (size(img2,3) > 3)
        %img2 = ind2rgb(img2, map); This causes crashes for some strange
        %reason so we naively truncate instead
        img2 = img2(:,:,1:3,:);
    end

    grid = zeros(gridrows, gridcols, featureVecSize);
    for gr=1:gridrows
        for gc=1:gridcols
            centerpixelrow = (gr-1)*HALF_GRID_SIZE+HALF_GRID_SIZE;
            centerpixelcol = (gc-1)*HALF_GRID_SIZE+HALF_GRID_SIZE;
            
            subimg = getSubImg(img2, GRID_SIZE, rows, columns, centerpixelrow, centerpixelcol);
            
            grid(gr,gc,:) = sfta(subimg, threshCount);
        end
    end

    for r = 1:rows
        for c= 1:columns
            gridr = ceil(r/HALF_GRID_SIZE);
            gridc = ceil(c/HALF_GRID_SIZE);
            count = 0;
            localFeatureValues = zeros(1,1,featureVecSize);
            for ir=(gridr-1):(gridr+1)
                for ic=(gridc-1):(gridc+1)
                    if ir > 0 && ic > 0 && ir <= gridrows && ic <= gridcols
                        count=count+1;                    
                        localFeatureValues = localFeatureValues + grid(ir, ic,:);
                    end
                end
            end
            
            localval(r,c,:) = localFeatureValues./count;
            for kk = 1:featureVecSize
                if isnan(localval(r,c,kk))
                    localval(r,c,kk) = 0;
                end
            end
        end
    end
    for kk = 1:featureVecSize
        localval(:,:,kk) = imfilter(localval(:,:,kk), pixelFilter,'replicate');
    end
    features(:,:,:, (i-startIndex)/skip+1) = localval;
end
display(size(features));

NORMALIZE_FEATURES_PER(features);

STFAFeatureNames = {};

for i = 1:featureVecSize
    STFAFeatureNames = [STFAFeatureNames;strcat('SFTA-',num2str(i))];
end

end


function subimg = getSubImg(oriImg, reqImgSize, oriRows, oriColumns, centerRow, centerColumn)

halfsize = reqImgSize/2;

windowLowRow = centerRow - halfsize;
windowHighRow = centerRow + halfsize;
windowLowColumn = centerColumn - halfsize;
windowHighColumn = centerColumn + halfsize;

%Handle edge cases
if ( windowLowRow < 1)
   windowHighRow = windowHighRow + (1-windowLowRow);
   windowLowRow = 1; 
elseif (windowHighRow > oriRows)
    windowLowRow = windowLowRow - (windowHighRow - oriRows);
    windowHighRow = oriRows;
end
if ( windowLowColumn < 1)
   windowHighColumn = windowHighColumn + (1-windowLowColumn);
   windowLowColumn = 1; 
elseif (windowHighColumn > oriColumns)
    windowLowColumn = windowLowColumn - (windowHighColumn - oriColumns);
    windowHighColumn = oriColumns;
end

subimg = oriImg(windowLowRow:windowHighRow, windowLowColumn:windowHighColumn,:);
end

function [motionVectorsAll, SIFTFeatureNames] = ImageStackToSIFT_Video(imagePath, startIndex, skip, endIndex, numberlength, fileFormat, outputSIFTimages)
global Path_Input;
global Path_Output;

SIFTFeatureNames = {'siftcosine';'siftsine';'siftlength'};

formatstring = strcat('%0',int2str(numberlength),'d');

%SIFT parameters
patchsize = 8; 
gridspacing = 1; % sampling step

%Find dimensions
img = imread(strcat(Path_Input, imagePath, num2str(startIndex, formatstring), ['.', fileFormat]), fileFormat);
[rows, columns, color] = size(img);

SIFTflowpara.alpha=2;
SIFTflowpara.d=40;
SIFTflowpara.gamma=0.005;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=5;
SIFTflowpara.topwsize=20;
SIFTflowpara.nIterations=60;

SIFTImg1 = iat_dense_sift(im2double(img),patchsize,gridspacing);
[d1, d2, d3] = size(SIFTImg1);

siftflowframes = (endIndex - startIndex+1)/skip;

motionVectors = zeros(rows, columns, 2);
motionVectorsAll = zeros(rows, columns, 3,siftflowframes);

for i = startIndex:skip : endIndex-2
    img2 = imread(strcat(Path_Input, imagePath, num2str(i+1, formatstring), ['.', fileFormat]), fileFormat);
    SIFTImg2 = iat_dense_sift(im2double(img2),patchsize,gridspacing);
    
    if (exist(strcat(Path_Output, imagePath, '-mv-', num2str(i, formatstring),'-skip-',num2str(skip),'.mat'), 'file') == 0)

        [vx, vy, energylist] = iat_SIFTflow(SIFTImg1, SIFTImg2, SIFTflowpara);
        motionVectors(1+patchsize/2:rows-patchsize/2,1+patchsize/2:columns-patchsize/2,1) = vx;
        motionVectors(1+patchsize/2:rows-patchsize/2,1+patchsize/2:columns-patchsize/2,2) = vy;
        for k = 1:rows
            for l = 1:columns
                if ((k <= patchsize/2 || k >= d1+patchsize/2+1) || (l <= patchsize/2 || l >= d2+patchsize/2+1))
                    projectedX = k-patchsize/2;
                    projectedY = l-patchsize/2;

                    if (projectedX < 1)
                        projectedX = 1;
                    elseif (projectedX >= rows-patchsize)
                        projectedX = d1;
                    end

                    if (projectedY < 1)
                        projectedY = 1;
                    elseif (projectedY >= columns-patchsize)
                        projectedY = d2;
                    end

                    motionVectors(k, l ,1) = vx(projectedX, projectedY);
                    motionVectors(k, l, 2) = vy(projectedX, projectedY);
                end
            end
        end
        outputSIFTimages = true;
        if (outputSIFTimages == true)
            imwrite(iat_flow2rgb(motionVectors(:,:,1),motionVectors(:,:,2)), strcat(Path_Output, imagePath, num2str(i, formatstring), '.png'));
        end
        save(strcat(Path_Output, imagePath, '-mv-',num2str(i, formatstring),'-skip-',num2str(skip), '.mat'), 'motionVectors');
    else
        load(strcat(Path_Output, imagePath, '-mv-', num2str(i, formatstring),'-skip-',num2str(skip), '.mat'));
    end
    motionVectorsAll(:,:,1,(i-startIndex)/skip+1) = motionVectors(:,:,1); 
    motionVectorsAll(:,:,2,(i-startIndex)/skip+1) = motionVectors(:,:,2);
    
    SIFTImg1 = SIFTImg2;
end

motionVectorsAll = double(motionVectorsAll);

for k = 1:rows
    for l = 1:columns
        for i = 1:siftflowframes
            [cos,sin,len] = calcvectorrepresentation(motionVectorsAll(k, l ,1,i), motionVectorsAll(k, l,2,i));
            if (isnan(cos))
                cos = 0;
            end
            if (isnan(sin))
                sin = 0;
            end
            if (isnan(len))
                len = 0;
            end
            
            motionVectorsAll(k, l,1, i) = (cos+1) * 127.5;
            motionVectorsAll(k, l,2, i) = (sin+1) * 127.5;
            motionVectorsAll(k, l,3, i) = len;
        end
    end
end

maxLen = max(max(max(motionVectorsAll(:,:,3,:))));

if (maxLen ~= 0)
    motionVectorsAll(:,:,3,:) = motionVectorsAll(:,:,3,:)*(255/maxLen);
end
end

function [cos,sin,len] = calcvectorrepresentation(a,b)

V = [a;b];
len = norm(V);
N = V/len;
cos = N(1);
sin = N(2);

end


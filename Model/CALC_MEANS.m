function [ Means ] = CALC_MEANS( GPParameters, Image, MeanType)
%CALC_MEANS Summary of this function goes here
%   Detailed explanation goes here
%   Output is a (Layers,Labels,Features,Frames) matrix

if (strcmp(MeanType, 'any-degree-poly'))
    frames = linspace(1, Image.Frames, Image.Frames);
    layerCount = size(GPParameters.cofficients,1);
    labelCount = size(GPParameters.cofficients,2);
    featureCount = size(GPParameters.cofficients,3);
    Means = zeros(layerCount, labelCount, featureCount, Image.Frames);
    for i = 1:layerCount
        for j = 1:labelCount
            for k = 1:featureCount
                Means(i,j,k,:) = polyval(reshape(GPParameters.cofficients(i,j,k,:),[1,GPParameters.polyDegree+1]), frames);
            end
        end
    end
end

if (strcmp(MeanType, 'fixed-continues-piecewise'))
    frames = linspace(1, Image.Frames, Image.Frames);
    layerCount = size(GPParameters.slm,1);
    labelCount = size(GPParameters.slm,2);
    featureCount = size(Image.Features,3);
    Means = zeros(layerCount, labelCount, featureCount, Image.Frames);
    for i = 1:layerCount
        for j = 1:labelCount
            for k = 1:featureCount
                slm = GPParameters.slm(i,j,k);
                Means(i,j,k,:) = slmeval(frames,slm);
            end
        end
    end
end

if (strcmp(MeanType, 'free-discontinues-piecewise'))
    layerCount = size(GPParameters.x1,1);
    labelCount = size(GPParameters.x1,2);
    featureCount = size(GPParameters.x1,3);
    Means = zeros(layerCount, labelCount, featureCount, Image.Frames);
    for i = 1:layerCount
        for j = 1:labelCount
            for k = 1:featureCount
                p = 1;
                for f = 1 : Image.Frames
                    if (f > GPParameters.x2(i,j,k,p))
                        p = p + 1; %skip to next piece
                    end
                    dx = f - GPParameters.x1(i,j,k,p);
                    Means(i,j,k,f) = GPParameters.b(i,j,k,p) + dx * GPParameters.a(i,j,k,p);
                end
            end
        end
    end
end

end


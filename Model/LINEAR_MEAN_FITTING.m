function [coffecients, TerminateFlag] = LINEAR_MEAN_FITTING(Labels, Image, prevCoffecients, frameCount,  Model)

%Assumptions:
% - prevCoffecients & coffecients contain a & b values for each feature
% value per cluster in each layer
% - Framecount is now passed to this function
% - Features are now passed as row,column,frame,featureindex instead of the
% old row,column,featureindex

%% TODO:
% We currently don't find the multilabel optimal solution, but currently
% simply ignores that we need to optimize considering multiple layers

Features = Image.Features;
featureVecSize = size(Features,3);
display(featureVecSize);
TerminateFlag = 1; % Assume termination/convergence unless otherwise proven
rows = Image.D1;
columns = Image.D2;

% Indexmatrix is necessary to construct for decoding labelings
IndexMatrix = zeros(Model.NumberOfLabelsPerLayer^Model.NumberOfLayers,... 
    Model.NumberOfLayers);
count = 0;
loopSize = Model.NumberOfLabelsPerLayer^Model.NumberOfLayers;
for i=1 : loopSize
    count = count +1;
    for j=1 : Model.NumberOfLayers
       IndexMatrix(count,j) = mod(floor((i-1)/...
           (Model.NumberOfLabelsPerLayer^(j-1))), Model.NumberOfLabelsPerLayer)+1;
    end
end

%We first want to find the datavalues that we want to fit the model to:
clusterMeanValues = zeros(Model.NumberOfLayers, Model.NumberOfLabelsPerLayer,frameCount, featureVecSize);
clusterPixelCounts = zeros(Model.NumberOfLayers, Model.NumberOfLabelsPerLayer);
for f=1:frameCount
    for r= 1:rows
        for c=1:columns
            label = Labels(i,j,:);%Gets the layer dependant segmentation index
            for l=1 : Model.NumberOfLayers
                for fv=1:featureVecSize
                    clusterIndex = IndexMatrix(label,l);
                    clusterPixelCounts(l, clusterIndex) = ...
                        clusterPixelCounts(l, clusterIndex) + 1;
                    %4 Christoffer: 
                    %Attempted to access Features(1,1,1,2); 
                    %index out of bounds because size(Features)=[160,320,3,1].
                    %Is cuz Features don't yet index by frames (see assumptions)
                    clusterMeanValues(l, clusterIndex,f, fv) = ...
                        clusterMeanValues(l, IndexMatrix(label,l),f, fv) + Features(r,c,f,fv);
                end
            end
        end
    end
end
% Now we do the division to get means instead of sums
for l=1:Model.NumberOfLayers
    for seg=1:Model.NumberOfLabelsPerLayer
        clusterMeanValues(l,seg,:, :) = clusterMeanValues(l,seg,:, :)./clusterPixelCounts(l,seg);
    end
end


%Now we have the datapoints, we want to fit the model
coffecients = zeros(Model.NumberOfLayers, Model.NumberOfLabelsPerLayer, featureVecSize, 2);
for l=1:Model.NumberOfLayers
    for seg=1:Model.NumberOfLabelsPerLayer
        for fv=1:featureVecSize
            xValues= linspace(1,frameCount,frameCount); %[1 2 3 ... frameCount]
            dataVector = clusterMeanValues(l,seg,:, fv); 
            coffecients(l,seg,fv,:) = polyfit(xValues, dataVector, 1); %fit to first degree polynomial
            %plot(xValues,  polyval(coffecients(l,seg,fv,:),xValues)  );
            
            %Check to see if we have converged
            if abs(coffecients(l,seg,fv,1) - prevCoffecients(l,seg,fv,1)) > 0.01 || ...
               abs(coffecients(l,seg,fv,2) - prevCoffecients(l,seg,fv,2)) > 0.01
                TerminateFlag = 0;
            end
        end
    end
end


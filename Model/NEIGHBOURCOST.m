function [NeighbourCost] = NEIGHBOURCOST(totalCount, gridHeight, gridWidth, neighbourhoodWeight)
% Computes neighbourhood cost matrix
%
% returns a sparse matrix with the neighbor cost that should be applied
% if two data points have different labelings
% 
% totalCount            = The number of grid cells (or pixels for an image)
% gridHeight            = The height of the grid matrix (or pixel height for an image)
% gridWidth             = The width of the grid matrix (or pixel width for an image)
% neighbourhoodWeight   = The weight multiplier for cost

Vs = zeros(totalCount*4,1);
Vi =  ones(totalCount*4,1);
Vj =  ones(totalCount*4,1);

count = 1;
for ind=1:totalCount % all pixels
    [i, j]=ind2ij(ind,gridHeight);

    %If not at the right edge of the image
    if i-1>=1 % &&  EDGE(i-1,j) >= EdgeThreshold
        ind2 =  ij2index([i-1, j], gridHeight);
        Vi(count,1) = ind;
        Vj(count, 1) = ind2;
        % If using pixelvariance add the difference of the pixels and
        % its neighours variance to the weight. (doesn't make much sense)
        Vs(count,1) = neighbourhoodWeight;
        count = count +1 ;
    end
    
    %If not at the left edge of the image
    if i+1<=gridHeight % &&  EDGE(i+1,j) >= EdgeThreshold
        ind2 =  ij2index([i+1, j], gridHeight);
        Vi(count,1) = ind;
        Vj(count, 1) = ind2;
        Vs(count,1) = neighbourhoodWeight;
        count = count +1 ;
    end
     %If not at the top edge of the image
    if j-1>=1 % &&  EDGE(i,j-1) >= EdgeThreshold
        ind2 =  ij2index([i, j-1], gridHeight);
        Vi(count,1) = ind;
        Vj(count, 1) = ind2;
        Vs(count,1) = neighbourhoodWeight;
        count = count +1 ;
    end
     %If not at the bottom edge of the image
    if j+1<=gridWidth % &&  EDGE(i,j+1) >= EdgeThreshold
        ind2 =  ij2index([i, j+1], gridHeight);
        Vi(count,1) = ind;
        Vj(count, 1) = ind2;
        Vs(count,1) = neighbourhoodWeight;
        count = count +1 ;
    end
end

NeighbourCost = sparse(Vi, Vj, Vs, totalCount, totalCount, totalCount*4);
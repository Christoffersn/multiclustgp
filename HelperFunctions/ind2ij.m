function [i j]=ind2ij(ind,m)
% index to i and j image coordinates conversion
%
% ind: index
% m: height of image
% i, j: image coordinates

i=mod(ind-1,m)+1;
j=floor((ind-1)/m)+1;

end
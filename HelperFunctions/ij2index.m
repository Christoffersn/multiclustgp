function index = ij2index(ij, m )
% i and j image coordinates to index conversion
%
% ind: index
% m: height of image
% i, j: image coordinates

index =( ij(2)-1) * m + ij(1);

end


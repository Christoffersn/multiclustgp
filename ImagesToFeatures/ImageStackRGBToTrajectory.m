function [totalvector, tenvectors, length, trajecfeaturenames]...
    = ImageStackRGBToTrajectory( RGB )
% Computes pixel trajectories through RGB space
%
% RGB   = Matrix of size imgWidth*imgHeight*(frameCount*3) with RGB values

lengths = zeros(size(RGB,1),size(RGB,2));

trajecfeaturenames = {};
tvlnames = {};
% Smoothing

filter = fspecial('gaussian',[1,11],3);
RGB = imfilter(RGB,filter,'replicate');

% The vector directly from the start of the trajectory to the end 
totalvector = RGB(:,:,1:3) - RGB(:,:,end-2:end);
totalvector = calc3dvect(totalvector);
totalvector(isnan(totalvector)) = 0;

vectorlength = totalvector(:,:,4);
vector = totalvector(:,:,1:3);

vectorlength = NORMALIZE_FEATURES(vectorlength);
vector = NORMALIZE_FEATURES(vector);

totalvector = cat(3,vector,vectorlength);

totalvectornames = {'totalvectorRed'; 'totalvectorGreen'; ...
    'totalvectorBlue'; 'totalvectorLength'};
trajecfeaturenames = [trajecfeaturenames, totalvectornames];

% The trajectory described by 10 vectors
tenvectors = [];
tenvectorslen = [];
stepsize = floor(size(RGB,3)/10);
for i = 1:10
   if ((i)*stepsize>size(RGB,3))
    vector = RGB(:,:,(i-1)*stepsize+1:(i-1)*stepsize+3)...
        -RGB(:,:,end-2:end);
   else
       vector = RGB(:,:,(i-1)*stepsize+1:(i-1)*stepsize+3)...
        -RGB(:,:,(i)*stepsize:(i)*stepsize+2);
   end
   vector = calc3dvect(vector);
   vector(isnan(vector)) = 0;
   vectorlength = vector(:,:,4);
   vector = vector(:,:,1:3);
   
   tenvectors = cat(3,tenvectors,vector);
   tenvectorslen = cat(3,tenvectorslen,vectorlength);
   
   tvnames = ...
   {strcat('tenvectorRed',num2str(i)); strcat('tenvectorGreen',num2str(i));...
    strcat('tenvectorBlue',num2str(i)); };
    
   tvlnames = [tvlnames;strcat('tenvectorLength',num2str(i))];

   trajecfeaturenames = [trajecfeaturenames;tvnames];
end

    tenvectors = NORMALIZE_FEATURES(tenvectors);
    tenvectorslen = NORMALIZE_FEATURES(tenvectorslen);
    tenvectors = cat(3,tenvectors,tenvectorslen);
    
    trajecfeaturenames = [trajecfeaturenames;tvlnames];
% Totallength
for i = 1:(size(RGB,3)/3)-1

    frame1 = RGB(:,:,(i-1)*3+1:(i-1)*3+3);
    frame2 = RGB(:,:,(i)*3+1:(i)*3+3);
    diff = frame2-frame1;

    length = arrayfun(@mynorm,diff(:,:,1),diff(:,:,2),diff(:,:,3));
  
    lengths = lengths+length;
   if ( mod(i,20) == 0)
      display(i) 
   end
    
end
trajecfeaturenames = [trajecfeaturenames; 'trajectoryLength'];
lengths(isnan(lengths)) = 0;
length = NORMALIZE_FEATURES(lengths);



end

function length = mynorm(x,y,z)
    length = sqrt(x^2+y^2+z^2);
end

function output = calc3dvect(vector)
    [cos,sin,zon,len] = arrayfun(@calcvectorrepresentation,...
           vector(:,:,1),vector(:,:,2),vector(:,:,3));
     output = cat(3,cos,sin,zon,len);
end

function [cos,sin,zon,len] = calcvectorrepresentation(a,b,c)

    V = [a;b;c];
    len = norm(V);
    N = V/len;
    cos = N(1);
    sin = N(2);
    zon = N(3);

end

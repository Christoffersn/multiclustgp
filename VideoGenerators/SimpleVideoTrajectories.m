function Image = SimpleVideoTrajectories
%Create a simple greyscale trajectory video of size 100x100 pixels with 50
frames = 50;
noise = 5;

rng(1);

video = zeros(100,100,1,frames);

%Layer 1 - Cluster 1
for r = 1 : 50
   for c = 1 : 100
       %Write a whole trajectory to this pixel
       b = 80;
       a = 2;
       v = b + (randn * noise);
       for f = 1 : frames
           video(r,c,1,f) = video(r,c,1,f) + v;
           v = v + a;
       end
   end
end

%Layer 1 - Cluster 2
for r = 51 : 100
   for c = 1 : 100
       %Write a whole trajectory to this pixel
       b = 150;
       a = -2;
       v = b + (randn * noise);
       for f = 1 : frames
           video(r,c,1,f) = video(r,c,1,f) + v;
           v = v + a;
       end
   end
end

%Layer 2 - Cluster 1
for r = 1 : 100
   for c = 1 : 50
       %Write a whole trajectory to this pixel
       b = 10;
       a = 0.5;
       v = b + (randn * noise);
       for f = 1 : frames
           video(r,c,1,f) = video(r,c,1,f) + v;
           v = v + a;
       end
   end
end

%Layer 2 - Cluster 2
for r = 1 : 100
   for c = 51 : 100
       %Write a whole trajectory to this pixel
       b = 60;
       a = -0.5;
       v = b + (randn * noise);
       for f = 1 : frames
           video(r,c,1,f) = video(r,c,1,f) + v;
           v = v + a;
       end
   end
end

rng('shuffle');

Image.Features = video;
Image.Frames = frames;

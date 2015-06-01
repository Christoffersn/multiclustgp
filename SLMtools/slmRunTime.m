rng(1);
length = 60000;
xValues = linspace(1,length,length);

dataVector = randi(500,1,length);
tic;
slm = ...
    slmengine(xValues,dataVector,'degree',1, 'interiorknots','free', 'knots', 24);
toc;
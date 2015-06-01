n = 30;
x2 = linspace(1,n,n)'
y2 = randi([40 220],n,1);


slm = slmengine(x2,y2,'degree',1,'interiorknots','free', 'knots',7)
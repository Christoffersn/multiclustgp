


D = zeros(10,12);


for i = 1:10
    bla = sfta(imread(strcat('s', num2str(i), '.png')),2);
  D(i,:) = bla;

end
D(1,:)
norm(D(9,:) - D(2,:))
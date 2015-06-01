function GPParameters = FIT_POLYNOMIAL_MEAN(xValues, dataVector,polyDegree)

P = polyfit(xValues, dataVector, polyDegree);

GPParameters = zeros(1,1,1,polyDegree+1);
for dd = 1 : polyDegree +1
    GPParameters(1,1,1,dd) = P(1,dd);
end

end


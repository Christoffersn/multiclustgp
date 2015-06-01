function slm = FIT_SLM_MEAN(xValues, dataVector, knots, degree)

slm = ...
    slmengine(xValues,dataVector,'degree',degree, 'interiorknots','free', 'knots', knots);

end


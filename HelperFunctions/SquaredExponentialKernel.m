function y = SquaredExponentialKernel(x1, x2, l)
    y = exp(-((x1 - x2)^2 / (2 * l^2)));
end


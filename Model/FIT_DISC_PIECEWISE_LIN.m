function GPParameters = FIT_DISC_PIECEWISE_LIN(dataVector, GPParameters, l, c, d)

y = dataVector;
e = GPParameters.epsilon;
x1 = 1;
[x2, a, b] = findSegment(x1, y, e);
pieces(1) = struct('x1', x1, 'x2', x2, 'a', a, 'b', b);

p = 2;
while (pieces(p-1).x2 ~= length(y))
    %fit next segment
    x1 = pieces(p-1).x2 + 1;
    [x2, a, b] = findSegment(x1, y, e);
    pieces(p) = struct('x1', x1, 'x2', x2, 'a', a, 'b', b);
    
    %try to decrement x1
    tryDecrement = 1;
    while (tryDecrement && x1-1 ~= pieces(p-1).x1)
        x1 = x1 - 1;
        [x2, a, b] = findSegment(x1, y, e);
        if (x2 > pieces(p).x2)
            pieces(p) = struct('x1', x1, 'x2', x2, 'a', a, 'b', b);
            pieces(p-1).x2 = pieces(p-1).x2 - 1;
        else
            tryDecrement = 0;
        end
    end
    
    p = p + 1;
end

for i = 1 : length(pieces)    
    GPParameters.x1(l,c,d,i) = pieces(i).x1;
    GPParameters.x2(l,c,d,i) = pieces(i).x2;
    GPParameters.a(l,c,d,i) = pieces(i).a;
    GPParameters.b(l,c,d,i) = pieces(i).b;
end

end

function [x2, a, b]  = findSegment(x1, y, e)
if (x1 ~= length(y)) % check for trivial case where there is only one point left
    attempts = 20;
    z = linspace(y(x1)-e, y(x1)+e, attempts);
    z(attempts + 1) = z(1);
    z(1) = y(x1);
    
    allx2 = zeros(length(z), 1);
    allsse = zeros(length(z), 1);
    allslopes = zeros(length(z), 1);
    for i = 1 : length(z)
        b = z(i);
        
        x2 = x1; %endpoint of longest valid linear function
        sse = 0; %sum of squared error of longest valid linear function
        slope = 0; %mean slope of longest valid linear function
        checkNextEndPoint = 1;
        while (checkNextEndPoint && x2 ~= length(y)) %check if we can extend endpoint by 1 (x2+1)
            allPtsWithinBound = 1;
            s = 0; %slope variable
            for xi = x1+1 : x2+1
                if (xi == x1+1)
                    s = s + (y(xi) - b); %use offset on first point
                else
                    s = s + (y(xi) - y(xi-1));
                end
            end
            s = s / ((x2+1) - x1); %mean of slope
            currentsse = 0;
            for xi = x1 : x2+1
                ym = b + (s * (xi - x1)); %value predicted by linear function
                error = abs((ym - y(xi)));
                currentsse = currentsse + error^2;
                if (error > e)
                    allPtsWithinBound = 0;
                end
            end
            if (allPtsWithinBound)
                x2 = x2 + 1;
                sse = currentsse;
                slope = s;
            else
                checkNextEndPoint = 0;
            end
        end
        allx2(i) = x2;
        allsse(i) = sse;
        allslopes(i) = slope;
    end
    
    indices = find(allx2 == max(allx2));
    [m, i] = min(allsse(indices));
    
    bestIndex = indices(i);
    x2 = allx2(bestIndex);
    a = allslopes(bestIndex);
    b = z(bestIndex);
else
    x2 = x1;
    a = 0;
    b = y(x1);
end
end
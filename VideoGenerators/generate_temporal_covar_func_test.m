function [ RGB ] = generate_temporal_covar_func_test(frames )
%GENERATE_TEMPORAL_COVAR_FUNC_TEST Summary of this function goes here
%   Detailed explanation goes here


%right-top:     Mean 100-200  short waves    100+x*2+10*(sin(x)-0.5)
%left-bottom    Mean 0-100    short waves    0+x*2+10*(sin(x)-0.5)
%left-top:      Mean 100-200  long waves     100+x*2+30*(sin(x/5)-0.5)
%right-bottom:  Mean 0-100    long waves     0+x*2+30*(sin(x/5)-0.5)

RGB = zeros(100, 100, 3, frames); 


for i = 1: frames
    framevalue = 100+i*2+5*(sin(i)-0.5);
    RGB(51:100,1:50,1:3,i) = framevalue;
end

for i = 1: frames
    framevalue =  0+i*2+5*(sin(i)-0.5);
    RGB(1:50,51:100,1:3,i) = framevalue;
end

for i = 1: frames
    framevalue = 100+i*2+10*(sin(i/5)-0.5);
    RGB(1:50,1:50,1:3,i) = framevalue;
end

for i = 1: frames
    framevalue = 0+i*2+10*(sin(i/5)-0.5);
    RGB(51:100,51:100,1:3,i) = framevalue;
end

end


%--------------------------------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------------------------------
GLOBALS();
%--------------------------------------------------------------------------------------------------
% Paramater configuration
%--------------------------------------------------------------------------------------------------

%Possible features: siftbins, meansift, trajectories, meanrgb, variance
endindex = 65;
step = 1; 
start = 0;
% Restrictions: mod(Frames,step) must be 0
Image = CREATE_VIDEO_FEATURES('/geowind/geowind-', start, step, endindex-1, 4, 'png', 'rgb');
Image.Frames = (endindex-start)/step;
%Give this configuration a name or short description that will be included
%in the output files
Image.Description = 'evalutation-poly4-';

%Toggle the different output options on or off
Output.FLAG_PLOT_ALL_ITERATIONS = 0;
Output.FLAG_PLOT_MEANS = 0;
Output.FLAG_PCA_SCORES = 0;

%Algorithm parameters
Algorithm.NumberOfRuns = 20;
Algorithm.InitializationMethod = 'temporal-weighted';
Algorithm.MaxEM_iterations = 20;
Algorithm.TerminationThreshold = 0.006;
Algorithm.GradientStepSize = 2;
Algorithm.GradientNormalizationConstant = 10^6; % diminishes the gradient stepsize as constant factor
Algorithm.UsePCAonFeatures = 0; %Use PCA on features to achieve an orthogonal subspace transformation
Algorithm.pctVarianceCovered = 95; %percentage of variance that should be covered when PCA is used on features
Algorithm.polyDegree = 8;
Algorithm.MeanType = 'fixed-continues-piecewise';
Algorithm.knots = 7;

%Clustering model parameters
Model.NumberOfLabelsPerLayer = 3;
Model.NumberOfLayers = 2;
Model.regparam = 0;
Model.NeighbourWeight = 200; %higher values -> higher penalty for different labeling of neighbours
tic
CLUSTERING_ALGORITHM(Image, Output, Algorithm, Model);
toc

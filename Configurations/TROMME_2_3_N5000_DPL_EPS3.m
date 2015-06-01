%--------------------------------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------------------------------
GLOBALS();
%--------------------------------------------------------------------------------------------------
% Paramater configuration
%--------------------------------------------------------------------------------------------------

%Possible features: siftbins, meansift, trajectories, meanrgb, variance
endindex = 284;
start = 0;
step = 2; % mod(Frames,step) must be 0.
Image = CREATE_VIDEO_FEATURES('/tromme/tromme', start, step, endindex-1, 3, 'tif', 'rgb');
Image.Frames = (endindex-start)/step;

%Give this configuration a name or short description that will be included
%in the output files
Image.Description = 'tromme-3-2-n5000-dpl-eps3';

%Toggle the different output options on or off
Output.FLAG_PLOT_ALL_ITERATIONS = 0;
Output.FLAG_PLOT_MEANS = 0;
Output.FLAG_PCA_SCORES = 0;
Output.FLAG_FINAL_PARAMETERS = 1;
Output.FLAG_STEP_PARAMETERS = 0;

%Algorithm parameters
Algorithm.NumberOfRuns = 100;
Algorithm.InitializationMethod = 'temporal-weighted';
Algorithm.MaxEM_iterations = 50;
Algorithm.TerminationThreshold = 0.006;
Algorithm.GradientStepSize = 0.3;
Algorithm.UsePCAonFeatures = 0; %Use PCA on features to achieve an orthogonal subspace transformation
Algorithm.pctVarianceCovered = 95; %percentage of variance that should be covered when PCA is used on features
%Algorithm.MeanType = 'any-degree-poly';
%Algorithm.polyDegree = 5;
%Algorithm.MeanType = 'fixed-continues-piecewise';
Algorithm.MeanType = 'free-discontinues-piecewise';
Algorithm.epsilon = 3; %error bound for fitting the discontinues piecewise linear function
%Algorithm.knots = 7;
%Algorithm.degree = 3; %1 or 3

%Clustering model parameters
Model.NumberOfLabelsPerLayer = 2;
Model.NumberOfLayers = 3;
Model.regparam = 0;
Model.NeighbourWeight = 5000; %higher values -> higher penalty for different labeling

CLUSTERING_ALGORITHM(Image, Output, Algorithm, Model);



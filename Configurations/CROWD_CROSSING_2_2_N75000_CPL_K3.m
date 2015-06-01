%--------------------------------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------------------------------
GLOBALS();  
%--------------------------------------------------------------------------------------------------
% Paramater configuration
%--------------------------------------------------------------------------------------------------

%Possible features: siftbins, meansift, trajectories, meanrgb, variance
endIndex = 800;
step = 2; 
start = 200;
% Restrictions: mod(Frames,step) must be 0
Image = CREATE_VIDEO_FEATURES('/crowdcrossing/CrowdCrossing', start, step, endIndex-1, 4, 'tif', 'sift');
Image.Frames = (endIndex-start)/step;

%Give this configuration a name or short description that will be included
%in the output files
Image.Description = 'crowdcrossing-2-2-N75k-cpl-k3';

%Toggle the different output options on or off
Output.FLAG_PLOT_ALL_ITERATIONS = 0;
Output.FLAG_PLOT_MEANS = 0;
Output.FLAG_PCA_SCORES = 0;
Output.FLAG_FINAL_PARAMETERS = 1;
Output.FLAG_STEP_PARAMETERS = 1;

%Algorithm parameters
Algorithm.NumberOfRuns = 200;
Algorithm.InitializationMethod = 'temporal-weighted';
Algorithm.MaxEM_iterations = 50;
Algorithm.TerminationThreshold = 0.006;
Algorithm.GradientStepSize = 0.3;
Algorithm.UsePCAonFeatures = 0; %Use PCA on features to achieve an orthogonal subspace transformation
Algorithm.pctVarianceCovered = 95; %percentage of variance that should be covered when PCA is used on features
%Algorithm.MeanType = 'any-degree-poly';
%Algorithm.polyDegree = 1;
Algorithm.MeanType = 'fixed-continues-piecewise';
Algorithm.degree = 1;
%Algorithm.MeanType = 'free-discontinues-piecewise';
%Algorithm.epsilon = 20; %error bound for fitting the discontinues piecewise linear function
Algorithm.knots = 3;

%Clustering model parameters
Model.NumberOfLabelsPerLayer = 2;
Model.NumberOfLayers = 2;
Model.regparam = 0;
Model.NeighbourWeight = 75000; %higher values -> higher penalty for different labeling

CLUSTERING_ALGORITHM(Image, Output, Algorithm, Model);


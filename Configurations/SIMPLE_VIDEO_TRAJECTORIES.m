%--------------------------------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------------------------------
GLOBALS();
%--------------------------------------------------------------------------------------------------
% Paramater configuration
%--------------------------------------------------------------------------------------------------

%Possible features: siftbins, meansift, trajectories, meanrgb, variance
Image = SimpleVideoTrajectories;

%Give this configuration a name or short description that will be included
%in the output files
Image.Description = 'simple_video-traj';

%Toggle the different output options on or off
Output.FLAG_PLOT_ALL_ITERATIONS = 0;
Output.FLAG_PLOT_MEANS = 0;
Output.FLAG_PCA_SCORES = 0;

%Algorithm parameters
Algorithm.NumberOfRuns = 10;
Algorithm.InitializationMethod = 'temporal-weighted';
Algorithm.MaxEM_iterations = 50;
Algorithm.TerminationThreshold = 0.006;
Algorithm.UsePCAonFeatures = 0; %Use PCA on features to achieve an orthogonal subspace transformation
Algorithm.pctVarianceCovered = 95; %percentage of variance that should be covered when PCA is used on features

%Clustering model parameters
Model.NumberOfLabelsPerLayer = 2;
Model.NumberOfLayers = 2;
Model.regparam = 0;
Model.NeighbourWeight = 500; %higher values -> higher penalty for different labeling

Algorithm.GradientStepSize = 0.3;

CLUSTERING_ALGORITHM(Image, Output, Algorithm, Model);


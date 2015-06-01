%--------------------------------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------------------------------
GLOBALS();
%--------------------------------------------------------------------------------------------------
% Paramater configuration
%--------------------------------------------------------------------------------------------------

frames = 50;

Image.Frames = frames;
Image.Features  = generate_temporal_covar_func_test(frames);

%Give this configuration a name or short description that will be included
%in the output files
Image.Description = 'covar_test';

%Toggle the different output options on or off
Output.FLAG_PLOT_ALL_ITERATIONS = 0;
Output.FLAG_PLOT_MEANS = 0;
Output.FLAG_PCA_SCORES = 0;

%Algorithm parameters
Algorithm.NumberOfRuns = 50;
Algorithm.InitializationMethod = 'temporal-weighted';
Algorithm.MaxEM_iterations = 50;
Algorithm.TerminationThreshold = 0.006;
Algorithm.GradientStepSize = 2;
Algorithm.GradientNormalizationConstant = 10^6; % diminishes the gradient stepsize as constant factor
Algorithm.UsePCAonFeatures = 0; %Use PCA on features to achieve an orthogonal subspace transformation
Algorithm.pctVarianceCovered = 95; %percentage of variance that should be covered when PCA is used on features

%Clustering model parameters
Model.NumberOfLabelsPerLayer = 4;
Model.NumberOfLayers = 2;
Model.regparam = 0;
Model.NeighbourWeight = 200; %higher values -> higher penalty for different labeling of neighbours

CLUSTERING_ALGORITHM(Image, Output, Algorithm, Model);


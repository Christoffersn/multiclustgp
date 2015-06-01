function CLUSTERING_ALGORITHM(inputData, outputFlags, algorithmParams, modelParams, useCUDA)
% Compute clusterings for an inputData and write results as inputDatas
%
% inputData         = The data in grid format to computer the clustering on 
% outputFlags       = Struct of parameters for output method
% AlgorithmParams   = Struct of algorithm parameters
% modelParams       = Struct of model parameters
% useCUDA           = Whether to use CUDA for ~30% speedup (NVidia cards only)


if nargin == 4
   useCUDA = false; 
end

%--------------------------------------------------------------------------------------------------
% Optional orthogonal subspace transformation of features using PCA
%--------------------------------------------------------------------------------------------------

if (algorithmParams.UsePCAonFeatures == 1)
    [transformedFeatures, components] = FEATURE_TRANSFORMATION(inputData.Features, algorithmParams);
    inputData.Features = transformedFeatures;
end

%--------------------------------------------------------------------------------------------------
% Initilization of data related variables
%--------------------------------------------------------------------------------------------------
inputData.D1 = size(inputData.Features, 1); %grid height
inputData.D2 = size(inputData.Features, 2); %grid width
inputData.NumberOfDimensions = size(inputData.Features, 3);
inputData.NumberOfPixels = inputData.D1 * inputData.D2;
inputData.NumberOfNeighbourPairs = (inputData.D1 - 1) * inputData.D2 + (inputData.D2 - 1) * inputData.D1;
%Resized inputData from 3d array to 2d array with size NumberOfPixels * NumberOfDimensions
inputData.FlatFeatures = double(reshape(inputData.Features, inputData.NumberOfPixels, inputData.NumberOfDimensions,inputData.Frames));

%Precompute a sparse matrix with the neighbor cost that should be applied
%if two data points have different labelings
NeighbourCost = NEIGHBOURCOST(inputData.NumberOfPixels, inputData.D1, inputData.D2, modelParams.NeighbourWeight);

%--------------------------------------------------------------------------------------------------
% Running the algorithm
%--------------------------------------------------------------------------------------------------
for currentRun = 1 : algorithmParams.NumberOfRuns
     
        PreviousIterationEnergy = 10^15;
    
        %--------------------------------------------------------------------------------------------------
        % Initialization of labels and cluster means
        %--------------------------------------------------------------------------------------------------
        [Labels, GPParameters] = INITIALIZATION(modelParams.NumberOfLabelsPerLayer,...
            modelParams.NumberOfLayers, algorithmParams,modelParams, inputData, algorithmParams.InitializationMethod);
        Means = CALC_MEANS(GPParameters, inputData, algorithmParams.MeanType);
        %--------------------------------------------------------------------------------------------------
        %  Expectation - Maximization inner loop
        %--------------------------------------------------------------------------------------------------
        for currentEMStep = 1 : algorithmParams.MaxEM_iterations
            fprintf('\nRun: %d - EM-iteration: %d\n', currentRun, currentEMStep);

            %--------------------------------------------------------------------------------------------------
            % MAP AlgorithmParams (Expectation-step)
            %--------------------------------------------------------------------------------------------------
            [Labels, Energy, TerminationFlag] = MAP_IMPLEMENT_GCO ...
                    (Labels, inputData, Means, algorithmParams, modelParams, ...
                    NeighbourCost, PreviousIterationEnergy, outputFlags, ...
                    currentRun, currentEMStep);
            
            PreviousIterationEnergy = Energy;
            
            %--------------------------------------------------------------------------------------------------
            % Update Parameters (Maximization-step)
            %--------------------------------------------------------------------------------------------------
            if (TerminationFlag == 0)
                [Means, GPParameters, TerminationFlag] = GRADIENT_DESCENT_COORDINATE(Labels, inputData, Means, GPParameters, modelParams, algorithmParams, useCUDA);
            end

            SAVE_PARAMETERS(GPParameters, outputFlags, TerminationFlag, inputData.Description, currentRun, currentEMStep, Energy);
            
            if ((TerminationFlag == 1) || (algorithmParams.MaxEM_iterations == currentEMStep))
                PLOTSEGMENT_IMPLEMENT(Labels, modelParams.NumberOfLayers, modelParams.NumberOfLabelsPerLayer,currentEMStep, Means, outputFlags, inputData.Description, currentRun, Energy);
                break;
            end
            
        end
        
        %Output feature scores based on PCA
        if(isfield(inputData, 'FeatureNames') && outputFlags.FLAG_PCA_SCORES == 1)
            if (algorithmParams.UsePCAonFeatures == 1)
                OutputMeans = REVERSE_FEATURE_TRANSFORMATION(Means, components, modelParams.NumberOfLabelsPerLayer, modelParams.NumberOfLayers(currentLayerRun));
            else
                OutputMeans = Means;
            end
            writeVariance = false;
            WRITE_PCA(GPParameters, inputData.FeatureNames, Energy, writeVariance, inputData.Description);

        end

end
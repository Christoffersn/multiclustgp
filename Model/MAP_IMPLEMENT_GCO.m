function [LabelsOutput, NewEnergy, TerminationFlag] = MAP_IMPLEMENT_GCO ...
    (Labels, Image, Means, Algorithm, Model, NeighbourCost, ...
    PreviousIterationEnergy, Output, currentRun, currentEMStep)
% Performs the MAP step, labeling pixels, using GCO
%
% Labels                    = Current labelings
% Image                     = The input data
% Means                     = The current means
% Algorithm                 = Struct containing algorithm parameters
% Model                     = Struct containing model parameters
% NeighbourCost             = NeighbourhoodCost parameter
% PreviousIterationEnergy   = Previous Energy, used for termination
% Output                    = Output parameter
% currentRun                = Numbering of the current run
% currentEMStep             = Numbering of the current EM step


FlatFeatures = Image.FlatFeatures;

NumberOfLayers = Model.NumberOfLayers; 
NumberOfLabelsPerLayer = Model.NumberOfLabelsPerLayer;

TerminationFlag = 0;
D1 = Image.D1;
D2 = Image.D2;

Labels = reshape(Labels, size(Labels,1)*size(Labels,2), 1);
NumberOfCombinations = NumberOfLabelsPerLayer  ^ NumberOfLayers;

Size = D1*D2;
dataCost = zeros(Size, NumberOfCombinations);


%--------------------------------------------------------------------------
%  Calculating Datacost
%--------------------------------------------------------------------------

for k = 1: NumberOfCombinations
    %Means should be calculated for this specific combination
    %of labels. Return value is a matrix indexed by
    %(frame, layer, feature)
    MLidx = SL_IND_TO_ML_IND (k, NumberOfLayers, NumberOfLabelsPerLayer);


    for framenumber = 1:Image.Frames

        A = FlatFeatures(:,:,framenumber);

        for i = 1 : NumberOfLayers
            A = bsxfun(@minus, A, reshape(Means(i,MLidx(i), :,framenumber),[1 size(A,2)]) );
        end

        A = sum(abs(A).^2,2);

        dataCost(:,k)  = dataCost(:,k) + A;

    end
end

DM = SINGLE_LAYER_POT(NumberOfLayers, NumberOfLabelsPerLayer);    


integerDataCost = int64(round(dataCost));

%--------------------------------------------------------------------------
%  Calculating Multilabel Graph Cut
%--------------------------------------------------------------------------
%
gco = GCO_Create(Size, NumberOfCombinations);
if (currentEMStep > 1)
    GCO_SetLabeling(gco, Labels);
end

integerDataCostNormalized = integerDataCost;


warning ('off','all');
GCO_SetDataCost(gco, integerDataCostNormalized');
GCO_SetSmoothCost(gco, DM);  % change on DM to alter the neighbour-penalty
GCO_SetNeighbors(gco, NeighbourCost);
GCO_Expansion(gco);
[Energy, D, S] = GCO_ComputeEnergy(gco) ;
warning ('on','all');

NewLabels = GCO_GetLabeling(gco);
GCO_Delete(gco);

LabelsOutput = reshape(NewLabels, D1, D2);

NewEnergy = Energy;

if( PreviousIterationEnergy > NewEnergy)
    str1 = sprintf('%0.5e',NewEnergy);
    str2 = sprintf('%0.5e',D);
    str3 = sprintf('%0.5e',S);
    disp('Decreasing Energy ! ');
    disp(strcat('Total energy = ',str1));
    disp(strcat('Data term energy = ', str2));
    disp(strcat('Neighbourhood term energy = ',str3));
    
    threshold = double((double(PreviousIterationEnergy) - double(NewEnergy))/double(NewEnergy));
    
    if( threshold < Algorithm.TerminationThreshold)
        str5 = sprintf('%0.5e',threshold);
        disp(strcat('Terminating: decreasing threshold exceeded: ',str5));
        TerminationFlag = 1;
    end
else
    if (PreviousIterationEnergy < NewEnergy)
        fprintf('Warning:  Energy non decreasing! ');
        str1 = sprintf('%0.5e',NewEnergy);
        disp(strcat('Total energy = ',str1));
    else
        fprintf('Warning:  Energy not changing! Terminating ! (Maybe GradientStepsize too big!) ');
        str1 = sprintf('%0.5e',NewEnergy);
        disp(strcat('Total energy = ',str1));
        TerminationFlag = 1;
    end
end
%------------------------------------------------------------------------------------

if ((Output.FLAG_PLOT_ALL_ITERATIONS == 1))
    PLOTSEGMENT_IMPLEMENT(LabelsOutput, NumberOfLayers, NumberOfLabelsPerLayer, currentEMStep, Means, Output, Image.Description, currentRun, NewEnergy);
end

end

function [RegularizationScore] = REGULARIZATION_TERM(Means, NumberOfLayers, NumberOfLabelsPerLayer, regparam, NumberOfNeighbourPairs)
% Calculates a regularization score for penalizing similar segmentations
%
% Means                     = The current means
% NumberOfLabelsPerLayer    = Number of labels for the solution
% NumberOfLayers            = Number of layers for the solution
% regparam                  = Regularization parameter
% NumberOfNeighbourPairs    = Number of neighbours

% Loop over all unique, assymetric, non-reflexive combinations of layers (for 3 layers: 1-2, 1-3, 2-3)
t = 0;
for l1= 1: NumberOfLayers - 1
    for l2= l1+1: NumberOfLayers
        tLocal = 0;
        i = 1;
        j = 1;
        checkmatrix = zeros(NumberOfLabelsPerLayer * NumberOfLabelsPerLayer, 2);
        checkmatrix2 = zeros(NumberOfLabelsPerLayer * NumberOfLabelsPerLayer, 2); 

        for i1= 1: NumberOfLabelsPerLayer
            for i2 =1: NumberOfLabelsPerLayer
                check = [i1, i2];

                if ( sum(ismember(check,checkmatrix,'rows')) < 1)
                    checkmatrix(i,:) = [i2,i1]; 
                    i = i+1;
                    for j1=1: NumberOfLabelsPerLayer
                        for j2=1: NumberOfLabelsPerLayer

                            check2 = [j1, j2];

                            if ( sum(ismember(check2,checkmatrix2,'rows')) < 1)
                                checkmatrix2(j,:) = [j2,j1];
                                j = j+1;
                                if (i1 ~= i2 && j1 ~=j2)  
                                    tLocal = tLocal + (((Means(:,j1,l1) - Means(:,j2,l1))/norm(Means(:,j1,l1) - Means(:,j2,l1)))' * ( (Means(:,i1,l2) - Means(:,i2,l2))/norm(Means(:,i1,l2) - Means(:,i2,l2))))^2;
                                end
                            end

                        end
                    end
                    checkmatrix2 = zeros(NumberOfLabelsPerLayer * NumberOfLabelsPerLayer, 2); 
                    j = 1;
                end 
            end
        end
        t = t + tLocal;
    end
end
RegularizationScore =  regparam*NumberOfNeighbourPairs*t;
% normalization of score-function
%----------------------------------------------------
RegularizationScore = RegularizationScore / (NumberOfLabelsPerLayer ^NumberOfLayers);
%-------------------------------------------------------------------------------------------------
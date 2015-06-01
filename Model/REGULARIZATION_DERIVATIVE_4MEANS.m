function [MeanDerivative1, MeanDerivative2, MeanDerivative3, MeanDerivative4] = REGULARIZATION_DERIVATIVE_4MEANS(MEAN1, MEAN2, MEAN3, MEAN4, regparam)
% Calculating derivative for MEAN1 and MEAN2

Mean1Mean2Diff = MEAN1 - MEAN2;

Mean1Mean2Diff_2 = MEAN1*2 - MEAN2*2;
NORM1 = sqrt(sum(abs(Mean1Mean2Diff).^2,1));


Mean3Mean4Diff = MEAN3 - MEAN4;

Mean3Mean4Diff_2 = MEAN3*2 - MEAN4*2;
NORM2 = sqrt(sum(abs(Mean3Mean4Diff).^2,1));

NORM1b = sqrt((sum(abs(Mean1Mean2Diff).^2,1)).^3);
NORM2b = sqrt((sum(abs(Mean3Mean4Diff).^2,1)).^3);

denominator1 = NORM1 * NORM2;
denominator2 = 2 * NORM1b * NORM2;

numerator1 = bsxfun(@times, Mean1Mean2Diff, Mean3Mean4Diff);
numerator1 = bsxfun(@times, numerator1, Mean1Mean2Diff_2);

term1 = Mean3Mean4Diff / (denominator1);
term2 = numerator1 / (denominator2);


MeanDerivative1 = term1 - term2;

%-----------------------------------------------------------------------------------------

factor1 = sum(bsxfun(@times, Mean1Mean2Diff, Mean3Mean4Diff),1)/ denominator2;
term3 = Mean1Mean2Diff_2 * factor1;

term3 = term3 - term2;

MeanDerivative1 = MeanDerivative1 - term3;
MeanDerivative2 = MeanDerivative1 * (-1);

%-------------------------------------------------------------------------------------------
%   Calculating derivative for MEAN3 and MEAN4
%-------------------------------------------------------------------------------------------
denominator2b = 2 * NORM1 * NORM2b;
numerator1b = bsxfun(@times, Mean1Mean2Diff, Mean3Mean4Diff);
numerator1b = bsxfun(@times, numerator1b, Mean3Mean4Diff_2);

term1b = Mean1Mean2Diff / (denominator1);
term2b = numerator1b / (denominator2b);

MeanDerivative3 = term1b - term2b;

%------------------------------------------------------------------------------------------

factor1b = sum(bsxfun(@times, Mean1Mean2Diff, Mean3Mean4Diff),1)/ denominator2b;
term3b = Mean3Mean4Diff_2 * factor1b;

term3b = term3b - term2b;

MeanDerivative3 = MeanDerivative3 - term3b;
MeanDerivative4 = MeanDerivative3 * (-1);

%---------------------------------------------------------------------------------------------

constant = 2*((MEAN1 - MEAN2)/ norm(MEAN1-MEAN2))' * ((MEAN3 - MEAN4)/ norm(MEAN3-MEAN4));

MeanDerivative1 = MeanDerivative1 * constant;
MeanDerivative2 = MeanDerivative2 * constant;
MeanDerivative3 = MeanDerivative3 * constant;
MeanDerivative4 = MeanDerivative4 * constant;
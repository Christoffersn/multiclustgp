function GLOBALS()
%--------------------------------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------------------------------
global Path_Root;
Path_Root = '../';

global Path_SLMtools;
Path_SLMtools = '../SLMtools';

global Path_Alpha_Expansion;
Path_Alpha_Expansion = '../alpha_expansion';

global Path_Alpha_Expansion_Matlab;
Path_Alpha_Expansion_Matlab = '../alpha_expansion/matlab';

global Path_Features;
Path_Features = '../ImagesToFeatures';

global Path_Helpers;
Path_Helpers = '../HelperFunctions';

global Path_Model;
Path_Model = '../Model';

global Path_Input;
Path_Input = '../ImagesR';

global Path_Output;
Path_Output = '../ImagesW';

addpath(genpath('../IAT_v0.9.1'));
global Path_SIFT;
Path_SIFT = '../IAT_v0.9.1';



global Path_FeatureTrans;
Path_FeatureTrans = '../FeatureTransformation';

global Path_VideoGenerators;
Path_VideoGenerators = '../VideoGenerators';

addpath(Path_Root, Path_SLMtools, Path_Alpha_Expansion, Path_Model, Path_Alpha_Expansion_Matlab, Path_Features, Path_SIFT, Path_Helpers,Path_FeatureTrans,Path_VideoGenerators);
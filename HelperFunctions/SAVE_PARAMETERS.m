function SAVE_PARAMETERS(GPParameters, Output, TerminationFlag, Description, currentRun, currentEMStep, Energy)
global Path_Output;

if ((Output.FLAG_FINAL_PARAMETERS && TerminationFlag) || Output.FLAG_STEP_PARAMETERS)
    stepName = sprintf('EM%d',currentEMStep);
    
    if TerminationFlag == 1
        stepName = 'final';
    end
    
    filePath = strcat(Path_Output, '/parameters/', Description, sprintf('-E%d-Run%d-%s.mat', Energy, currentRun, stepName));
    save(filePath,'GPParameters');
end
end
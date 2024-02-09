function [subcode] = spm_glm_script(ids)

addpath('/group/mlr-lab/AH/Projects/spm12/');
addpath('/group/mlr-lab/AH/Projects/toolboxes/');
addpath('/imaging/projects/cbu/mr21005_memb/scripts/');
addpath('/imaging/local/software/spm_toolbox/marsbar/marsbar_v0.44/')

root = ['/imaging/projects/cbu/mr21005_memb/derivatives/'];
cd([root]);

subcode{1} = ['sub-',ids]


%% run 1st level analysis for all subjects

cond={'SESB';'SEMB';'MESB';'MEMB'};

for s=1:size(subcode,2)
    
    %on each iteration, the code checks to see if a data file is present in the derivatives/SPM folder
    %data in this folder is the MNI smoothed (8mm) EPI per protocol
    %if data does not exist, the function produces them.
    %All GLMs are built using these base files
    
    % cycles through all conditions and produces first level GLMs for univariate analyses
    firstlevel_glm(subcode{s})
    
    % cycles through all conditions and produces first level GLMs for multivafiate analyses
    firstlevel_glm_mvpa(subcode{s})
    
    % cycles through MB conditions and produces first level GLMs for odd volumes for univariate
    firstlevel_glm_mbodd(subcode{s})
    
    % cycles through MB conditions and produces first level GLMs for odd volumes for multivariate
    firstlevel_glm_mvpa_mbodd(subcode{s})

    % cycles through all conditions and produces first level GLMs for univariate analyses in native space
    firstlevel_glm_native(subcode{s})


end


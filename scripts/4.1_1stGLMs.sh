#!/bin/bash
echo "
++++++++++++++++++++++++" 

#ids is set in 4.0_sub_job_1stGLMs.sh 
dirp=/imaging/projects/cbu/mr21005_memb

#master script that runs each GLM script one after the other: 1) 1st standard, 2) 1st MVPA, 3) 1st standard MB odd only, 4) 1st MVPA MB odd only, 5) 1st Native space 
matlab_r2019a -nodisplay -nodesktop -r "addpath('$dirp/scripts/');spm_glm_script('"$ids"');exit"



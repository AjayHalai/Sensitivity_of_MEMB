#!/bin/bash
echo "
++++++++++++++++++++++++" 
echo +* "Set up script run environment" 
#adds appropriate tools and options - no need to change if you have access to /imaging/mlr_imaging as the tools are in my folder 'AH', which is accessable to all users
export PATH=$PATH:/imaging/local/software/anaconda/latest/x86_64/bin/
export PATH=/imaging/local/software/centos7/ants/bin/ants/bin/:$PATH
module load fsl
FSLOUTPUTTYPE=NIFTI_GZ

dirp=/imaging/projects/cbu/mr21005_memb/

for ids in $(seq -w 001 021); do
echo $ids
#remove existing data
rm -rf "$dirp"/mc04/sub-"$ids"/sub-"$ids"_task-*.nii

#cycle through conditions
for cond in SESB SEMB MESB MEMB; do

#base dimensions are slightly different so use correct base image
if [[ "$cond" == "SE"* ]]; then
ref="$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$cond"_run-01_space-EPI_desc-preproc_bold.nii.gz
else
ref="$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$cond"_run-01_echo-1_desc-preproc_bold.nii.gz
fi

#apply the inverse transform (for some reason doesn't work to go straight to EPI space using EPI as ref so using T1w and that works)
antsApplyTransforms -d 3 \
-i "$dirp"/derivatives/GLM/second/con/effectofecho_band/S_and_C/atl_peak.nii.gz \
-r "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_desc-preproc_T1w.nii.gz \
-o "$dirp"/mc04/sub-"$ids"/sub-"$ids"_task-"$cond"_space-EPI_peak.nii.gz \
--default-value 0 --float 1 -n Linear \
--transform identity \
--transform "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_task-"$cond"*from-T1w_to-scanner*.txt \
--transform "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5 

#change warped dimensions to match EPI base
flirt -in "$dirp"/mc04/sub-"$ids"/sub-"$ids"_task-"$cond"_space-EPI_peak.nii.gz -ref $ref -out "$dirp"/mc04/sub-"$ids"/sub-"$ids"_task-"$cond"_space-EPI_peak.nii.gz -interp trilinear -applyxfm -usesqform
#unzip for easier matlab reading
gzip -d "$dirp"/mc04/sub-"$ids"/sub-"$ids"_task-"$cond"_space-EPI_peak.nii.gz

done

done

#run matlab script to extract peak voxel in matrix
matlab_r2020b -nodisplay -nodesktop -r "addpath('$dirp/');AH_getpeak_voxel();exit"




#!/bin/bash

dirp=/imaging/projects/cbu/mr21005_memb


for ids in 001 002 003 004 007 008 009 010 011 012 013 014 015 016 017 018 019 020 021; do

antsApplyTransforms -d 3 -e 3 -i $dirp/mc04/sub-"$ids"/sub-"$ids"_SEMB_seed_*_sphere6_artefact_mask_single_voxel.nii -r $dirp/work/MNI_largefov.nii.gz -o $dirp/mc04/sub-"$ids"/sub-"$ids"_SEMB_MNIartefact.nii --default-value 0 --float 1 -n NearestNeighbor --transform "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 --transform $dirp/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_task-SEMB_run-01_from-scanner_to-T1w_mode-image_xfm.txt --transform identity --transform identity

antsApplyTransforms -d 3 -e 3 -i $dirp/mc04/sub-"$ids"/sub-"$ids"_MEMB_seed_*_sphere6_artefact_mask_single_voxel.nii -r $dirp/work/MNI_largefov.nii.gz -o $dirp/mc04/sub-"$ids"/sub-"$ids"_MEMB_MNIartefact.nii --default-value 0 --float 1 -n NearestNeighbor --transform "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 --transform $dirp/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_task-MEMB_run-01_from-scanner_to-T1w_mode-image_xfm.txt --transform identity --transform identity

#matlab code that calls MARSBAR tool in SPM to create an ROI sphere around a point (transformed from native to MNI space in previous two steps)
#done for artefacts in MB (only location B) and MEMB (locations B, Ag, Bg)
matlab_r2019a -nodisplay -nodesktop -r "addpath('$dirp/scripts/');peaks_toMNI_ROIs('sub-"$ids"');exit"

done


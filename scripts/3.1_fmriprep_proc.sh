#!/bin/bash
echo "
++++++++++++++++++++++++" 
echo +* "Set up script run environment" 
#adds appropriate tools and options
export PATH=/imaging/local/software/centos7/ants/bin/ants/bin/:$PATH
module load fsl
module load apptainer
FSLOUTPUTTYPE=NIFTI_GZ
#set jq path, manually installed
export PATH=$dirp/work/apps/bin/:$PATH

#conda enviroment includes tedana toolkit
conda activate /imaging/projects/cbu/mr21005_memb/work/AHALAI

dirp=/imaging/projects/cbu/mr21005_memb
echo "$dirp"/data/sub-"$ids"

#run fmriprep singularity - no freesurfer reconall, framewise-displacement set to 0.3 to detect outlier volumes but can change post-hoc
singularity run -B /imaging/projects/cbu/mr21005_memb/work/templateflow:/opt/templateflow --cleanenv -B /imaging/local/software/freesurfer/7.1.1/license.txt:/opt/freesurfer/license.txt -B $dirp:/base /imaging/local/software/singularity_images/fmriprep/fmriprep-22.0.0.sif /base/data /base/derivatives/fmriprep participant --participant-label sub-"$ids" -w /base/work --fs-no-reconall --write-graph --fs-license-file /opt/freesurfer/license.txt --nthreads 16 --omp-nthreads 16 --output-spaces MNI152NLin2009cAsym:res-2 --fd-spike-threshold 0.3 --me-output-echos

#re-process the multi-echo data to include ICA denoising pipeline

#automatically detect fmriprep folders
folders=$(ls -d $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/func*)

for s in $folders; do
#detect if data had multi-echo fMRI (this folder is not present for single echo fMRI)
if [ -d "$s"/join_echos ]; then
echo $s
echo "Found multi-echo, running multi-echo specific analysis"

#get all folders related to each echo from fmriprep outputs use bold_bold as skullstrip already had func masked applied, using T1 mask here instead
echoes=$(ls -d "$s"/bold_bold_trans_wf/_*)
x=0
unset e1
for e in $echoes; do
#echo $e
xx=`expr $x + 1`
x=$(printf "%01d" "$xx")
#re-save fMRIPrep outputs in tmp space
cp -rf $e/merge/vol0000_xform-00000_*.nii.gz $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/tmp"$x".nii.gz
#get echo time from orig json file
y=$(cat $e/merge/*.json | jq --raw-output ".[2][1][0]")
y=$(basename $y .nii.gz)
if [ $xx == 1 ]; then
	e1=($(cat "$dirp"/data/sub-"$ids"/func/"$y".json | jq '.EchoTime'));e1=$(echo "$e1*1000" | bc -l)
	elif [ $xx == 2 ]; then 
	e2=($(cat "$dirp"/data/sub-"$ids"/func/"$y".json | jq '.EchoTime'));e2=$(echo "$e2*1000" | bc -l)
	elif [ $xx == 3 ]; then 
	e3=($(cat "$dirp"/data/sub-"$ids"/func/"$y".json | jq '.EchoTime'));e3=$(echo "$e3*1000" | bc -l)
fi
done

#move T1 mask into mean native EPI space and match dimensions
flirt -in "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-*1_desc-brain_mask.nii.gz -ref $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/tmp"$x".nii.gz -applyxfm -usesqform -interp nearestneighbour -out $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/T1.nii.gz

fslmaths $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/tmp"$x".nii.gz -Tmean -nan $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/tmp"$x"_mean
#uses flirt BBR transforms 
antsApplyTransforms --default-value 0 --float 1 --input "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-*1_desc-brain_mask.nii.gz --interpolation NearestNeighbor --output $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/T1.nii.gz --reference-image $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/tmp"$x"_mean.nii.gz --transform $s/bold_reg_wf/fsl_bbr_wf/fsl2itk_inv/affine.txt

#run tedana
tedana -d $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/tmp1.nii.gz $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/tmp2.nii.gz $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/tmp3.nii.gz -e $e1 $e2 $e3 --fittype curvefit --n-threads 16 --maxit 500 --maxrestart 50 --mask $dirp/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/T1.nii.gz --out-dir "$s"/tedana/

#identify filename and run automatically (dirty version)
yy=${y#*"$ids"_}
cond=${yy%_run*}
yy=${y#*_run-0}
r=${yy%_echo*}
echo sub-"$ids"_"$cond"_"$r"

#apply bbr and MNI warps in one concat step
antsApplyTransforms -d 3 -e 3 -i "$s"/tedana/desc-optcomDenoised_bold.nii.gz -r $dirp/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_space-MNI152NLin2009cAsym_res-2_desc-preproc_T1w.nii.gz -o "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_rec-tedana_run-0"$r"_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz --default-value 0 --float 1 -n LanczosWindowedSinc --transform "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 --transform $s/bold_reg_wf/fsl_bbr_wf/fsl2itk_fwd/affine.txt --transform identity --transform identity

antsApplyTransforms -d 3 -e 3 -i "$s"/tedana/desc-optcom_bold.nii.gz -r $dirp/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_space-MNI152NLin2009cAsym_res-2_desc-preproc_T1w.nii.gz -o "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_rec-t2star_run-0"$r"_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz --default-value 0 --float 1 -n LanczosWindowedSinc --transform "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 --transform $s/bold_reg_wf/fsl_bbr_wf/fsl2itk_fwd/affine.txt --transform identity --transform identity

#apply to t2star map
antsApplyTransforms -d 3 -i "$s"/tedana/T2starmap.nii.gz -r $dirp/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_space-MNI152NLin2009cAsym_res-2_desc-preproc_T1w.nii.gz -o "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_run-0"$r"_space-MNI152NLin2009cAsym_res-2_desc-t2star_roi.nii.gz --default-value 0 --float 1 -n LanczosWindowedSinc --transform "$dirp"/derivatives/fmriprep/sub-"$ids"/anat/sub-"$ids"_run-01_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 --transform $s/bold_reg_wf/fsl_bbr_wf/fsl2itk_fwd/affine.txt --transform identity --transform identity

#move files to final output folders and rename
#move flirt bbr reg in case native EPI outputs need to be moved to T1 (or MNI space)
cp -rf $s/bold_reg_wf/fsl_bbr_wf/fsl2itk_fwd/affine.txt "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_run-01_from-bold_to-T1w_mode-affine_xfm.txt
#copy old json file and rename
cp "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_run-0"$r"*bold.json "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_rec-tedana_run-0"$r"_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.json
cp "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_run-0"$r"*bold.json "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_rec-t2star_run-0"$r"_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.json
#create space to store multi-echo preprocessing and report files
rm -rf "$dirp"/derivatives/fmriprep/sub-"$ids"/func/ME_report/"$cond"/*
mkdir -p "$dirp"/derivatives/fmriprep/sub-"$ids"/func/ME_report/"$cond"/
mv "$s"/tedana/* "$dirp"/derivatives/fmriprep/sub-"$ids"/func/ME_report/"$cond"/

#remove fmriprep (old) multi-echo outputs
rm -rf "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_run*bold*.nii.gz "$dirp"/derivatives/fmriprep/sub-"$ids"/func/sub-"$ids"_"$cond"_run*_T2starmap.*

#retain native preprocessed files
mkdir -p "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/ "$dirp"/derivatives/fmriprep_native/sub-"$ids"/anat/
tmp=${cond#*task-}

#get preprocessed files from fmriprep work files and copy to derivatives folder
cp -rf "$s"/bold_bold_trans_wf/*echo*0*/merge/vol0000_xform-00000_clipped_merged.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-1_space-EPI_desc-preproc_bold.nii.gz
cp -rf "$s"/bold_bold_trans_wf/*echo*1*/merge/vol0000_xform-00000_clipped_merged.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-2_space-EPI_desc-preproc_bold.nii.gz
cp -rf "$s"/bold_bold_trans_wf/*echo*1*/merge/vol0000_xform-00000_clipped_merged.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-3_space-EPI_desc-preproc_bold.nii.gz
#same for masks
cp -rf "$s"/final_boldref_wf/enhance_and_skullstrip_bold_wf/combine_masks/vol0000_xform-00000_clipped_merged_average_corrected_brain_mask_maths.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-1_space-EPI_desc-brain_mask.nii.gz
cp -rf "$s"/final_boldref_wf/enhance_and_skullstrip_bold_wf/combine_masks/vol0000_xform-00000_clipped_merged_average_corrected_brain_mask_maths.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-2_space-EPI_desc-brain_mask.nii.gz
cp -rf "$s"/final_boldref_wf/enhance_and_skullstrip_bold_wf/combine_masks/vol0000_xform-00000_clipped_merged_average_corrected_brain_mask_maths.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-3_space-EPI_desc-brain_mask.nii.gz
#same for json
cp -rf "$dirp"/data/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-1_bold.json "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-1_space-EPI_desc-preproc_bold.json
cp -rf "$dirp"/data/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-2_bold.json "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-2_space-EPI_desc-preproc_bold.json
cp -rf "$dirp"/data/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-3_bold.json "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-3_space-EPI_desc-preproc_bold.json

#run T2* optimum combination for native data
t2smap -d "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-1_space-EPI_desc-preproc_bold.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-2_space-EPI_desc-preproc_bold.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-3_space-EPI_desc-preproc_bold.nii.gz -e $e1 $e2 $e3 --fittype curvefit --n-threads 16 --out-dir "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/"$tmp"/

#transform T1 brain into EPI space
antsApplyTransforms --default-value 0 -d 3 --float 1 --input "$dirp"/work/fmriprep_22_0_wf/single_subject_"$ids"_wf/func_preproc_task_"$tmp"_*/t1w_brain/*T1w_corrected_xform_masked.nii.gz --interpolation Linear --output "$dirp"/derivatives/fmriprep_native/sub-"$ids"/anat/sub-"$ids"_run-01_space-"$tmp"_desc-preproc_T1w.nii.gz --reference-image "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_echo-1_space-EPI_desc-brain_mask.nii.gz --transform ["$s"/bold_reg_wf/fsl_bbr_wf/fsl2itk_fwd/affine.txt, 1]
cp -rf $s/bold_reg_wf/fsl_bbr_wf/fsl2itk_fwd/affine.txt "$dirp"/derivatives/fmriprep_native/sub-"$ids"/anat/sub-"$ids"_task-"$tmp"_run-01_from-bold_to-T1w_mode-affine_xfm.txt

else
echo "No multi-echo detected, skipping multi-echo specific analysis"

mkdir -p "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/ "$dirp"/derivatives/fmriprep_native/sub-"$ids"/anat/
tmp=${s#*task_}
tmp=${tmp%_run_01_wf}

cp -rf $s/bold_bold_trans_wf/merge/vol0000_xform-00000_clipped_merged.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_space-EPI_desc-preproc_bold.nii.gz
cp -rf "$s"/final_boldref_wf/enhance_and_skullstrip_bold_wf/combine_masks/vol0000_xform-00000_clipped_merged_average_corrected_brain_mask_maths.nii.gz "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_space-EPI_desc-brain_mask.nii.gz
cp -rf "$dirp"/data/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_bold.json "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_space-EPI_desc-preproc_bold.json

antsApplyTransforms --default-value 0 -d 3 --float 1 --input "$s"/t1w_brain/sub-"$ids"_run-01_T1w_corrected_xform_masked.nii.gz --interpolation Linear --output "$dirp"/derivatives/fmriprep_native/sub-"$ids"/anat/sub-"$ids"_run-01_space-"$tmp"_desc-preproc_T1w.nii.gz --reference-image "$dirp"/derivatives/fmriprep_native/sub-"$ids"/func/sub-"$ids"_task-"$tmp"_run-01_space-EPI_desc-brain_mask.nii.gz --transform ["$s"/bold_reg_wf/fsl_bbr_wf/fsl2itk_fwd/affine.txt, 1]
cp -rf $s/bold_reg_wf/fsl_bbr_wf/fsl2itk_fwd/affine.txt "$dirp"/derivatives/fmriprep_native/sub-"$ids"/anat/sub-"$ids"_task-"$tmp"_run-01_from-bold_to-T1w_mode-affine_xfm.txt
echo $tmp
fi

#remove fmriprep work/temp files
#rm -rf $dirp/work/fmriprep_wf/single_subject_"$ids"_wf
done


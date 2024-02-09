#!/bin/bash

#conda environment with heudiconv pip installed
conda activate /imaging/projects/cbu/mr21005_memb/work/AHALAI

#set dcm2niix path
export PATH=$PATH:/imaging/projects/cbu/mr21005_memb/work/AHALAI/bin

dirp=/imaging/projects/cbu/mr21005_memb/
#heudiconv -d $PWD/Dicom/sub-{subject}/*/*/*/*.dcm -o $PWD/Nifti/ -f convertall -s $1 -c none -b --overwrite
cd $dirp
mrdir=/mridata/cbu/

x=000;

rm -rf $dirp/data/

for s in CBU210081_METHODS CBU210108_METHODS CBU210110_METHODS CBU210116_METHODS CBU210117_MR21005 CBU210122_MR21005 CBU210136_MR21005 CBU210149_MR21005 CBU210150_MR21005 CBU210159_MR21005 CBU210171_MR21005 CBU210172_MR21005 CBU210212_MR21005 CBU210213_MR21005 CBU210223_MMR21005 CBU210258_MR21005 CBU210261_MR21005 CBU210283_MR21005 CBU210301_MR21005 CBU210318_MR21005 CBU210319_MR21005; do

#increase subj number by 1 using three digits (001, 002, etc)
y=`expr $x + 1`
x=$(printf "%03d" "$y")

#tmp copy files to newly named BIDS compliant folder
mkdir -p ./sub-"$x"/
cp -rf $mrdir/"$s" ./sub-"$x"/

#run converter to output BIDS compliant files
heudiconv -d $dirp/sub-{subject}/*/*/*/*.dcm -o $dirp/data/ -f $dirp/scripts/heuristics_main.py -s "$x" -c dcm2niix -b --overwrite

#remove tmp DICOM copies
rm -rf ./sub-"$x"/
done



#!/bin/bash
export PATH=$PATH:/imaging/local/software/centos7/anaconda3/bin/

cd /imaging/projects/cbu/mr21005_memb/

conda create --prefix /imaging/projects/cbu/mr21005_memb/work/AHALAI python=3 pip mdp numpy scikit-learn scipy 
conda activate /imaging/projects/cbu/mr21005_memb/work/AHALAI
pip install nilearn nibabel
pip install tedana
pip install heudiconv


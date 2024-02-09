#!/bin/bash


dirp=/imaging/projects/cbu/mr21005_memb

for s in 001 002 005 006 007 008 009 010 011 012 013 014 015 016 017 018 019 020 021; do

echo "$s"

#runs preprocessing
#sbatch -o $dirp/work/logs/"$s"tedana.out -c 16 --job-name=MEMB"$s" --export=ids=${s} $dirp/scripts/sub_fmriprep.sh
sbatch -o $dirp/work/logs/"$s"fmriprep.out -c 16 --job-name=MEMB"$s" --export=ids=${s} $dirp/scripts/3.1_fmriprep_proc.sh


done

#001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 018 019 020 021
	


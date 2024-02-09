#!/bin/bash


dirp=/imaging/projects/cbu/mr21005_memb

for s in 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 018 019 020 021; do

echo "$s"

#runs 1st level GLMs
sbatch -o $dirp/work/logs/"$s"_1stglm.out -c 16 --job-name=GLM"$s" --export=ids=${s} $dirp/scripts/4.1_1stGLMs.sh

done


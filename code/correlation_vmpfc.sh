#!/bin/bash

# This script uses the derivatives from XCP_Engine. They are too big to upload, so feel free to ask for them egarza@gmail.com

root=/media/egarza/Elements2/projects/ADDIMEX_TMS/FC_CLIN/3-Experiment

for i in ${root}/derivatives/xcpEngine/xcpOut_27JAN2020/sub-0*/ses-t*/norm/sub-0*_ses-t*_std.nii.gz; 

do file=$(basename $i); 
seed=vmPFC;
file2=${file%%.*};

# Extract the mean signal from the vmPFC resulting significant cluster.

fslmeants -i ${i} -o ${root}/derivatives/correlations/1D/${file%%.*}${seed}.1D -m ${root}/data/normative/vmPFC_cluster_sphere_bin; 

# Extract the correlation coefficients.
3dfim+ -polort 3 -input ${i} -ideal_file ${root}/derivatives/correlations/1D/${file%%.*}${seed}.1D -out Correlation -bucket ${root}/derivatives/correlations/seed_vmPFC/${file%%.*}${seed}.nii.gz;

# Convert correlations to Z-score
3dcalc -a ${root}/derivatives/correlations/seed_vmPFC/${file%%.*}${seed}.nii.gz -expr 'log((1+a)/(1-a))/2' -prefix ${root}/derivatives/correlations/seed_vmPFC/${file%%.*}${seed}_Z.nii.gz; 

done

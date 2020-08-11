#!/bin/bash

root=$PWD

# Functional connectivity (FC) between lDLPFC and vmPFC.

## Binarize AVERAGE seed cone to obtain lDLPFC mask.

fslmaths ${root}/data/normative/AVG_CONE_msk_normed.nii.gz -bin ${root}/data/normative/AVE_CONE_msk_normed_bin.nii.gz

## Clusterize normative AVERAGE FC map to obtain vmPFC mask.

fslmaths ${root}/data/normative/AVG_CONE_msk_normed_AvgR.nii.gz -uthr -0.2 -thr -1 ${root}/analysis/FSL/Acute_Interaction/rois/test

fslmaths ${root}/analysis/FSL/Acute_Interaction/rois/test.nii.gz -mul -1 ${root}/analysis/FSL/Acute_Interaction/rois/test2

cluster -i ${root}/analysis/FSL/Acute_Interaction/rois/test2.nii.gz -t 0.2 -o ${root}/analysis/FSL/Acute_Interaction/rois/test3

fslmaths ${root}/analysis/FSL/Acute_Interaction/rois/test3.nii.gz -uthr 11 -thr 11 ${root}/analysis/FSL/Acute_Interaction/rois/vmPFC

fslmaths ${root}/analysis/FSL/Acute_Interaction/rois/vmPFC -bin ${root}/analysis/FSL/Acute_Interaction/rois/vmPFC_bin

rm ${root}/analysis/FSL/Acute_Interaction/rois/test*

## Extract correlation values from AVG SEED (you need to edit and run)

bash ${root}/code/correlation_dlpfc.sh


# Mixed Model analysis (voxel wise)

## Step 1 create paired T-Test files

## T1-T0
for i in *.nii.gz; do echo fslmaths Zmaps/lDLPFC/${i%%?????????????.*}1_stdlDLPFC_Z.nii.gz -sub ${i%%?????????????.*}0_stdlDLPFC_Z.nii.gz ../Submaps_PairedTTest/${i%%??????????????????.*}t0t1_diff.nii.gz; done

## Interaction

fslmerge -t runSham_T0-T1 sub-001_t0t1*  sub-002_t0t1*  sub-006_t0t1*  sub-008_t0t1* sub-010_t0t1* sub-012_t0t1* sub-013_t0t1* sub-018_t0t1* sub-019_t0t1* sub-022_t0t1* sub-027_t0t1* sub-030_t0t1* sub-033_t0t1* sub-036_t0t1* sub-042_t0t1* sub-045_t0t1* sub-046_t0t1* sub-047_t0t1* sub-050_t0t1* sub-052_t0t1*

fslmerge -t runSham_T1-T0 sub-001_t1t0*  sub-002_t1t0*  sub-006_t1t0*  sub-008_t1t0* sub-010_t1t0* sub-012_t1t0* sub-013_t1t0* sub-018_t1t0* sub-019_t1t0* sub-022_t1t0* sub-027_t1t0* sub-030_t1t0 sub-033_t1t0* sub-036_t1t0* sub-042_t1t0* sub-045_t1t0* sub-046_t1t0* sub-047_t1t0* sub-050_t1t0* sub-052_t1t0*

fslmerge -t runReal_T0-T1 sub-003_t0t1* sub-004_t0t1* sub-007_t0t1* sub-011_t0t1* sub-015_t0t1* sub-016_t0t1* sub-017_t0t1* sub-020_t0t1* sub-021_t0t1* sub-023_t0t1* sub-024_t0t1* sub-025_t0t1* sub-026_t0t1* sub-031_t0t1* sub-032_t0t1* sub-034_t0t1* sub-037_t0t1* sub-039_t0t1* sub-041_t0t1* sub-043_t0t1* sub-048_t0t1* sub-049_t0t1* sub-053_t0t1* sub-054_t0t1*

fslmerge -t runReal_T1-T0 sub-003_t1t0* sub-004_t1t0* sub-007_t1t0* sub-011_t1t0* sub-015_t1t0* sub-016_t1t0* sub-017_t1t0* sub-020_t1t0* sub-021_t1t0* sub-023_t1t0* sub-024_t1t0* sub-025_t1t0* sub-026_t1t0* sub-031_t1t0* sub-032_t1t0* sub-034_t1t0* sub-037_t1t0* sub-039_t1t0* sub-041_t1t0* sub-043_t1t0* sub-048_t1t0* sub-049_t1t0* sub-053_t1t0* sub-054_t1t0*

fslmerge -t runGroup_T1-T0 runSham_T1-T0 runReal_T1-T0

fslmerge -t runGroup_T0-T1 runSham_T0-T1 runReal_T0-T1

randomise -i Submaps_PairedTTest/runGroup_T1-T0.nii.gz -o Interaction/InteractionT1T0 -d Interaction.mat -t Interaction.con -m analysis/FSL/AcuteInteraction/rois/vmPFC_roi_bin.nii.gz -T --uncorrp

fslmaths InteractionT1T0_tfce_corrp_tstat1.nii.gz -thr 0.95 -bin vmPFC_sig_cluster.nii.gz

####################################################################################################

# Functional connectivity (FC) between vmPFC and whole brain.

# Extract mean correlation

bash code/correlation_vmpfc.sh


### T1-T0
for i in *.nii.gz; do fslmaths ${i%%????????????.*}1_stdvmPFC_Z.nii.gz -sub ${i%%????????????.*}0_stdvmPFC_Z.nii.gz ../../Submaps_PairedTTest/${i%%?????????????????.*}t1t0_diff_vmPFC.nii.gz; done


fslmerge -t vmpfcSham_T1-T0 sub-001_t1t0*  sub-002_t1t0*  sub-006_t1t0*  sub-008_t1t0* sub-010_t1t0* sub-012_t1t0* sub-013_t1t0* sub-018_t1t0* sub-019_t1t0* sub-022_t1t0* sub-027_t1t0* sub-030_t1t0* sub-033_t1t0* sub-036_t1t0* sub-042_t1t0* sub-045_t1t0* sub-046_t1t0* sub-047_t1t0* sub-050_t1t0* sub-052_t1t0*

fslmerge -t vmpfcReal_T1-T0 sub-003_t1t0* sub-004_t1t0* sub-007_t1t0* sub-011_t1t0* sub-015_t1t0* sub-016_t1t0* sub-017_t1t0* sub-020_t1t0* sub-021_t1t0* sub-023_t1t0* sub-024_t1t0* sub-025_t1t0* sub-026_t1t0* sub-031_t1t0* sub-032_t1t0* sub-034_t1t0* sub-037_t1t0* sub-039_t1t0* sub-041_t1t0* sub-043_t1t0* sub-048_t1t0* sub-049_t1t0* sub-053_t1t0* sub-054_t1t0*

fslmerge -t vmpfcGroup_T1-T0 vmpfcSham_T1-T0 vmpfcReal_T1-T0

randomise -i Submaps_PairedTTest/vmPFC/vmpfcGroup_T1-T0.nii.gz -o Interaction/vmpfc_InteractionT1T0 -d Interaction.mat -t Interaction.con -m rois/MNI152_T1_2mm_brain_mask -T -n 5000 --uncorrp



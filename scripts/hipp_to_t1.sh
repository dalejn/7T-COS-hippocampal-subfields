#!/bin/sh

# Combine those transforms and register the T2* hipp image to the
# freesurfer labels

sub=d701
sd=/data/zhoud4/fs_subjects
wd=$sd/$sub


mri_convert $wd/mri/rh.hippoSfLabels-T1.v10.mgz $wd/nii//rh.hippoSfLabels-T1.v10.nii.gz

$ANTSPATH/antsApplyTransforms -d 3 \
    --float 1 -v 1 \
    -i $wd/nii/struc.anat/T1_biascorr.nii.gz  \
    -o $wd/hipp/T1_biascorr_to_r_fshipp.nii.gz \
    -r $wd/nii/rh.hippoSfLabels-T1.v10.nii.gz 

$ANTSPATH/antsApplyTransforms -d 3 \
    --float 1 -v 1 \
    -i $wd/hipp/hip_algn_avg.nii.gz  \
    -t 
    -o $wd/hipp/t2hipp_to_r_fshipp.nii.gz \
    -r $wd/nii/rh.hippoSfLabels-T1.v10.nii.gz 


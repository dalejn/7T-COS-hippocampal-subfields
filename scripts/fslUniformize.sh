#!/bin/sh
set -x -e
sub=$1
export FREESURFER_HOME=/data/adamt/Apps/fs6beta/
export SUBJECTS_DIR=/data/zhoud4/fs_subjects
export ANTSPATH=/data/adamt/build/antsbin/bin/
source $FREESURFER_HOME/SetUpFreeSurfer.sh
module load fsl

if [ ! -e $SUBJECTS_DIR/$sub ];then
    echo  "$SUBJECTS_DIR/$sub doesn't exist"
    exit 1
fi

mkdir -p $SUBJECTS_DIR/$sub/nii/
if [ ! -e $SUBJECTS_DIR/$sub/nii/001.mgz ]; then
	mv $SUBJECTS_DIR/$sub/mri/orig/001.mgz $SUBJECTS_DIR/$sub/nii/
fi
cd  $SUBJECTS_DIR/$sub/nii/	
mri_convert $SUBJECTS_DIR/$sub/nii/001.mgz \
    $SUBJECTS_DIR/$sub/nii/orig.nii.gz
fsl_anat -i orig.nii.gz -o struc
#$ANTSPATH/N4BiasFieldCorrection -d 3 -b [200] \
#    -c [50x50x40x30,0.00000001] \
#    -i $SUBJECTS_DIR/$sub/nii/orig.nii.gz \
#    -o $SUBJECTS_DIR/$sub/nii/orig_n4.nii.gz \
#    -r 0 -s 2 
mri_convert $SUBJECTS_DIR/$sub/nii/struc.anat/T1_biascorr.nii.gz \
    $SUBJECTS_DIR/$sub/nii/T1_biascorr.mgz
cd $SUBJECTS_DIR/$sub/mri/orig/
ln -s ../../nii/T1_biascorr.mgz 001.mgz

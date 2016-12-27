#!/bin/sh
set -x -e
# The goal here is to get the freesurfer hippcampal labels into the
# same space as the T1 & T2 images so that we can feed all three of
# them into ANTS and run a template creation

base=/home/adamt/proj/hippo_hr/moa/
export FREESURFER_HOME=/data/adamt/Apps/fs6beta/
export SUBJECTS_DIR=/data/adamt/fs6beta_subs
source /data/adamt/Apps/fs6beta//SetUpFreeSurfer.sh
sub=md130
debug=false

# Find the biggest hipframe
l_j=0
r_j=0
for i in 5 4 3 2 1;do
    fsDir=$SUBJECTS_DIR/${sub}-${i}.long.${sub}Templ/
    hrhipp=$base/$sub/scan0$i/hrhipp/
    if [ ! -e $fsDir ]; then echo "Freesurfer subdir $fsdir doesn't exist, skipping this scan";continue;fi
    mkdir -p $base/$sub/scan0$i/antsHrhipp/
    cd $base/$sub/scan0$i/antsHrhipp/
# First get everything into nifti format
    mri_convert $fsDir/mri/T1.mgz \
	./fs_T1.nii.gz
    mri_convert $fsDir/mri/lh.hippoSfLabels-T1.v10.mgz \
	./lh.hippoSfLabels-T1.v10.nii.gz
    mri_convert $fsDir/mri/rh.hippoSfLabels-T1.v10.mgz \
	./rh.hippoSfLabels-T1.v10.nii.gz
echo $sub $i
    l_k=`mri_info --dim $fsDir/mri/lh.hippoSfLabels-T1.v10.mgz | awk '{print $1*$2+$3}'`
    r_k=`mri_info --dim $fsDir/mri/rh.hippoSfLabels-T1.v10.mgz | awk '{print $1*$2+$3}'`
    if [ "$l_k" -gt "$l_j" ];then l_j=$l_k;lhipTarg=$i;fi
    if [ "$r_k" -gt "$r_j" ];then r_j=$r_k;rhipTarg=$i;fi
done


# Before we start we need to convert the rotcrop tranform to ITK
need_to_convert_rotcrop=false
if [ "$need_to_convert_rotcrop" = true ];then
    c3d_affine_tool -ref ../../conf/hrhipptemplate.nii.gz \
	-src hrhipp/hip_algn_avg.nii.gz  \
	../../scripts/hrhipptemplate_rot_tr_crop.mat \
	-fsl2ras -oitk ../../scripts/itk_rot_tr_crop.txt
fi

# For each scan
for i in 5 4 3 2 1;do
    fsDir=$SUBJECTS_DIR/${sub}-${i}.long.${sub}Templ/
    hrhipp=$base/$sub/scan0$i/hrhipp/
    echo $sub $i
    wd=$base/$sub/scan0$i/antsHrhipp/
    cd $wd
# Get all the masks in the same frame

# But not like this. It doesn't work
#    $ANTSPATH/antsApplyTransforms -d 3 \
#	--float 1 -v 1 \
#	-i $wd/rh.hippoSfLabels-T1.v10.nii.gz  -o $wd/rh.hippoSfLabels-T1.v10_fit.nii.gz \
#	-r ../../scan0$rhipTarg/antsHrhipp/rh.hippoSfLabels-T1.v10.nii.gz \
#	-t identity \
#        -n nearestneighbor &
#    $ANTSPATH/antsApplyTransforms -d 3 \
#	--float 1 -v 1 \
#	-i $wd/lh.hippoSfLabels-T1.v10.nii.gz  -o $wd/lh.hippoSfLabels-T1.v10_fit.nii.gz \
#	-r ../../scan0$lhipTarg/antsHrhipp/lh.hippoSfLabels-T1.v10.nii.gz \


    $ANTSPATH/ImageMath 3 $wd/rhippFrame.nii.gz m \
	../../scan0$rhipTarg/antsHrhipp/rh.hippoSfLabels-T1.v10.nii.gz 0
    $ANTSPATH/ImageMath 3 $wd/lhippFrame.nii.gz m \
	../../scan0$lhipTarg/antsHrhipp/lh.hippoSfLabels-T1.v10.nii.gz 0

    $ANTSPATH/ImageMath 3 rh.hippoSfLabels-T1.v10_fit.nii.gz \
	$wd/rhippFrame.nii.gz  \
	rh.hippoSfLabels-T1.v10.nii.gz 0
    $ANTSPATH/ImageMath 3 lh.hippoSfLabels-T1.v10_fit.nii.gz \
	$wd/lhippFrame.nii.gz  \
	lh.hippoSfLabels-T1.v10.nii.gz 0

# Also make some mask and dilate them 
    fslmaths lh.hippoSfLabels-T1.v10_fit -bin -dilM lh.hippoMask_dil&
    fslmaths rh.hippoSfLabels-T1.v10_fit -bin -dilM rh.hippoMask_dil&

# figure out the transformation from freesurfer space to fsl_anat space with ANTS
    if [ ! -e fs_T1_to_T1_biascorr0GenericAffine.mat ];then
	$ANTSPATH/antsRegistration -d 3 \
	    --float 1 -v 1 \
	    -r [${hrhipp}/T1_biascorr.nii.gz,fs_T1.nii.gz,1] \
	    -t Rigid[0.1] \
	    -m MI[${hrhipp}/T1_biascorr.nii.gz,fs_T1.nii.gz,1,32,Regular,0.25] \
	    -c [1000x500x250x100,1e-8,10] \
	    -f 8x4x2x1 -s 4x2x1x0 \
	    -o fs_T1_to_T1_biascorr
	echo $sub $i
    fi
    
# Now convert the hipp_avg_algn image to fs space by
# 1. Apply: hip_to_t1.mat and the inverse of fs_T1_to_T1_biascorr
# But how do we end up at 0.4?
# Let's first try to apply the inverse of fs_T1_to_T1_biascorr on T1_biascorr with the label image as the target
# Note that we will need to eventually get the label images into a single image or process them separately
#    $ANTSPATH/antsApplyTransforms -d 3 \
#	--float 1 -v 1 \
#	-i $hrhipp/T1_biascorr.nii.gz  -o T1_biascorr_to_fs_T1_test.nii.gz \
#	-r fs_T1.nii.gz \
#	-t [fs_T1_to_T1_biascorr0GenericAffine.mat,1] 
#k that works, now
#    $ANTSPATH/antsApplyTransforms -d 3 \
#	--float 1 -v 1 \
#	-i $hrhipp/T1_biascorr.nii.gz  -o T1_biascorr_to_fs_T1_test.nii.gz \
#	-r ./lh.hippoSfLabels-T1.v10.nii.gz \
#	-t [fs_T1_to_T1_biascorr0GenericAffine.mat,1] 
# And that works, too. Yay. Now the big finish:


#    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $wd/rh.hippoSfLabels-T1.v10.nii.gz  -o $wd/rh.hippoSfLabels-T1.v10_fit.nii.gz \
	-r ../../scan0$rhipTarg/antsHrhipp/rh.hippoSfLabels-T1.v10.nii.gz \
        -n nearestneighbor &

    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $wd/lh.hippoSfLabels-T1.v10.nii.gz  -o $wd/lh.hippoSfLabels-T1.v10_fit.nii.gz \
	-r ../../scan0$lhipTarg/antsHrhipp/lh.hippoSfLabels-T1.v10.nii.gz \

    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $hrhipp/T1_biascorr.nii.gz  -o $wd/T1_biascorr_to_r_fshipp.nii.gz \
	-r ../../scan0$rhipTarg/antsHrhipp/rh.hippoSfLabels-T1.v10.nii.gz \
	-t [fs_T1_to_T1_biascorr0GenericAffine.mat,1]&
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $hrhipp/T1_biascorr.nii.gz  -o $wd/T1_biascorr_to_l_fshipp.nii.gz \
	-r ../../scan0$lhipTarg/antsHrhipp/lh.hippoSfLabels-T1.v10.nii.gz \
	-t [fs_T1_to_T1_biascorr0GenericAffine.mat,1]&

    c3d_affine_tool -ref $hrhipp/T1_biascorr.nii.gz \
	-src $hrhipp/hip_algn_avg.nii.gz  \
	$hrhipp/hip_to_t1.mat \
	-fsl2ras -oitk $wd/itk_hip_to_t1.txt
    wait 
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $hrhipp/hip_algn_avg.nii.gz  -o hip_algn_avg_to_l_fshipp.nii.gz \
	-r ../../scan0$lhipTarg/antsHrhipp/lh.hippoSfLabels-T1.v10.nii.gz \
	-t [fs_T1_to_T1_biascorr0GenericAffine.mat,1] \
	-t itk_hip_to_t1.txt& 
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $hrhipp/hip_algn_avg.nii.gz  -o hip_algn_avg_to_r_fshipp.nii.gz \
	-r ../../scan0$lhipTarg/antsHrhipp/lh.hippoSfLabels-T1.v10.nii.gz \
	-t [fs_T1_to_T1_biascorr0GenericAffine.mat,1] \
	-t itk_hip_to_t1.txt 
wait
    $ANTSPATH/N4BiasFieldCorrection -d 3 -b [200] -c [50x50x40x30,0.00000001] \
	-i hip_algn_avg_to_r_fshipp.nii.gz -o $wd/r_t2_bfc.nii.gz \
	-r 0 -s 2 &
    $ANTSPATH/N4BiasFieldCorrection -d 3 -b [200] -c [50x50x40x30,0.00000001] \
	-i hip_algn_avg_to_l_fshipp.nii.gz -o $wd/l_t2_bfc.nii.gz \
	-r 0 -s 2 &
    $ANTSPATH/N4BiasFieldCorrection -d 3 -b [200] -c [50x50x40x30,0.00000001] \
	-i T1_biascorr_to_l_fshipp.nii.gz -o $wd/l_t1_bfc.nii.gz \
	-r 0 -s 2 &
    $ANTSPATH/N4BiasFieldCorrection -d 3 -b [200] -c [50x50x40x30,0.00000001] \
	-i T1_biascorr_to_r_fshipp.nii.gz -o $wd/r_t1_bfc.nii.gz \
	-r 0 -s 2 &


#################
#cat /home/adamt/proj/hippo_hr/moa/mvtc_ants/job95_r.sh

#/data/adamt/antsLab_7T/ants-2.1.0-redhat//N4BiasFieldCorrection -d 3 -b [200] -c [50x50x40x30,0.00000001] -i md122-5.nii.gz -o ./hrhipptemplate0md122-5Repaired.nii.gz -r 0 -s 2 >> ./job_95_metriclog.txt >> ./job_95_metriclog.txt

$ANTSPATH/antsRegistration -d 3 --float 1 -u 1 \
     -w [0.01,0.99] -z 1 -r [hrhipptemplate0.nii.gz,md122-5.nii.gz,1] \
    -t Rigid[0.1] \
    -m MI[hrhipptemplate0.nii.gz,./hrhipptemplate0md122-5Repaired.nii.gz,1,32,Regular,0.25] \
    -c [1000x500x250x100,1e-8,10] -f 8x4x2x1 -s 4x2x1x0 \
    -t Affine[0.1] \
    -m MI[hrhipptemplate0.nii.gz,./hrhipptemplate0md122-5Repaired.nii.gz,1,32,Regular,0.25] \
    -c [1000x500x250x100,1e-8,10] -f 8x4x2x1 -s 4x2x1x0 \
    -t SyN[0.1,3,0] \
    -m CC[hrhippteplate0.nii.gz,./hrhipptemplate0md122-5Repaired.nii.gz,1,4] \
    -c [100x100x70x20,1e-9,10] -f 6x4x2x1 -s 3x2x1x0 \
    -o ./hrhippmd122-595 >> ./job_95_metriclog.txt
 
$ANTSPATH/antsApplyTransforms -d 3 --float 1 \
    -i ./hrhipptemplate0md122-5Repaired.nii.gz \
    -o ./hrhipptemplate0md122-595WarpedToTemplate.nii.gz \
    -r hrhipptemplate0.nii.gz \
    -t ./hrhippmd122-5951Warp.nii.gz \
    -t ./hrhippmd122-5950GenericAffine.mat >> ./job_95_metriclog.txt
##########################

done
exit









    if [ "$debug" = true]; then
    # Does it work?
	$ANTSPATH/antsApplyTransforms -d 3 \
	    --float 1 -v 1 \
	    -i fs_T1.nii.gz  -o ants_fs_T1_to_T1_biascorr_test.nii.gz \
	    -r ${hrhipp}/T1_biascorr.nii.gz \
	    -t fs_T1_to_T1_biascorr0GenericAffine.mat 
    # It did. So what if you compine it with the MNI warp?
	$ANTSPATH/antsApplyTransforms -d 3 \
	    --float 1 -v 1 \
	    -i fs_T1.nii.gz  -o ants_fs_T1_to_MNI1.0mm_test.nii.gz \
	    -r $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz \
	    -t fs_T1_to_T1_biascorr0GenericAffine.mat \
	    -t ${hrhipp}/t1_to_MNI_ants1Warp.nii.gz \
	    -t ${hrhipp}/t1_to_MNI_ants0GenericAffine.mat 
    #that works too. Good. Now get it to 0.5
	$ANTSPATH/antsApplyTransforms -d 3 \
	    --float 1 -v 1 \
	    -i fs_T1.nii.gz  -o ants_fs_T1_to_MNI0.5mm.nii.gz \
	    -r $FSLDIR/data/standard/MNI152_T1_0.5mm.nii.gz \
	    -t fs_T1_to_T1_biascorr0GenericAffine.mat \
	    -t ${hrhipp}/t1_to_MNI_ants1Warp.nii.gz \
	    -t ${hrhipp}/t1_to_MNI_ants0GenericAffine.mat \
	    -t ${hrhipp}/MNI1.0_to_MNI_0.5_ants0GenericAffine.mat 
    fi
   # That works. Now rotcrop. Mind the order of the transforms
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i fs_T1.nii.gz  -o ants_fs_T1_to_rotcrop.nii.gz \
	-r ${base}/conf/hrhipptemplate.nii.gz \
	-t ${base}/scripts/itk_rot_tr_crop.txt \
	-t fs_T1_to_T1_biascorr0GenericAffine.mat \
	-t ${base}/conf/MNI1.0_to_MNI_0.5_ants0GenericAffine.mat \
	-t ./t1_to_MNI_ants1Warp.nii.gz \
	-t ./t1_to_MNI_ants0GenericAffine.mat 
    
    # Get the hipp labels in the same space
    for side in l r;do 
	$ANTSPATH/antsApplyTransforms -d 3 \
	    --float 1 -v 1 -n NearestNeighbor \
	    -i  ${side}h.hippoSfLabels-T1.v10.nii.gz -o ${side}_hippSfLabelsT1_rotcrop.nii.gz \
	    -r ../../../conf/hrhipptemplate.nii.gz \
	    -t ../../../scripts/itk_rot_tr_crop.txt \
	    -t fs_T1_to_T1_biascorr0GenericAffine.mat \
	    -t ${hrhipp}/MNI1.0_to_MNI_0.5_ants0GenericAffine.mat \
	    -t ${hrhipp}/t1_to_MNI_ants1Warp.nii.gz \
	    -t ${hrhipp}/t1_to_MNI_ants0GenericAffine.mat 
    done
    #combine them to a single file
    fslmaths l_hippSfLabelsT1_rotcrop -add r_hippSfLabelsT1_rotcrop hippSfLabelsT1_rotcrop
done
# Hmm, nearest neighbor interp makes a bit of a mess of the labels. 
# Maybe I should be moving the T2 into the freesurfer space and running that through ANTS?
# Not that hard. Just need to flip some of the transforms
exit








# Convert the hip to T1 transform to ITK
    c3d_affine_tool -ref hrhipp/T1_biascorr.nii.gz \
	-src hrhipp/hip_algn_avg.nii.gz  \
	hrhipp/hip_to_t1.mat \
	-fsl2ras -oitk hrhipp/itk_hip_to_t1.txt
# now test it
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i hrhipp/hip_algn_avg.nii.gz  -o ants_hip_avg_to_t1_test.nii.gz \
	-r hrhipp/T1_biascorr.nii.gz \
	-t  hrhipp/itk_hip_to_t1.txt
# And it works. Good. So let's try to combine it with the warp to get it to standard space
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i hrhipp/hip_algn_avg.nii.gz  -o ants_hip_avg_to_MNI0.5_test.nii.gz \
	-r $FSLDIR/data/standard/MNI152_T1_0.5mm.nii.gz \
	-t hrhipp/MNI1.0_to_MNI_0.5_ants0GenericAffine.mat \
	-t hrhipp/t1_to_MNI_ants1Warp.nii.gz \
	-t hrhipp/t1_to_MNI_ants0GenericAffine.mat \
	-t hrhipp/itk_hip_to_t1.txt
# Not getting the right resolution here -- Must have did something wrong
# I think it might just ge a question of getting the order right



# Convert the rotcrop transform to ITK
    c3d_affine_tool -ref ../../conf/hrhipptemplate_rot_tr_crop.nii.gz \
	-src $FSLDIR/data/standard/MNI152_T1_0.5mm.nii.gz  \
	../../scripts/hrhipptemplate_rot_tr_crop.mat \
	-fsl2ras -oitk ../../scripts/itk_rot_tr_crop.txt
# Test
    $ANTSPATH/antsApplyTransforms -d 3 \
	--float 1 -v 1 \
	-i $FSLDIR/data/standard/MNI152_T1_0.5mm.nii.gz  -o ants_rotcrop_test.nii.gz \
	-r ../../conf/hrhipptemplate_rot_tr_crop.nii.gz \
	-t ../../scripts/itk_rot_tr_crop.txt
# Works!


#	-t ${outPrefix}1Warp.nii.gz \





   #Combine all of the transforms together


mri_convert -rt nearest -at mri_robust_reg_$i.lta \
    lh.hippoSfLabels-T1.v10_$i.nii.gz \
    lh.hippoSfLabels-T1.v10_to_T1_biascorr_$i.nii.gz
done



# See below for a log of failed attempts

applywarp --in=lh.hippoSfLabels-T1.v10.nii.gz \
    --premat=fs_T1_long_to_T1_biascorr.mat \
    --warp=hrhipp/t1_nl_mni_0.5mm_warp \
    --interp=nn \
    --ref=$base/conf/hrhipptemplate_rot_tr_crop \
    --postmat=$base/scripts/hrhipptemplate_rot_tr_crop.mat \
    --out=t1_hippSFLabels-T1.v10_mni_0.5mm_rotcrop
#fail
applywarp --in=lh.hippoSfLabels-T1.v10.nii.gz \
    --premat=fs_T1_long_to_T1_biascorr.mat \
    --warp=hrhipp/t1_nl_mni_0.5mm_warp \
    --interp=nn \
    --ref=$base/conf/MNI152_T1_0.5mm_brain \
    --out=test2
#fail
applywarp --in=lh.hippoSfLabels-T1.v10.nii.gz \
    --premat=fs_T1_long_to_T1_biascorr.mat \
    --interp=nn \
    --ref=hrhipp/T1_biascorr \
    --out=test3
#fail
align_epi_anat -epi fs_T1.nii.gz -anat hrhipp/T1_biascorr.nii.gz -epi_base 1
# Skull stripping -- gag. Need a more general tool

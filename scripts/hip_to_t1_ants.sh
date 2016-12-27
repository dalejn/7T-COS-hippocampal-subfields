
#!/bin/sh

export ANTSPATH=/data/adamt/build/antsbin/bin/


flirt -in hip_algn_avg -ref t2wb -usesqform \
    -nosearch -omat hip_avg_to_t2wb.mat -out hip_avg_to_t2wb&

$ANTSPATH/antsApplyTransforms -d 3 \
    --float 1 -v 1 \
    -i T1_biascorr.nii.gz  -o _to_l_fshipp.nii.gz \
    -r ../../scan0$lhipTarg/antsHrhipp/lh.hippoSfLabels-T1.v10.nii.gz \
    -t [fs_T1_to_T1_biascorr0GenericAffine.mat,1] \
    -t itk_hip_to_t1.txt& 




$ANTSPATH/antsApplyTransforms -d 3 \
    --float 1 -v 1 \
    -i $hrhipp/hip_algn_avg.nii.gz  -o hip_algn_avg_to_l_fshipp.nii.gz \
    -r ../../scan0$lhipTarg/antsHrhipp/lh.hippoSfLabels-T1.v10.nii.gz \
    -t [fs_T1_to_T1_biascorr0GenericAffine.mat,1] \
    -t itk_hip_to_t1.txt& 



$ANTSPATH/antsRegistration -d 3 \
    --float 1 -v 1 \
    -r [hip_algn_avg.nii.gz,T1_biascorr.nii.gz,1] \
    -t Rigid[0.1] \
    -m CC[hip_algn_avg.nii.gz,T1_biascorr.nii.gz,1,32,Regular,0.25] \
    -c [1000x500x250x100,1e-8,10] \
    -f 8x4x2x1 -s 4x2x1x0 \
    -o hipp_to_t1_ants
exit

$ANTSPATH/antsRegistration -d 3 \
    --float 1 -v 1 \
    --initial-moving-transform [T1_biascorr.nii.gz,hip_algn_avg.nii.gz,1] \
    -r [T1_biascorr.nii.gz,hip_algn_avg.nii.gz,1] \
    -t Rigid[0.1] \
    -m MI[T1_biascorr.nii.gz,hip_algn_avg.nii.gz,0.9,32,Regular,0.25] \
    -c [1] \
    -f 1 -s 1 \
    -o hipp_to_t1_ants_$RANDOM


$ANTSPATH/antsRegistration -d 3 \
    --float 1 -v 1 \
    --initial-moving-transform [T1_biascorr.nii.gz,hip_algn_avg.nii.gz,1] \
    -r [T1_biascorr.nii.gz,hip_algn_avg.nii.gz,1] \
    -t Rigid[0.1] \
    -m CC[T1_biascorr.nii.gz,hip_algn_avg.nii.gz,0.9,32,Regular,0.25] \
    -c [1000x500x250x100,1e-8,10] \
    -f 8x4x2x1 -s 4x2x1x0 \
    -o hipp_to_t1_ants_$RANDOM
#!/bin/bash

while read line
do
    mri_mask $line-t1.nii.gz $line-lab.nii.gz $line-t1-mask.nii.gz
    mri_mask $line-t2s-bfc.nii.gz $line-lab.nii.gz $line-t2s-bfc-mask.nii.gz
done<sub_full.txt
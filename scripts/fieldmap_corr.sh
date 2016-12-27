#!/bin/sh

set -e -x

magnitude=${1/.nii.gz} #mag1
phase=${2/.nii.gz} #mag
toBeCor=${3/.nii.gz/}
delta_te=1.02 
dwelltime=$4
# 0.0000651
# 0.00013208

## Stuart thought the "dwell" parameter needed for frequency
## unwrapping (analogous to echo spacing in EPI) in this case should
## be 1000/Bandwidth/Frequency encode steps, 
## which is 1000/30/512 = 0.0651 ms for the hippocampus
## or 1000/30/256 = 0.130208 for the whole brain

## I spoke with MJ who pointed out that dwell time should be passed to
## fugue in seconds, not milliseconds, thus it should be 0.0000651 or 0.00013208

# images_012_grefieldmapping1001
# images_013_grefieldmapping2001


if [ ! -e fieldmap.nii.gz ];then
    bet $magnitude ${magnitude}_brain -f 0.3
    fsl_prepare_fieldmap SIEMENS \
	$phase \
	${magnitude}_brain fieldmap $delta_te
fi

flirt \
    -in $1 \
    -ref $toBeCor \
    -omat fieldmap_to_$toBeCor.mat \
    -out mag1_to_$toBeCor -nosearch -usesqform

flirt -applyxfm -in fieldmap \
    -init fieldmap_to_$toBeCor.mat \
    -ref $toBeCor -out fieldmap_to_$toBeCor

fugue -i $toBeCor \
    --dwell=$dwelltime --loadfmap=fieldmap_to_$toBeCor -u ${toBeCor}_fugue

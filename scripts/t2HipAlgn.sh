#!/bin/sh
set -e -x

croparg=" 21 22 6      307 288 44"
hipstring="Hippocam"
t2wbstring="wholebrainTE30FA10"

# Assumptions:
# Subject ID is passed on the command line
# FreeSurfer is loaded and SUBJECTS_DIR is set

if [[ -z "${1// }" ]] || [ ! -e $base/$1 ]; then 
    echo "Help. something is wrong"; exit 1;fi
sub=$1
sd=$SUBJECTS_DIR
mkdir -p $sd/$sub/hipp
cd $sd/$sub/hipp

i=1
rm -f hip??.nii.gz dropped_hip??.nii.gz t2wb.nii.gz
for sess in ../nii;do
    j=1
    k=1
    for scan in $sess/image*${hipstring}*gz;do
	echo $scan
	oddScan=`echo $j % 2|bc`
	if [ $oddScan -eq 1 ]; then 
	    if grep $i$k drop.txt;then
		ln -sf $scan dropped_hip$i$k.nii.gz
	    else ln -sf $scan hip$i$k.nii.gz
	    fi
	    k=$((k+1))
	fi
	j=$((j+1))
    done
    i=$((i+1))
done

for sess in ../nii;do
    for scan in $sess/image*${t2wbstring}*gz;do
	ln -sf $scan t2wb.nii.gz
	break;
    done
done    

if [ -e target.txt ];then
    targ=`cat target.txt`
else targ=11
fi

imageList=""
for i in hip??.nii.gz;do 
    j=${i%%.nii.gz}
    imageList="$imageList ${j##hip}"
done

echo imageList $imageList
echo targ $targ

crop=true
align=true
rigid2=true
#warp=true

if [ $crop ];then
rm -f hip??_crop.nii.gz 
    for x in `imglob hip??.nii.gz`;do
# Does the small FOV make it harder to align?
#    fslroi $x ${x}_crop 100 240 130 200 20 50 0 1 &
#    fslroi $x ${x}_crop 80 290 150 280 5 50 0 1 &
    agtfslroi.sh  $croparg $x ${x}_crop &
    done
    wait
    fslmerge -t hip_raw_merg hip??_crop.nii.gz
fi

if [ $align ];then
    rm -f hip??_to_??.nii.gz 
    for x in $imageList;do
	inp=`imglob hip${x}_crop.nii.gz`
	out=hip${x}_to_${targ}
	flirt -in ${inp}  -out $out -omat ${out}.mat \
	    -ref hip${targ}_crop -nosearch -usesqform &
    done
    wait
    fslmerge -t hip_algn_merg hip??_to_${targ}.nii.gz 
#hip${targ}_crop.nii.gz 
    fslmaths hip_algn_merg -Tmean hip_algn_avg
fi

if [ $rigid2 ]; then
    rm -f hip_algn_merg hip??_to_avg.nii.gz
    for x in $imageList;do
	inp=`imglob hip${x}_crop.nii.gz`
	out=hip${x}_to_avg
	flirt -in ${inp}  -out $out -omat ${out}.mat \
	    -ref hip_algn_avg -nosearch -init hip${x}_to_${targ}.mat  &
    done
    wait
    fslmerge -t hip_algn_merg hip??_to_avg.nii.gz 
#hip${targ}_crop.nii.gz 
    fslmaths hip_algn_merg -Tmean hip_algn_avg
    fslmaths hip_algn_avg.nii.gz -mul 0 masktmp1
    fslmaths masktmp1.nii.gz -add 1 -roi 5 280 5 270 9 25 0 1 hipmask
    rm masktmp1.nii.gz
fi

if [ $warp ];then
    rm -f hip??_nl_??.nii.gz 
    for x in $imageList;do
        inp=`imglob hip${x}_crop.nii.gz`
	aff=hip${x}_to_${targ}.mat
        warp=hip${x}_to_${targ}_warp
        out=hip${x}_nl_${targ}
	jesper_fnirt_beta --in=${inp} --cout=$warp \
	    --ref=hip${targ}_crop --aff=$aff -v --config=T1_2_T1_test6.cnf 
	applywarp --ref=hip22_crop --interp=spline --in=$inp --warp=$warp \
	    --out=$out
    done
    wait
    fslmerge -t hip_fnirt_merg hip??_nl_${targ}.nii.gz 
#hip${targ}_crop.nii.gz
fi


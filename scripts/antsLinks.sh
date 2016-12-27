
set -e -x
base=/data/Hippo_hr/cpb/
sd=$SUBJECTS_DIR
wd=$base/ants1/lhipp3_batch
cd $wd/

for x in d7??; do 
    if [ -e $base/$x/hipp/lhipp_t2s.nii.gz ];then
	echo $x;fi
done > $wd/subs.txt

for x in `cat subs.txt`;do 
    ln -sf $base/$x/hipp/lhipp_t2s.nii.gz ${x}-t2s.nii.gz
    ln -sf $base/$x/hipp/lhipp_t2s.nii.gz ${x}-t1.nii.gz
    ln -sf $base/$x/hipp/lh.hippoSfLabels-T1.v10.nii.gz ${x}-lab.nii.gz
done



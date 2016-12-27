pushd ~/proj/hippo_hr/moa

for x in md???; do 
    if [ -e $x/ants_ss/hrhipptemplate0.nii.gz ];then 
	echo $x;fi
done > ws_ants1/subs.txt

popd
for x in `cat subs.txt`;do 
    ln -sf ../$x/ants_ss/hrhipptemplate0.nii.gz ${x}-0.nii.gz
    ln -sf ../$x/ants_ss/hrhipptemplate1.nii.gz ${x}-1.nii.gz
done

rm md102*gz md114*gz md116*gz md124*gz md126*gz md131*gz 

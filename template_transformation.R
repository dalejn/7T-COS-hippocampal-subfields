library(ANTsR)

#apparently needs to be in type char, not list
#to add another transformation, call translist[2]<- "filepath"
translist <- "/spin1/users/zhoud4/ants_scripts/lhd711-lab300GenericAffine.mat"
fi <- antsImageRead("/spin1/users/zhoud4/ants_scripts/lhtemplate0.nii.gz")
mi <- antsImageRead("/spin1/users/zhoud4/ants_scripts/d711-lab.nii.gz")

img_rigid_only <- antsApplyTransforms( 
  fixed=fi,  
  moving=mi,
  transformlist=translist,
)

antsImageWrite(img_rigid_only,"/spin1/users/zhoud4/ants_scripts/lhd711-lab30WarpedToTemplate.nii.gz")

# antsApplyTransforms(
#   list(
#   d=3,  
#   i="/spin1/users/zhoud4/ants_scripts/d711-lab.nii.gz",
#   o="/spin1/users/zhoud4/ants_scripts/lhd711-lab30WarpedToTemplate.nii.gz",
#   r="/spin1/users/zhoud4/ants_scripts/lhtemplate0.nii.gz",
#   t="/spin1/users/zhoud4/ants_scripts/lhd711-lab300GenericAffine.mat"
# ))
# 
# antsApplyTransforms("/spin1/users/zhoud4/ants_scripts/lhtemplate0.nii.gz","/spin1/users/zhoud4/ants_scripts/d711-lab.nii.gz","/spin1/users/zhoud4/ants_scripts/lhd711-lab300GenericAffine.mat")
# 
# antsApplyTransforms("-d","3","--float","-i","/spin1/users/zhoud4/ants_scripts/d711-lab.nii.gz","-o","/spin1/users/zhoud4/ants_scripts/lhd711-lab30WarpedToTemplate.nii.gz","-r","/spin1/users/zhoud4/ants_scripts/lhtemplate0.nii.gz","-t","/spin1/users/zhoud4/ants_scripts/lhd711-lab300GenericAffine.mat")


# -d 3 
# --float 1 
# --verbose 1 
# -i d711-lab.nii.gz 
# -o ./lhtemplate0d711-lab30WarpedToTemplate.nii.gz 
# -r lhtemplate0.nii.gz 
# -t ./lhd711-lab301Warp.nii.gz 
# -t ./lhd711-lab300GenericAffine.mat
# 
# /data/adamt/build/antsbinApr2016/bin//antsApplyTransforms 
# -d 3 
# --float 1 
# --verbose 1 
# -i d711-t1.nii.gz -o ./lhtemplate1d711-t131WarpedToTemplate.nii.gz 
# -r lhtemplate1.nii.gz 
# -t ./lhd711-lab301Warp.nii.gz 
# -t ./lhd711-lab300GenericAffine.mat
# 
# /data/adamt/build/antsbinApr2016/bin//antsApplyTransforms 
# -d 3 
# --float 1 
# --verbose 1 
# -i d711-t2s.nii.gz 
# -o ./lhtemplate2d711-t2s32WarpedToTemplate.nii.gz 
# -r lhtemplate2.nii.gz 
# -t ./lhd711-lab301Warp.nii.gz 
# -t ./lhd711-lab300GenericAffine.mat
library(ANTsR)

# lhtemplate0 <- antsImageRead("/spin1/users/zhoud4/ants_scripts/lhtemplate0.nii.gz")
# lhtemplate1 <- antsImageRead("/spin1/users/zhoud4/ants_scripts/lhtemplate1.nii.gz")
# lhtemplate2 <- antsImageRead("/spin1/users/zhoud4/ants_scripts/lhtemplate2.nii.gz")
# d711_lab <- antsImageRead("/spin1/users/zhoud4/ants_scripts/d711-lab.nii.gz")
# d711_t1 <- antsImageRead("/spin1/users/zhoud4/ants_scripts/d711-t1.nii.gz")
# d711_t2s <- antsImageRead("/spin1/users/zhoud4/ants_scripts/d711-t2s.nii.gz")

setwd("~/data/ants_scripts/")


antsRegistration(
  list(
    d = 3,
    f = 1,
    v = 1,
    u = 1, 
    w = "[0.01,0.99]", 
    z = 1,
    r = "[lhtemplate0.nii.gz, d711-lab.nii.gz, 1]",
    ## problem with loading d711-lab.nii.gz
    ##  "file  d711-lab.nii.gz does not exist"
    ##  can't run -r because it dpeends on this MI being loaded
    
  t = "Rigid[0.1]",
      m = "mi[lhtemplate0.nii.gz, d711-lab.nii.gz, 1, 32, Regular, 0.25]",
      m = "mi[lhtemplate1.nii.gz, d711-t1.nii.gz, 1, 32, Regular, 0.25]",
      m = "mi[lhtemplate2.nii.gz, d711-t2s.nii.gz, 1, 32, Regular, 0.25]",
          c = "[1000x500x250x0,1e-6,10]",
          f = "6x4x2x1",
          s = "4x3x2x1x0",

  t = "affine[0.1]",
      m = "mi[lhtemplate0.nii.gz, d711-lab.nii.gz, 1, 32, Regular, 0.25]",
      m = "mi[lhtemplate1.nii.gz, d711-t1.nii.gz, 1, 32, Regular, 0.25]",
      m = "mi[lhtemplate2.nii.gz, d711-t2s.nii.gz, 1, 32, Regular, 0.25]",
          c = "[1000x500x250x0,1e-6,10]",
          f = "6x4x2x1",
          s = "4x2x1x0", 

  t = "SyN[0.1,3,0]",
    m =  "CC[lhtemplate0.nii.gz, d711-lab.nii.gz, 1 ,4]",
    m = "CC[lhtemplate1.nii.gz, d711-t1.nii.gz, 1, 4]",
    m = "CC[lhtemplate2.nii.gz, d711-t2s.nii.gz, 1, 4]",
        c = "[100x100x70x20,1e-9,10]", 
        f = "6x4x2x1", 
        s = "3x2x1x0",
  o = "./lhd711-lab30"
  )
)

# 
# /data/adamt/build/antsbinApr2016/bin//antsApplyTransforms 
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

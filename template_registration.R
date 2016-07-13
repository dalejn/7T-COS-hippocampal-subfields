library(ANTsR)

antsRegistration(
  list(
    d = 3,
    float = 1,
    v = 1,
    u = 1, 
    w = "[0.01,0.99]", 
    z = 1,
    r = "[/spin1/users/zhoud4/ants_scripts/lhtemplate0.nii.gz,/spin1/users/zhoud4/ants_scripts/d711-lab.nii.gz,1]",
    
  t = "Rigid[0.1]",
      m = "mi[/spin1/users/zhoud4/ants_scripts/lhtemplate0.nii.gz,/spin1/users/zhoud4/ants_scripts/d711-lab.nii.gz, 1, 32,Regular, 0.25]",
      m = "mi[/spin1/users/zhoud4/ants_scripts/lhtemplate1.nii.gz,/spin1/users/zhoud4/ants_scripts/d711-t1.nii.gz, 1, 32,Regular, 0.25]",
      m = "mi[/spin1/users/zhoud4/ants_scripts/lhtemplate2.nii.gz,/spin1/users/zhoud4/ants_scripts/d711-t2s.nii.gz, 1, 32,Regular, 0.25]",
          c = "[1000x500x250x0,1e-6,10]",
          f = "6x4x2x1",
          s = "4x2x1x0",

#   t = "affine[0.1]",
#       m = "mi[lhtemplate0.nii.gz, d711-lab.nii.gz, 1, 32, Regular, 0.25]",
#       m = "mi[lhtemplate1.nii.gz, d711-t1.nii.gz, 1, 32, Regular, 0.25]",
#       m = "mi[lhtemplate2.nii.gz, d711-t2s.nii.gz, 1, 32, Regular, 0.25]",
#           c = "[1000x500x250x0,1e-6,10]",
#           f = "6x4x2x1",
#           s = "4x2x1x0", 
# 
#   t = "SyN[0.1,3,0]",
#     m =  "CC[lhtemplate0.nii.gz, d711-lab.nii.gz, 1 ,4]",
#     m = "CC[lhtemplate1.nii.gz, d711-t1.nii.gz, 1, 4]",
#     m = "CC[lhtemplate2.nii.gz, d711-t2s.nii.gz, 1, 4]",
#         c = "[100x100x70x20,1e-9,10]", 
#         f = "6x4x2x1", 
#         s = "3x2x1x0",
  o = "lhd711-lab30"
  )
)

library(ANTsR)

#set whatever paths you want
path_to_dz <- "/spin1/users/zhoud4/ants_scripts/"
path_to_cpb <- "/home/zhoud4/cpb/ants1/lhipp3_batch/"

#read list of subject IDs to pass through loop
sub_list <- as.matrix(read.table("/spin1/users/zhoud4/ants_scripts/sub_full.txt"))

#for each subject...
for (i in sub_list) {
  #set transformation matrix
  translist <- paste(path_to_dz,"lh",i, "-30-pass2-0GenericAffine.mat",sep="")
  #read template as antsImage class
  fi <- antsImageRead(paste(path_to_dz,"lhtemplate0_rigidtransform.nii.gz",sep=""))
      
      #read moving image modalities (e.g. label, T1 weighted, T2* weighted)
      #as antsImage class, then apply the transform
      mi <- antsImageRead(paste(path_to_cpb,i,"-lab.nii.gz",sep=""))
          lab_rigid_only <- antsApplyTransforms( 
          fixed=fi,  
          moving=mi,
          transformlist=translist
        )

  fi <- antsImageRead(paste(path_to_dz,"lhtemplate1_rigidtransform.nii.gz",sep=""))
      mi <- antsImageRead(paste(path_to_cpb,i,"-t1.nii.gz",sep="")) 
          t1_rigid_only <- antsApplyTransforms( 
            fixed=fi,  
            moving=mi,
            transformlist=translist
          )
  
  fi <- antsImageRead(paste(path_to_dz,"lhtemplate2_rigidtransform.nii.gz",sep=""))      
      mi <- antsImageRead(paste(path_to_cpb,i,"-t2s.nii.gz",sep=""))
          t2s_rigid_only <- antsApplyTransforms( 
            fixed=fi,  
            moving=mi,
            transformlist=translist
          )
  
  #write warped image as .nii.gz
  antsImageWrite(lab_rigid_only,paste(path_to_dz,"lh",i,"-lab-pass2-30WarpedToTemplate.nii.gz",sep=""))
  antsImageWrite(t1_rigid_only,paste(path_to_dz,"lh",i,"-t1-pass2-30WarpedToTemplate.nii.gz",sep=""))
  antsImageWrite(t2s_rigid_only,paste(path_to_dz,"lh",i,"-t2s-pass2-30WarpedToTemplate.nii.gz",sep=""))
  print(paste(i,"done"))
}
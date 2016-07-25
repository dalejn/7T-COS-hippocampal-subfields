library(ANTsR)

#set whatever paths you want
path_to_dz <- "/spin1/users/zhoud4/ants_scripts/"
path_to_cpb <- "/home/zhoud4/cpb/ants1/lhipp3_batch/"

#read list of subject IDs to pass through loop
sub_list <- as.matrix(read.table("sub_full.txt"))

#REGISTRATION for each subject__________________________________________________________________
print("DOING REGISTRATION")
start.time.registration <- Sys.time()
for (i in sub_list) {  
  #set path for each modality (e.g. label, T1 weighted, T2* weighted)
  m1=paste("MeanSquares[",path_to_dz,"lhtemplate0.nii.gz,",path_to_cpb,i,"-lab.nii.gz,0.1]",sep="")
  m2=paste("mi[",path_to_dz,"lhtemplate1.nii.gz,",path_to_cpb,i,"-t1.nii.gz,0.9,32,Regular,0.25]",sep="")
  m3=paste("mi[",path_to_dz,"lhtemplate2.nii.gz,",path_to_cpb,i,"-t2s.nii.gz,0.9,32,Regular,0.25]",sep="")
  
  #set output path and file pre-fix
  output=paste(path_to_dz,"lh",i,"-30-pass1-",sep="")
  
  antsRegistration(
    list(
      d = 3, #3 dimentions
      float = 1, #as opposed to double-point
      v = 1, #verbose for more info
      u = 1, #use histogram matching
      w = "[0.01,0.99]", #winsorize image intensities; upper,lower quantile
      z = 1, #collapse output transforms to combine all adjacent transforms where possible
      r = paste("[",path_to_dz,"lhtemplate0.nii.gz,",path_to_cpb,i,"-lab.nii.gz,1]",sep=""),
      #initial moving transform based on geometric center of the image intensities, which gets 
      #immediately incorporated into the composite transform the last transform specified on 
      #the command line is the first to be applied
      
      t = "Rigid[0.1]", #rigid transformation with 0.1 gradient step
      m = m1, #label images
      m = m2, #T1 images
      m = m3, #T2* images
      c = "[1000x500x250x0,1e-6,10]", #determines slope of normalized energy profile for the
      #last N iterations and compares to convergence threshold
      f = "6x4x2x1", #shrink factors at each level
      s = "4x2x1x0", #gaussian smoothing sigmas at each level
      
      o = output
    )
  )
}

end.time.registration<- Sys.time()

#APPLY TRANSFORMS for each subject__________________________________________________________________
start.time.applytransforms<- Sys.time()
print("APPLYING TRANSFORMS")
for (i in sub_list) {
  #set transformation matrix
  translist <- paste(path_to_dz,"lh",i, "-30-pass1-0GenericAffine.mat",sep="")
  #read template as antsImage class
  fi <- antsImageRead(paste(path_to_dz,"lhtemplate0.nii.gz",sep=""))
  
  #read moving image modalities (e.g. label, T1 weighted, T2* weighted)
  #as antsImage class, then apply the transform
  mi <- antsImageRead(paste(path_to_cpb,i,"-lab.nii.gz",sep=""))
  lab_rigid_only <- antsApplyTransforms( 
    fixed=fi,  
    moving=mi,
    transformlist=translist
  )
  
  fi <- antsImageRead(paste(path_to_dz,"lhtemplate1.nii.gz",sep=""))
  mi <- antsImageRead(paste(path_to_cpb,i,"-t1.nii.gz",sep="")) 
  t1_rigid_only <- antsApplyTransforms( 
    fixed=fi,  
    moving=mi,
    transformlist=translist
  )
  
  fi <- antsImageRead(paste(path_to_dz,"lhtemplate2.nii.gz",sep=""))      
  mi <- antsImageRead(paste(path_to_cpb,i,"-t2s.nii.gz",sep=""))
  t2s_rigid_only <- antsApplyTransforms( 
    fixed=fi,  
    moving=mi,
    transformlist=translist
  )
  
  #write warped image as .nii.gz
  antsImageWrite(lab_rigid_only,paste(path_to_dz,"lh",i,"-lab-pass1-30WarpedToTemplate.nii.gz",sep=""))
  antsImageWrite(t1_rigid_only,paste(path_to_dz,"lh",i,"-t1-pass1-30WarpedToTemplate.nii.gz",sep=""))
  antsImageWrite(t2s_rigid_only,paste(path_to_dz,"lh",i,"-t2s-pass1-30WarpedToTemplate.nii.gz",sep=""))
  print(paste(i,"done"))
}
end.time.applytransforms <- Sys.time()

#AVERAGE TRANSFORMED IMAGES __________________________________________________________________
start.time.average <- Sys.time()
print("AVERAGING TRANSFORMED IMAGES")

#read list of transformed images for each modality for all subjects
lab_list <- as.matrix(Sys.glob(paste(path_to_dz,"lh*-lab-pass1-30WarpedToTemplate.nii.gz",sep="")))
t1_list <- as.matrix(Sys.glob(paste(path_to_dz,"lh*-t1-pass1-30WarpedToTemplate.nii.gz",sep="")))
t2s_list <- as.matrix(Sys.glob(paste(path_to_dz,"lh*-t2s-pass1-30WarpedToTemplate.nii.gz",sep="")))

#read all images for each modality as antsImage class and assign variable name
for (n in 1:nrow(lab_list)) {
  nam <- paste("lab_image",n,sep="") 
  assign(nam,antsImageRead(lab_list[n]))
  print(nam)
}

for (n in 1:nrow(t1_list)) {
  nam <- paste("t1_image",n,sep="") 
  assign(nam,antsImageRead(t1_list[n]))
  print(nam)
}

for (n in 1:nrow(t2s_list)) {
  nam <- paste("t2s_image",n,sep="") 
  assign(nam,antsImageRead(t2s_list[n]))
  print(nam)
}

#create list of all antsImage class objects; is there a better way to do this???
lab_image_list <- list(lab_image1  ,   lab_image10 ,   lab_image11 ,   lab_image12  ,  lab_image13   , lab_image14    ,lab_image15 ,   lab_image16  ,  lab_image17  ,  lab_image18 ,  
                       lab_image19  ,  lab_image2   ,  lab_image20 ,  lab_image21   , lab_image22  ,  lab_image23   , lab_image24  ,  lab_image25  ,  lab_image26 ,   lab_image27 ,  
                       lab_image28   , lab_image29 ,   lab_image3  ,   lab_image4   ,  lab_image5  ,   lab_image6   ,  lab_image7  ,   lab_image8  ,   lab_image9)

t1_image_list <- list(t1_image1  ,   t1_image10 ,   t1_image11 ,   t1_image12  ,  t1_image13   , t1_image14    ,t1_image15 ,   t1_image16  ,  t1_image17  ,  t1_image18 ,  
                      t1_image19  ,  t1_image2   ,  t1_image20 ,  t1_image21   , t1_image22  ,  t1_image23   , t1_image24  ,  t1_image25  ,  t1_image26 ,   t1_image27 ,  
                      t1_image28   , t1_image29 ,   t1_image3  ,   t1_image4   ,  t1_image5  ,   t1_image6   ,  t1_image7  ,   t1_image8  ,   t1_image9)

t2s_image_list <- list(t2s_image1  ,   t2s_image10 ,   t2s_image11 ,   t2s_image12  ,  t2s_image13   , t2s_image14    ,t2s_image15 ,   t2s_image16  ,  t2s_image17  ,  t2s_image18 ,  
                       t2s_image19  ,  t2s_image2   ,  t2s_image20 ,  t2s_image21   , t2s_image22  ,  t2s_image23   , t2s_image24  ,  t2s_image25  ,  t2s_image26 ,   t2s_image27 ,  
                       t2s_image28   , t2s_image29 ,   t2s_image3  ,   t2s_image4   ,  t2s_image5  ,   t2s_image6   ,  t2s_image7  ,   t2s_image8  ,   t2s_image9)

#get average of each image for each modality, then write the average as .nii.gz file
antsImageWrite(antsAverageImages(lab_image_list),"lhtemplate0_rigidtransform_pass1.nii.gz")
print("lhtemplate0_rigidtransform_pass1.nii.gz")
antsImageWrite(antsAverageImages(t1_image_list),"lhtemplate1_rigidtransform_pass1.nii.gz")
print("lhtemplate1_rigidtransform_pass1.nii.gz")
antsImageWrite(antsAverageImages(t2s_image_list),"lhtemplate2_rigidtransform_pass1.nii.gz")
print("lhtemplate2_rigidtransform_pass1.nii.gz")
end.time.average <- Sys.time()

# paste("Registration elapsed time:",end.time.registration-start.time.registration)
paste("Apply transforms elapsed time:",end.time.applytransforms-start.time.applytransforms)
paste("Average transformed images elapsed time:",end.time.average-start.time.average)
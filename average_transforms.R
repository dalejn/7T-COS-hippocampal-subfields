library(ANTsR)

#set whatever paths you want
path_to_dz <- "/spin1/users/zhoud4/ants_scripts/"
path_to_cpb <- "/home/zhoud4/cpb/ants1/lhipp3_batch/"

#read list of subject IDs to pass through loop
sub_list <- as.matrix(read.table("sub_full.txt"))

#read list of transformed images for each modality for all subjects
    lab_list <- as.matrix(Sys.glob(paste(path_to_dz,"lh*-lab-30WarpedToTemplate.nii.gz",sep="")))
    t1_list <- as.matrix(Sys.glob(paste(path_to_dz,"lh*-t1-30WarpedToTemplate.nii.gz",sep="")))
    t2s_list <- as.matrix(Sys.glob(paste(path_to_dz,"lh*-t2s-30WarpedToTemplate.nii.gz",sep="")))

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
antsImageWrite(antsAverageImages(lab_image_list),"lhtemplate0_rigidtransform.nii.gz")
  print("lhtemplate0_rigidtransform.nii.gz")
antsImageWrite(antsAverageImages(t1_image_list),"lhtemplate1_rigidtransform.nii.gz")
  print("lhtemplate1_rigidtransform.nii.gz")
antsImageWrite(antsAverageImages(t2s_image_list),"lhtemplate2_rigidtransform.nii.gz")
  print("lhtemplate2_rigidtransform.nii.gz")
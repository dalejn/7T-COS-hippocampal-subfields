library(ANTsR)
library(rslurm)

#set whatever paths you want
path_to_dz <- "/spin1/users/zhoud4/ants_scripts/"
path_to_cpb <- "/home/zhoud4/cpb/ants1/lhipp3_batch/"

#read list of subject IDs to pass through loop
sub_list <- as.matrix(read.table("sub_full.txt"))

for (j in 1:3) {

#for each subject...
for (i in sub_list) {  
  #set path for each modality (e.g. label, T1 weighted, T2* weighted)
  m1=paste("mi[",path_to_dz,"lhtemplate0.nii.gz,",path_to_cpb,i,"-lab.nii.gz, 1, 32,Regular, 0.25]",sep="")
  m2=paste("mi[",path_to_dz,"lhtemplate1.nii.gz,",path_to_cpb,i,"-t1-mask.nii.gz, 1, 32,Regular, 0.25]",sep="")
  m3=paste("mi[",path_to_dz,"lhtemplate2.nii.gz,",path_to_cpb,i,"-t2s-bfc-mask.nii.gz, 1, 32,Regular, 0.25]",sep="")
  
  #set output path and file prefix
  output=paste(path_to_dz,"/test1/lh",i,"-30-pass",j,"-TEST",sep="")
  
pars =data.frame(list(
        d = 3, #3 dimentions
        float = 1, #as opposed to double-point
        v = 1, #verbose for more info
        u = 1, #use histogram matching
        w = "[0.01,0.99]", #winsorize image intensities; upper,lower quantile
        z = 1, #collapse output transforms to combine all adjacent transforms where possible
        r = paste("[",path_to_cpb,"lhtemplate0.nii.gz,",path_to_cpb,i,"-lab.nii.gz,1]",sep=""),
        #initial moving transform based on geometric center of the image intensities, which gets 
        #immediately incorporated into the composite transform the last transform specified on 
        #the command line is the first to be applied
        
        t = "Rigid[0.1]", #rigid transformation with 0.1 gradient step
        m = m1, #moving images for each modality
        m = m2,
        m = m3,
        c = "[1000x500x250x0,1e-6,10]", #determines slope of normalized energy profile for the
        #last N iterations and compares to convergence threshold
        f = "6x4x2x1", #shrink factors at each level
        s = "4x2x1x0", #gaussian smoothing sigmas at each level  
        o = output
      ))
sjob=slurm_apply(antsRegistration, pars,jobname="AntsRegT", nodes = 1, cpus_per_node = 2)
}}
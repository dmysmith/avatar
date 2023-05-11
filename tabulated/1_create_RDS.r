################################

# Create RDS file for surface area / ADHD analysis 
# Diana Smith
# Created May 2023

################################
# load packages

library(tidyverse)
library(psych)
library(plyr)
library(dplyr)
library(PerformanceAnalytics)
library(pracma)

################################
# Define paths

# tabulated ABCD data 
inpath <- '/space/syn65/1/data/abcd-sync/4.0/tabulated/released'

# genetic PCs subject data
pcfile <- '/space/syn65/1/data/abcd-sync/5.0/genomics/ABCD_20220428.updated.nodups.curated_pcair.tsv'

# path to the output RDS file 
outpath <- '/space/syn50/1/data/ABCD/d9smith/avatar/tabulated'
fname <- 'nda4.0_offrel.RDS'
outmatfile <- paste0(outpath, '/', fname)

# cmig_utils/r directory
funcpath <- '/home/d9smith/github/cmig_tools_internal/cmig_tools_utils/r'

# The functionmakeDEAPdemos.R requires the path to the directory which 
# contains the tabulated ABCD data defined explicitly here
# deappath <- inpath

# file names for instruments of interest
prsfile <- '/space/syn50/1/data/ABCD/d9smith/PRScs/Results/global_total_surface_area.profile'
ancestryfile <- 'acspsw03.txt'
physfile <- 'abcd_ant01.txt'
img_tabfile1 <- 'abcd_smrip10201.txt'
MRIinfofile <- 'abcd_mri01.txt'
imgincfile <- 'abcd_imgincl01.txt'
cbclsfile <- 'abcd_cbcls01.txt'

# full paths to these files 
physfile <- paste0(inpath, '/', physfile)
img_tabfile1 <- paste0(inpath, '/', img_tabfile1)
imgincfile <- paste0(inpath, '/', imgincfile)
MRIinfofile <- paste0(inpath, '/', MRIinfofile)
cbclsfile <- paste0(inpath, '/', cbclsfile)
ancestryfile <- paste0(inpath, '/', ancestryfile)

################################

# source load.txt and makeDEAPdemos.R 
source(paste0(funcpath, '/', 'loadtxt.R'))
source(paste0(funcpath, '/', 'makeDEAPdemos.R'))
source('/home/d9smith/github/cmig_library/create_mentalhealth_vars.R')

deappath <- inpath

################################
# Load the physical health instrument file  
phys <- loadtxt(physfile)
# Extract the variables of interest
physvar <- c('src_subject_id', 'eventname', 'interview_age', 'sex')
timepoints <- c('baseline_year_1_arm_1','2_year_follow_up_y_arm_1')
phys <- phys[phys$eventname %in% timepoints,physvar]
# Write to a dataframe 
outmat <- phys

################################
# Create the SES variables as coded by DEAP
deap <- makeDEAPdemos(deappath)
deap <- deap[ , -which(names(deap) %in% c("sex", "interview_date", "interview_age"))]
# Combine with the previously extracted variables
outmat <- join(outmat, deap, by=c('src_subject_id', 'eventname'))

################################
# Load the genetic PCs file (this does not require loadtxt.R!) 
pc_mat <- read.delim(pcfile)
# Get just the first 10 PCs and write to a dataframe  
pc <- data.frame(pc_mat[,c('X',paste0("C",1:10))])
names(pc) <- c('src_subject_id',paste0("PC",1:10))
# Combine with the physical health variables. 
outmat <- join(outmat, pc, by='src_subject_id', match = "all")

################################
# Load the MRI info instrument  and extract the device serial number and software version 
# variables which are always needed as covariates when using imaging data  
MRIinfo <- loadtxt(MRIinfofile)
MRIinfo <- MRIinfo[,c('src_subject_id','eventname', grep('mri_info', names(MRIinfo), value=TRUE))]
MRIinfo[,'idevent'] <- paste0(MRIinfo$src_subject_id, '_', MRIinfo$eventname)
MRIinfo <- MRIinfo[duplicated(MRIinfo$idevent)==FALSE,]
MRIinfo[which(MRIinfo$mri_info_deviceserialnumber==""),]<-NA
lvl <- unique(MRIinfo$mri_info_deviceserialnumber)
lvl <- lvl[is.na(lvl)==FALSE]
MRIinfo$mri_info_deviceserialnumber<-factor(MRIinfo$mri_info_deviceserialnumber, levels=lvl)
MRIinfo[which(MRIinfo$mri_info_softwareversion==""),]<-NA
lvl <- unique(MRIinfo$mri_info_softwareversion)
lvl <- lvl[is.na(lvl)==FALSE]
MRIinfo$mri_info_softwareversion<-factor(MRIinfo$mri_info_softwareversion, levels=lvl)
MRIinfo <- select(MRIinfo,  -c('idevent'))
# Combine with the previously extracted variables
outmat <- join(outmat, MRIinfo, by=c('src_subject_id', 'eventname'))

# ################################
# # Create the SES variables as coded by DEAP
# deap <- makeDEAPdemos(deappath)
# deap <- deap[ , -which(names(deap) %in% c("sex", "interview_date", "interview_age"))]
# # Combine with the previously extracted variables
# outmat <- join(outmat, deap, by=c('src_subject_id', 'eventname'))

################################
# If you wish to work with the morphological imaging varibles (surface area, 
# cortical thickness, Jacobians etc) it is advisable to include the global 
# measures for these variable as covariates. 

# Load imaging data files from tabulated data 
img_tab1 <- loadtxt(img_tabfile1)
# Extract intracranial volume  mean thickness and surface area  
img_tabvar1 <-c('src_subject_id', 'eventname', 'smri_thick_cdk_mean', 'smri_area_cdk_total', 'smri_vol_scs_intracranialv')
img_tab1 <- img_tab1[, img_tabvar1]
# Combine with the previously extracted variables
outmat <- join(outmat, img_tab1, by=c('src_subject_id', 'eventname'))

################################
# Include the MRI QC include/exclude variable 
imginc <- loadtxt(imgincfile)
# Exctract the include/exclude variable for all imaging modalities 
imgincvar <- c('src_subject_id', 'eventname', grep('include', names(imginc), value=TRUE))
imginc <- imginc[, imgincvar]
# Combine with the previously extracted variables
outmat <- join(outmat, imginc, by=c('src_subject_id', 'eventname'))

################################
# Load KSADS file
cbcls <- loadtxt(cbclsfile)

# extract vars of interest
cbclsvars <- c('src_subject_id', 'eventname', 'cbcl_scr_dsm5_adhd_r')
cbcls = cbcls[,cbclsvars]

# merge with outmat
outmat <- join(outmat, cbcls, by=c('src_subject_id', 'eventname'))

################################
# Load PRS file
prs <- read.table(prsfile, header=TRUE, col.names=c("FID", "src_subject_id", "PHENO", "CNT", "CNT2", "areaprs"))

# normalize PRS
prs$areaprs_norm <- scale(prs$areaprs)

# extract variables of interest
prsvars <- c('src_subject_id', 'areaprs_norm')
prs = prs[,prsvars]

# merge with outmat
outmat <- join(outmat, prs, by='src_subject_id', match = "all")

################################
# Load ancestry information
ancestry <- loadtxt(ancestryfile)

# keep only baseline info
ancestry <- ancestry[ancestry$eventname=='baseline_year_1_arm_1',]

# define vars of interest
ancestryvars <- c('src_subject_id', 'genetic_af_european')
ancestry <- ancestry[,ancestryvars]

# merge with outmat
outmat <- join(outmat, ancestry, by='src_subject_id', match = "all")

################################
# Save the "outmat" as an RDS 

if ( ! dir.exists(outpath) ) {
        dir.create(outpath, recursive=TRUE)
}


saveRDS(outmat, file=outmatfile)

################################
# Save adhd scores (DV) in separate file 
outcomes <- "cbcl_scr_dsm5_adhd_r"
outcomefile <- outmat[,c("src_subject_id","eventname",outcomes)]
write.table(outcomefile, file=paste0(outpath, '/', 'outcomes.txt'), sep = "\t", row.names = FALSE)
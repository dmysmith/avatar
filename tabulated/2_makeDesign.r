################################

# Create design matrix for surface area / ADHD analysis 
# Diana Smith
# Created May 2023

###############################################################
# path to makeDesign function 
source('/home/d9smith/github/cmig_tools_internal/cmig_tools_utils/r/makeDesign.R')

###############################################################
# Load the data from mini RDS file
ndafile <- '/space/syn50/1/data/ABCD/d9smith/avatar/tabulated/nda4.0_offrel.RDS'
nda <- readRDS(ndafile)

# Define the path to the directory where you would like to save out your design matrix 
outpath <- '/space/syn50/1/data/ABCD/d9smith/avatar/tabulated/designMat'

# only include subjects which pass QC
# idx_dmri_inc <- which(nda$imgincl_dmri_include==1)
# nda_dmri_inc <- nda[idx_dmri_inc,]

idx_t1w_inc <- which(nda$imgincl_t1w_include==1)
nda_t1w_inc <- nda[idx_t1w_inc,]

# only include EUR > 0.8
idx_eur <- which(nda_t1w_inc$genetic_af_european>=0.8)
nda_t1w_eur <- nda_t1w_inc[idx_eur,]



###############################################################
# Design Matrix 1 - t1w_eur sample, age + sex + scanner + software + PCs

# Define the name of your design matrix file 
fname <- 'designMat01_t1w_eur_AgeSexScanSoftPCs.txt'
# and it's full path to your fave output directory
outfile <- paste0(outpath, '/', fname) 

# makeDesign encodes continuous and categorical variables differently, therefore they are 
# specified using different flags. Continuous variables are added using the "contvar" flag. 
# Here we include age and the genetic PCs as continuous variables.
contvar <- c('interview_age', paste0("PC",1:10))

# Categorical variables are dummy coded and added using the "catvar" flag. makeDesign automatically
# includes an intercept. For each categorical variable one category is defined as the reference category 
# and that column is dropped. makeDesign also checks whether your matrix is rank deficient and if so
# will automatically drop further categories to avoid this. Here we include sex, scanner info and 
# SES demographics as categorical.
catvar <- c('sex', 'mri_info_deviceserialnumber', 'mri_info_softwareversion')

# The time points for which we wish to extract data are specified. You do not have to specify multiple 
# time points, however if you do, specify them in chronoligical order ( this will be important for 
# longitudinal modelling)
time <- c('baseline_year_1_arm_1', '2_year_follow_up_y_arm_1') # order matters! start with baseline!

# You can specify whether you wish to demean your continuous variables or not. the default is set to 
# demean=TRUE. Other flags include "delta" for longitudinal modelling, "interact" to include interactions, 
# "subjs" if you wish to filter by subject and "quadratic" if you wish to include a quadratic term 
# (more details on these in the following sections). The defaults to these are set to null. 

# Now run makeDesign! 
makeDesign(nda_t1w_eur, outfile, time, contvar=contvar, catvar=catvar, delta=NULL, interact=NULL, subjs=NULL, demean=TRUE, quadratic=NULL)

###############################################################
# Design Matrix 2 - t1w_eur sample, age + sex + scanner + software + PCs + global surface area

# Define the name of your design matrix file 
fname <- 'designMat02_t1w_eur_AgeSexScanSoftPCsArea.txt'
# and it's full path to your fave output directory
outfile <- paste0(outpath, '/', fname) 

# makeDesign encodes continuous and categorical variables differently, therefore they are 
# specified using different flags. Continuous variables are added using the "contvar" flag. 
# Here we include age and the genetic PCs as continuous variables.
contvar <- c('interview_age', paste0("PC",1:10), 'smri_area_cdk_total')

# Categorical variables are dummy coded and added using the "catvar" flag. makeDesign automatically
# includes an intercept. For each categorical variable one category is defined as the reference category 
# and that column is dropped. makeDesign also checks whether your matrix is rank deficient and if so
# will automatically drop further categories to avoid this. Here we include sex, scanner info and 
# SES demographics as categorical.
catvar <- c('sex', 'mri_info_deviceserialnumber', 'mri_info_softwareversion')

# The time points for which we wish to extract data are specified. You do not have to specify multiple 
# time points, however if you do, specify them in chronoligical order ( this will be important for 
# longitudinal modelling)
time <- c('baseline_year_1_arm_1', '2_year_follow_up_y_arm_1') # order matters! start with baseline!

# You can specify whether you wish to demean your continuous variables or not. the default is set to 
# demean=TRUE. Other flags include "delta" for longitudinal modelling, "interact" to include interactions, 
# "subjs" if you wish to filter by subject and "quadratic" if you wish to include a quadratic term 
# (more details on these in the following sections). The defaults to these are set to null. 

# Now run makeDesign! 
makeDesign(nda_t1w_eur, outfile, time, contvar=contvar, catvar=catvar, delta=NULL, interact=NULL, subjs=NULL, demean=TRUE, quadratic=NULL)

###############################################################
# Design Matrix 3 - t1w_eur sample, age + sex + scanner + software + PCs + area PRS

# Define the name of your design matrix file 
fname <- 'designMat03_t1w_eur_AgeSexScanSoftPCsAreaprsnorm.txt'
# and it's full path to your fave output directory
outfile <- paste0(outpath, '/', fname) 

# makeDesign encodes continuous and categorical variables differently, therefore they are 
# specified using different flags. Continuous variables are added using the "contvar" flag. 
# Here we include age and the genetic PCs as continuous variables.
contvar <- c('interview_age', paste0("PC",1:10), 'areaprs_norm')

# Categorical variables are dummy coded and added using the "catvar" flag. makeDesign automatically
# includes an intercept. For each categorical variable one category is defined as the reference category 
# and that column is dropped. makeDesign also checks whether your matrix is rank deficient and if so
# will automatically drop further categories to avoid this. Here we include sex, scanner info and 
# SES demographics as categorical.
catvar <- c('sex', 'mri_info_deviceserialnumber', 'mri_info_softwareversion')

# The time points for which we wish to extract data are specified. You do not have to specify multiple 
# time points, however if you do, specify them in chronoligical order ( this will be important for 
# longitudinal modelling)
time <- c('baseline_year_1_arm_1', '2_year_follow_up_y_arm_1') # order matters! start with baseline!

# You can specify whether you wish to demean your continuous variables or not. the default is set to 
# demean=TRUE. Other flags include "delta" for longitudinal modelling, "interact" to include interactions, 
# "subjs" if you wish to filter by subject and "quadratic" if you wish to include a quadratic term 
# (more details on these in the following sections). The defaults to these are set to null. 

# Now run makeDesign! 
makeDesign(nda_t1w_eur, outfile, time, contvar=contvar, catvar=catvar, delta=NULL, interact=NULL, subjs=NULL, demean=TRUE, quadratic=NULL)

###############################################################
# Design Matrix 4 - t1w_eur sample, age + sex + scanner + software + PCs + area PRS

# Define the name of your design matrix file 
fname <- 'designMat04_t1w_eur_AgeSexScanSoftPCsAreaAreaprsnorm.txt'
# and it's full path to your fave output directory
outfile <- paste0(outpath, '/', fname) 

# makeDesign encodes continuous and categorical variables differently, therefore they are 
# specified using different flags. Continuous variables are added using the "contvar" flag. 
# Here we include age and the genetic PCs as continuous variables.
contvar <- c('interview_age', paste0("PC",1:10), 'smri_area_cdk_total', 'areaprs_norm')

# Categorical variables are dummy coded and added using the "catvar" flag. makeDesign automatically
# includes an intercept. For each categorical variable one category is defined as the reference category 
# and that column is dropped. makeDesign also checks whether your matrix is rank deficient and if so
# will automatically drop further categories to avoid this. Here we include sex, scanner info and 
# SES demographics as categorical.
catvar <- c('sex', 'mri_info_deviceserialnumber', 'mri_info_softwareversion')

# The time points for which we wish to extract data are specified. You do not have to specify multiple 
# time points, however if you do, specify them in chronoligical order ( this will be important for 
# longitudinal modelling)
time <- c('baseline_year_1_arm_1', '2_year_follow_up_y_arm_1') # order matters! start with baseline!

# You can specify whether you wish to demean your continuous variables or not. the default is set to 
# demean=TRUE. Other flags include "delta" for longitudinal modelling, "interact" to include interactions, 
# "subjs" if you wish to filter by subject and "quadratic" if you wish to include a quadratic term 
# (more details on these in the following sections). The defaults to these are set to null. 

# Now run makeDesign! 
makeDesign(nda_t1w_eur, outfile, time, contvar=contvar, catvar=catvar, delta=NULL, interact=NULL, subjs=NULL, demean=TRUE, quadratic=NULL)

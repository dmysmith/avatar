%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run FEMA for surface area / ADHD analysis 
%% Diana Smith
%% Created May 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify where to store results
outpath = '/space/syn50/1/data/ABCD/d9smith/avatar/tabulated/results_2023-05-10';

if ~exist(outpath, 'dir')
      mkdir(outpath)
end

% start diary
diary_path=strcat(outpath,'/','diary_', datestr(now, 'yyyy-mm-dd_HHMM'));
diary(diary_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD ALL ABCD CMIG tools directories to MATLAB path:
addpath(genpath('/home/d9smith/github/cmig_tools_internal'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify data release

dataRelease = '4.0'; %'3.0' or '4.0'

% run abcdConfig
cfg = abcdConfig('FEMA');
abcd_sync_path=cfg.data.abcd_sync;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INPUTS TO FEMA_wrapper.m

dirname_tabulated = fullfile(abcd_sync_path,dataRelease,'tabulated/released'); % directory to tabulated imaging data on abcd-sync 
atlasVersion = 'ABCD2_cor10';
dirname_tabulated = fullfile(abcd_sync_path,'4.0','tabulated/released'); %KNOWN ISSUE: breaks when using txt files following NDA release --> must use pre-release csv files
fname_pihat = fullfile('/space/syn65/1/data/abcd-sync/4.0/genomics/ABCD_rel4.0_grm.mat'); 

%To run multiple design matrices with same imaging data populate each row with path to each design matrix
designmat_dir = '/space/syn50/1/data/ABCD/d9smith/avatar/tabulated/designMat';
designmat_file = dir(sprintf('%s/designMat*.txt', designmat_dir));
designmat_file = {designmat_file.name}';
fname_design = strcat(designmat_dir, '/', designmat_file);

% if only running one design mat at a time
% fname_design = '/space/syn50/1/data/ABCD/d9smith/random_effects/designMat/designMat02_t1w_AgeSexScanSoft.txt';
% designmat_file = 'designMat02_t1w_AgeSexScanSoft.txt';

outdir_file = strrep(designmat_file, '.txt', '');
outdir_path=strcat(outpath,'/',outdir_file);

% for running just one designmat
% fname_design = '/space/syn50/1/data/ABCD/d9smith/random_effects/designMat/designMat11_dmri_AgeSexScanSoftGest.txt';
% outdir_path = '/space/syn50/1/data/ABCD/d9smith/random_effects/results_2023-02-07/designMat11_dmri_AgeSexScanSoftGest.txt';

datatype='external'; % imaging modality selected
dirname_imaging = '/space/syn50/1/data/ABCD/d9smith/avatar/tabulated/outcomes.txt'; % filepath to imaging data

% Optional inputs for `FEMA_wrapper.m` depending on analysis
contrasts=[]; % Contrasts relate to columns in design matrix e.g. [1 -1] will take the difference between cols 1 and 2 in your design matrix (X)
ranknorm = 0; % Rank normalizes dependent variables (Y) (default = 0)
nperms = 0; % Number of permutations - if wanting to use resampling methods nperms>0
mediation = 0; % If wanting to use outputs for a mediation analysis set mediation=1 - ensures same resampling scheme used for each model in fname_design
PermType = 'wildbootstrap'; %Default resampling method is null wild-bootstrap - to run mediation analysis need to use non-null wild-bootstrap ('wildboostrap-nn')
tfce = 0; % If wanting to run threshold free cluster enhancement (TFCE) set tfce=1 (default = 0)
RandomEstType = 'ML'; % specify random effects estimator (default is MoM)
Hessflag=0;
logLikflag=1;
ciflag=0;

RandomEffects = {'F','A','S','E'}; 

colsinterest=[1]; % Only used if nperms>0. Indicates which IVs (columns of X) the permuted null distribution and TFCE statistics will be saved for (default 1, i.e. column 1)
niter=0; % decrease number of iterations -- change when you want to run for real!

% fname_pregnancyID = fullfile('/home/sabad/requests/pregnancy_ID_01172023.csv');

dirname_out = outdir_path; % specify where to store results

fstem_imaging = 'adhd';

for i=1:length(fname_design)
      % RUN FEMA
      [fpaths_out beta_hat beta_se zmat logpmat sig2tvec sig2mat beta_hat_perm beta_se_perm zmat_perm sig2tvec_perm sig2mat_perm inputs mask tfce_perm colnames_interest save_params logLikvec Hessmat] = FEMA_wrapper(fstem_imaging, fname_design{i}, dirname_out{i}, dirname_tabulated, dirname_imaging, datatype,...
      'ranknorm', ranknorm, 'contrasts', contrasts, 'RandomEffects', RandomEffects, 'pihat_file', fname_pihat, 'nperms', nperms, 'mediation',mediation,'PermType',PermType,'tfce',tfce,'colsinterest',colsinterest,...
      'Hessflag',Hessflag,'ciflag',ciflag,'logLikflag',logLikflag,'RandomEstType',RandomEstType);

      save(fpaths_out{:}, 'logLikvec', '-append');
      save(fpaths_out{:}, 'RandomEffects', '-append');
end

diary off
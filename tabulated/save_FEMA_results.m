%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save FEMA results for surface area / ADHD analysis 
%% Diana Smith
%% Created May 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify where results were stored
outpath = '/space/syn50/1/data/ABCD/d9smith/avatar/tabulated/results_2023-05-10';
RandomEffects = {'F','A','S','E'};

designmat_file = dir(sprintf('%s/designMat*', outpath));
designmat_file = {designmat_file.name}';
results_dir = strcat(outpath, '/', designmat_file);

model = []; varname = []; beta_hat = []; beta_se = []; logpmat = []; zmat = [];
all_betas = table(model, varname, beta_hat, beta_se, logpmat, zmat);

iid = []; eid = [];
all_ids = table(model, iid, eid);

random_effect = []; est = [];
all_random_effects = table(model, random_effect, est);

for i=1:length(results_dir)
    
    load(strcat(results_dir{i}, '/', 'FEMA_wrapper_output_external_adhd.mat'));

    varname = string(colnames_model)';
    model = string(repmat(designmat_file{i}, size(varname)));
    betas = table(model, varname, beta_hat, beta_se, logpmat, zmat);
    all_betas = vertcat(all_betas, betas);

    iid = string(iid);
    eid = string(eid);
    model = string(repmat(designmat_file{i}, size(iid)));
    ids = table(model, iid, eid);
    all_ids = vertcat(all_ids, ids); 

    random_effect = [string(RandomEffects) 'sig2tvec' 'logLikvec']';
    est = [sig2mat; sig2tvec; logLikvec];
    model = string(repmat(designmat_file{i}, size(random_effect)));
    random_effects = table(model, random_effect, est);
    all_random_effects = vertcat(all_random_effects, random_effects);  
end

cd(outpath);
writetable(all_betas);
writetable(all_ids);
writetable(all_random_effects);
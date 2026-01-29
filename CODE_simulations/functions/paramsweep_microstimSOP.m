function paramsweep_microstimSOP(model, exp_path, model_sweep, expparams, thresholds_to_sweep)
%PARAMSWEEP run a sweep for specified model, experiment, and parameter set.
%   model (string): Specifies which model function to run (sop, anccr,
%               microstimulus)
%   exp_path (string): Identifies this parameter sweep run, will be name
%               of directory for saved data
%   model_sweep (struct): Specifies an array of inputs for each parameter
%               to be explored in sweep.

addpath('configs')
addpath('functions')

split_name = split(exp_path, '/');
exp_name = cell2mat(split_name(end));

% get parameter defaults for specified model
if strcmp(model, 'sop')
    baseparams = defaultsopparams;
    model_func = @(a,b,c,d,e) sop_scaling(a,b,c,d,e);
elseif strcmp(model, 'anccr')
    baseparams = defaultanccrparams;
    model_func = @(a,b,c,d,e) anccr_scaling(a,b,c,d,e);
elseif strcmp(model, 'microstimulus')
    baseparams = defaultmicrostimparams;
    model_func = @(a,b,c,d,e) microstim_scaling(a,b,c,d,e);

end
nthresholds = length(thresholds_to_sweep);
% generate configs for all specified parameter combinations
[comb_mat, comb_config, sweep_metadata] = sweepcombinations_microstimSOP(model_sweep, baseparams, thresholds_to_sweep);

[n_models, ~] = size(comb_mat);
nITI = length(expparams.ITIs);
nIter = 20;
trials_to_threshold_allmodels = nan(n_models*nthresholds, nITI, nIter);
for i = 1:n_models
    % loop through all model configs, simulate on task
    model_params = cell2mat(comb_config(i));
    model_id = [model, sprintf('%d', i)];
    % run ITI scaling experiment on specified model
    trials_to_thresh_ix = (i-1)*nthresholds+1;
    trials_to_threshold_allmodels(trials_to_thresh_ix:i*nthresholds, :, :) = model_func(model_params, ...
        exp_path, expparams, model_id, thresholds_to_sweep);
    % save copy of variables in workspace, in case of crash
    %save([exp_path,'/', model,'_bookmark_sweep.mat'],'-v7.3'); 
end

% save final results of sweep, trials to learn and metadata
save([exp_path,'/', exp_name, '_summarydata.mat' ], ...
    "sweep_metadata", "trials_to_threshold_allmodels",'-v7.3') 
end
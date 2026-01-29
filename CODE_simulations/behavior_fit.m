% behaviorfit.m
% author: annie taylor
% description: loads trials to learn data from experimental behavior, loads
%              trials to learn estimates from parameter sweeps for each 
%              candidate model, calculates the REVISE for each candidate model, identifies the best
%              models and makes statistical comparisons to behavioral data,
%              calculates the AIC for each model and plots summary results
%

%% imports, etc. 
clearvars; clc; 
close all;
rng(2); % just to get the same random seeds 
addpath('functions')
addpath('plotting')
addpath('configs')
addpath('functions')
addpath('models')
plot = true;  % to plot, change flag to true

%% load behavior data
load('./behavior_trials_to_learn.mat')
behavior = behavior_trials_to_learn_mat;
behavior_data = {ITI_30, ITI_60, ITI_300, ITI_600, ITI_3600};

%% load data from sweeps
clip_trials_to_learn_at_behavior_nums = 1;
%dir_root = 'E:/models_in_paper/';
dir_root = '../DATA_simulation_outputs/';
exp_names = {'microstimulus_sweep', 'sop_sweep', 'anccr_sweep', 'microstimulus_scaling_sweep'};
% Get a list of all files and folders in the main directory
contents = dir(dir_root);

% Filter out only the directories wiht '_sweep" in name (remove '.' and '..' entries)
directories = contents([contents.isdir] & ~ismember({contents.name}, {'.', '..'}) & ismember({contents.name}, exp_names)); %contains({contents.name}, "_sweep") );

% Initialize a cell array to store the paths of the "_sweep" folders
sweepFolders = cell(1, numel(directories));

% Iterate through each directory and check if it ends with "_sweep"
for j = 1:length(exp_names)
    expname = exp_names{j};
    dir_current = fullfile(dir_root,  expname);
    full_file_path = fullfile(dir_current, [expname '_summarydata.mat']);
    if exist(full_file_path, 'file')
        sweepdata.(sprintf(expname)) = load(full_file_path);
    end
end

%%

%load parameter sweep summary data for each sweep run

anccr_sweep_obj = sweepdata.anccr_sweep;
%constrain SOP to where pd1>pd2
sop_sweep_obj = sweepdata.sop_sweep;
sop_unconstrained_obj = sweepdata.sop_sweep;
labelRow = sop_sweep_obj.sweep_metadata(1, :);
dataRows = sop_sweep_obj.sweep_metadata(2:end, :);
pd1us_col = cell2mat(dataRows(:, 4));
pd2us_col = cell2mat(dataRows(:, 5));
pd1cs_col = cell2mat(dataRows(:, 6));
pd2cs_col = cell2mat(dataRows(:, 7));
mask1 = pd1us_col <= pd2us_col;
mask2 = pd1cs_col <= pd2cs_col;
mask = mask1 | mask2;
dataRows(mask, :) = [];
sop_sweep_obj.trials_to_threshold_allmodels(mask, :, :) =[];
sop_sweep_obj.sweep_metadata = [labelRow;dataRows];

microstim_obj = sweepdata.microstimulus_sweep;
microstim_scaling_obj = sweepdata.microstimulus_scaling_sweep;

%get trials to learn from sweep object
anccr_TTL = anccr_sweep_obj.trials_to_threshold_allmodels;
anccr_TTL_mean = mean(anccr_TTL, 3);
sop_TTL = sop_sweep_obj.trials_to_threshold_allmodels;
sop_TTL_mean = mean(sop_TTL, 3);
sop_unconstrained_TTL = sop_unconstrained_obj.trials_to_threshold_allmodels;
sop_unconstrained_TTL_mean = mean(sop_unconstrained_TTL,3);
microstim_scaling_TTL = microstim_scaling_obj.trials_to_threshold_allmodels;
microstim_scaling_TTL_mean = mean(microstim_scaling_TTL, 3);
if clip_trials_to_learn_at_behavior_nums == 1
    summary_file_name = "";
    thresholds_to_clip = [800, 400, 88, 48, 16];
    microstim_trials_to_threshold_raw = microstim_obj.trials_to_threshold_allmodels;
    for i = 1:length(thresholds_to_clip)
        trials_2d = squeeze(microstim_trials_to_threshold_raw(:,i,:));
        [row, col] = find(trials_2d >thresholds_to_clip(i));
        microstim_trials_to_threshold_raw(row, i, col) = NaN;

    end
    microstim_TTL = microstim_trials_to_threshold_raw;
else
    microstim_TTL = microstim_obj.trials_to_threshold_allmodels;
    summary_file_name = "400trialsPerSessionMicrostim";
end
microstim_TTL_mean = mean(microstim_TTL, 3);


%% calculate rss
models_to_exclude = 0; %if want to fit without longer ITI simulations
anccr_rss = calculate_rss(behavior(:,1:end-models_to_exclude), anccr_TTL_mean(:, 1:end-models_to_exclude));
sop_rss = calculate_rss(behavior(:, 1:end-models_to_exclude), sop_TTL_mean(:, 1:end-models_to_exclude));
sop_unconstrained_rss = calculate_rss(behavior(:, 1:end-models_to_exclude), sop_unconstrained_TTL_mean(:, 1:end-models_to_exclude));
microstim_rss = calculate_rss(behavior(:, 1:end-models_to_exclude), microstim_TTL_mean(:, 1:end-models_to_exclude));
microstim_scaling_rss = calculate_rss(behavior(:, 1:1:end-models_to_exclude), microstim_scaling_TTL_mean(:, 1:end-models_to_exclude));

%% sort results
% sort errors and return corresponding indices (to next sort models)
[anccr_rss_reordered, anccr_rss_reordered_idx] = sort(anccr_rss);
[sop_rss_reordered, sop_rss_reordered_idx] = sort(sop_rss);
[sop_unconstrained_rss_reordered, sop_unconstrained_rss_reordered_idx] = sort(sop_unconstrained_rss);
[microstim_rss_reordered, microstim_rss_reordered_idx] = sort(microstim_rss);
[microstim_rss_scaling_reordered, microstim_rss_scaling_reordered_idx] = sort(microstim_scaling_rss);

% sort metadata for each model, using sorted idxs
anccr_metadata_reordered = anccr_sweep_obj.sweep_metadata(anccr_rss_reordered_idx+1, 2:end);
sop_metadata_reordered = sop_sweep_obj.sweep_metadata(sop_rss_reordered_idx+1, 2:end);
sop_unconstrained_metadata_reordered = sop_unconstrained_obj.sweep_metadata(sop_unconstrained_rss_reordered_idx+1, 2:end);
microstim_metadata_reordered = microstim_obj.sweep_metadata(microstim_rss_reordered_idx+1, 2:end);
microstim_scaling_metadata_reordered = microstim_scaling_obj.sweep_metadata(microstim_rss_scaling_reordered_idx+1, 2:end);

% sort trials to learn for each model, using sorted idxs
anccr_TTL_reordered = anccr_TTL(anccr_rss_reordered_idx,:,:);
sop_TTL_reordered = sop_TTL(sop_rss_reordered_idx,:,:);
sop_unconstrained_TTL_reordered = sop_unconstrained_TTL(sop_unconstrained_rss_reordered_idx,:,:);
microstim_TTL_reordered = microstim_TTL(microstim_rss_reordered_idx,:,:);
microstim_scaling_TTL_reordered = microstim_scaling_TTL(microstim_rss_scaling_reordered_idx,:,:);


% isolate best candidate
anccr_best_fit_TTL = squeeze(anccr_TTL_reordered(1,:,:));
anccr_best_fit_TTL_mean = mean(anccr_TTL_reordered(1,:,:), 3);
% anccr_best_fit_TTL_idx_model_array = anccr_sweep_obj.sweep_metadata(anccr_rss_reordered_idx(1),2);
% anccr_best_fit_model_num = anccr_best_fit_TTL_idx_model_array{1}(1)
anccr_best_fit_model_idx = anccr_rss_reordered_idx(1)

sop_best_fit_TTL = squeeze(sop_TTL_reordered(1,:,:));
sop_best_fit_TTL_mean = mean(sop_TTL_reordered(1,:,:), 3);
sop_best_fit_TTL_idx_model_array = sop_sweep_obj.sweep_metadata(sop_rss_reordered_idx(1),2);
sop_best_fit_model_num = sop_best_fit_TTL_idx_model_array{1}(1)
sop_best_fit_metadata_idx = sop_rss_reordered_idx(1)

sop_unconstrained_best_fit_TTL = squeeze(sop_unconstrained_TTL_reordered(1,:,:));
sop_unconstrained_best_fit_TTL_mean = mean(sop_unconstrained_TTL_reordered(1,:,:), 3);
sop_unconstrained_best_fit_TTL_idx_model_array = sop_unconstrained_obj.sweep_metadata(sop_unconstrained_rss_reordered_idx(1),2);
sop_unconstrained_best_fit_model_num = sop_unconstrained_best_fit_TTL_idx_model_array{1}(1)
sop_unconstrained_best_fit_metadata_idx = sop_unconstrained_rss_reordered_idx(1)

microstim_best_fit_TTL = squeeze(microstim_TTL_reordered(1,:,:));
microstim_best_fit_TTL_mean = mean(microstim_TTL_reordered(1,:,:),3);
microstim_best_fit_TTL_idx_model_array = microstim_obj.sweep_metadata(microstim_rss_reordered_idx(1),2);
microstim_best_fit_model_num = microstim_best_fit_TTL_idx_model_array{1}(1)
microstim_best_fit_metadata_idx = microstim_rss_reordered_idx(1)

microstim_scaling_best_fit_TTL = squeeze(microstim_scaling_TTL_reordered(1,:,:));
microstim_scaling_best_fit_TTL_mean = mean(microstim_scaling_TTL_reordered(1,:,:),3);
microstim_scaling_best_fit_TTL_idx_model_array = microstim_scaling_obj.sweep_metadata(microstim_rss_scaling_reordered_idx(1),2);
microstim_scaling_best_fit_model_num = microstim_scaling_best_fit_TTL_idx_model_array{1}(1)
microstim_scaling_best_fit_metadata_idx = microstim_rss_scaling_reordered_idx(1)
%% calculate cAIC for best candidate model
n = 20; % number of iterations
k = [5, 12, 8, 8];  % number of parameters for each model (listed below)
k_same = [0 0 0 0];
% k=5 for anccr -> w, k, a0, dt, threshold
% k=12 for sop -> dt, r1, r2, L_plus, L_minus, p1_cs, pd1_cs pd2_cs, p1_us,
% pd1_us, pd2_us, threshold
% k=8 for microstimulus -> statesize, k, gamma, sigma, nmicrostimuli, d, threshold
% k=8 for microstimulus with alpha scaling -> statesize, alpha, gamma, sigma, nmicrostimuli, 
% d, threshold

% aic for total # params
[AIC_anccr_total, AIC_anccr_corrected_total] = calculate_aic(behavior, anccr_best_fit_TTL_mean, k(1));
[AIC_sop_total, AIC_SOP_corrected_total] = calculate_aic(behavior, sop_best_fit_TTL_mean, k(2));
[AIC_microstim_total, AIC_microstim_corrected_total] = calculate_aic(behavior, microstim_best_fit_TTL_mean, k(3));
[AIC_microstim_scaling_total, AIC_microstim_scaling_corrected_total] = calculate_aic(behavior, microstim_scaling_best_fit_TTL_mean, k(4));
[AIC_sop_unconstrained_total, AIC_sop_unconstrained_corrected_total] = calculate_aic(behavior, sop_unconstrained_best_fit_TTL_mean, k(2));

% aic using rss alone (k=0)
[AIC_anccr_0, AIC_anccr_corrected_0] = calculate_aic(behavior, anccr_best_fit_TTL_mean, k_same(1));
[AIC_sop_0, AIC_sop_corrected_0] = calculate_aic(behavior, sop_best_fit_TTL_mean, k_same(2));
[AIC_microstim_0, AIC_microstim_corrected_0] = calculate_aic(behavior, microstim_best_fit_TTL_mean, k_same(3));
[AIC_microstim_scaling_0, AIC_microstim_scaling_corrected_0] = calculate_aic(behavior, microstim_scaling_best_fit_TTL_mean, k_same(4));
[AIC_sop_unconstrained_0, AIC_sop_unconstrained_corrected_0] = calculate_aic(behavior, sop_unconstrained_best_fit_TTL_mean, k_same(2));
% 
%Using all params
aic_best_model_total = min([AIC_anccr_total, AIC_microstim_total, AIC_sop_total, AIC_microstim_scaling_total, AIC_sop_unconstrained_total]);
rel_likelihood_anccr = exp(-0.5*(AIC_anccr_total-aic_best_model_total));
rel_likelihood_microstim = exp(-0.5*(AIC_microstim_total-aic_best_model_total));
rel_likelihood_microstimscaled = exp(-0.5*(AIC_microstim_scaling_total-aic_best_model_total));
rel_likelihood_sop = exp(-0.5*(AIC_sop_total-aic_best_model_total));
rel_likelihood_sop_unconstrained = exp(-0.5*(AIC_sop_unconstrained_total-aic_best_model_total));


%using no params
aic_best_model_0 = min([AIC_anccr_0, AIC_microstim_scaling_0, AIC_sop_0, AIC_sop_unconstrained_0])
rel_likelihood_anccr_0 = exp(-0.5*(AIC_anccr_0-aic_best_model_0))
rel_likelihood_microstim_0 = exp(-0.5*(AIC_microstim_0-aic_best_model_0))
rel_likelihood_microstimscaled_0 = exp(-0.5*(AIC_microstim_scaling_0-aic_best_model_0))
rel_likelihood_sop_0 = exp(-0.5*(AIC_sop_0-aic_best_model_0))
rel_likelihood_sop_unconstrained_0 = exp(-0.5*(AIC_sop_unconstrained_0-aic_best_model_0))

% %using no params_corrected AIC (slightly different AIC calculation, not used here, see 'calculate_AIC' function)

% aic_best_model_0_corrected = min([AIC_anccr_corrected_0, AIC_microstim_corrected_0, AIC_microstim_scaling_corrected_0, AIC_sop_corrected_0, AIC_sop_unconstrained_corrected_0]);
% rel_likelihood_anccr_0_corrected = exp(-0.5*(AIC_anccr_corrected_0-aic_best_model_0_corrected));
% rel_likelihood_microstim_0_corrected = exp(-0.5*(AIC_microstim_corrected_0 -aic_best_model_0_corrected));
% rel_likelihood_microstimscaled_0_corrected = exp(-0.5*(AIC_microstim_scaling_corrected_0-aic_best_model_0_corrected));
% rel_likelihood_sop_0_corrected = exp(-0.5*(AIC_sop_corrected_0-aic_best_model_0_corrected));
% rel_likelihood_sop__unconstrained_0_corrected = exp(-0.5*(AIC_sop_unconstrained_corrected_0-aic_best_model_0_corrected));

% save
filename = "../data_simulation_outputs/behavior_fit_summary_files/modelfit_summarydata_bestfit" +summary_file_name+".mat";
save(filename, 'AIC_anccr_total', 'AIC_sop_total', 'AIC_sop_unconstrained_total',  'AIC_microstim_total',  ...
    'AIC_microstim_scaling_total',    'AIC_anccr_0', 'AIC_sop_0',  'AIC_sop_unconstrained_0', 'AIC_microstim_0', ...
    'AIC_microstim_scaling_0', 'microstim_scaling_best_fit_TTL', 'anccr_best_fit_TTL', 'sop_best_fit_TTL', ...
    'sop_unconstrained_best_fit_TTL', 'microstim_best_fit_TTL', 'anccr_best_fit_model_idx', 'sop_best_fit_metadata_idx', ...
    'sop_best_fit_model_num', 'sop_unconstrained_best_fit_metadata_idx', 'sop_unconstrained_best_fit_model_num', ...
    'microstim_best_fit_metadata_idx', 'microstim_best_fit_model_num', 'microstim_scaling_best_fit_metadata_idx', ...
    'microstim_scaling_best_fit_model_num', 'anccr_metadata_reordered', 'anccr_TTL_reordered', 'anccr_TTL', 'anccr_rss_reordered',...
    'sop_metadata_reordered', 'sop_TTL_reordered', 'sop_TTL', 'sop_rss_reordered', 'sop_unconstrained_metadata_reordered', ...
    'sop_unconstrained_TTL_reordered', 'sop_unconstrained_TTL', 'sop_unconstrained_rss_reordered','microstim_metadata_reordered',... 
    'microstim_TTL_reordered', 'microstim_TTL', 'microstim_rss_reordered', 'microstim_scaling_metadata_reordered', ...
    'microstim_scaling_TTL_reordered', 'microstim_scaling_TTL', 'microstim_rss_scaling_reordered', 'rel_likelihood_anccr_0', ...
    'rel_likelihood_microstim_0', 'rel_likelihood_microstimscaled_0', 'rel_likelihood_sop_0', 'rel_likelihood_sop_unconstrained_0')

%% plot results
if plot
    clr = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],...
        [0.4940 0.1840 0.5560], [0 0.4470 0.7410]};
    xticklabel = {'30s','60s','300s','600s','3600s'};
    fHandle = figure('PaperUnits','Centimeters','Paperposition',[2 2 3.5 4]); hold on;
    n_models = 4;
    nIter = 20;
    for iITI = 1:length(xticklabel)
            bar(iITI,[mean(cell2mat(behavior_data(iITI)),"omitnan")'; ...
                mean(anccr_best_fit_TTL(iITI,:),2,"omitnan")'; ...
                mean(sop_best_fit_TTL(iITI,:),2,"omitnan")'; ...
                mean(microstim_best_fit_TTL(iITI,:),2,"omitnan")';...
                mean(microstim_scaling_best_fit_TTL(iITI,:),2,"omitnan")'], ...
                0.8,'FaceColor',clr{iITI},'EdgeColor','none','FaceAlpha',0.3);
            scatter(rand(length(cell2mat(behavior_data(iITI))),1)*0.1+iITI-0.365, ...
                (cell2mat(behavior_data(iITI))),2,clr{iITI},'filled')
            scatter(rand(nIter,1)*0.1+iITI-.175,anccr_best_fit_TTL(iITI,:),2,clr{iITI}, ...
                'filled')
            scatter(rand(nIter,1)*0.1+iITI-0.0375,sop_best_fit_TTL(iITI,:),2,clr{iITI}, ...
                'filled')
            scatter(rand(nIter,1)*0.1+iITI+0.125,microstim_best_fit_TTL(iITI,:),2, ...
                clr{iITI},'filled')
            scatter(rand(nIter,1)*0.1+iITI+0.25,microstim_scaling_best_fit_TTL(iITI,:),2, ...
                clr{iITI},'filled')
            errorbar([iITI-0.275,iITI-.0875,iITI+0.0875,iITI+0.275], ...
                [mean(cell2mat(behavior_data(iITI)),"omitnan"), ...
                mean(anccr_best_fit_TTL(iITI,:),2,"omitnan"), ...
                mean(sop_best_fit_TTL(iITI,:),2,"omitnan"), ...
                mean(microstim_best_fit_TTL(iITI,:),2,"omitnan")], ...
                [std(cell2mat(behavior_data(iITI)),1), ...
                std(anccr_best_fit_TTL(iITI,:),1), std(sop_best_fit_TTL(iITI,:),1), ...
                std(microstim_best_fit_TTL(iITI,:),1)],'k', ...
                'CapSize',0,"LineStyle","none")
    end
    
    set(gca,'XLim',[0.5 5.5],'YLim',[0 300],'YTick',[0, 10, 50, 100, 200, 300], ...
        'XTick',[1,2,3,4,5],'XTickLabel',xticklabel,'XTickLabelRotation',45, ...
        'Box','off','TickDir','out','FontSize',8, 'YTickLabel', ...
        {'0','10','50','100','200','300'})
    ylabel({'';'trials to learn'})
    print(fHandle,'-depsc','change_trial_comparisons.ai')
    %print(fHandle,'-depsc','change_trial_comparisons.tif')
    %print(fHandle,'-depsc','change_trial_comparisons.jpg')
end


clearvars; clc; 
close all;
addpath('functions')
addpath('models')
addpath('configs')

%% inputs for sweep
% model name
model = 'sop';
exp_path = '../DATA_simulation_outputs/sop_sweep' %directory to save each model output

% Define the parameters and values to search over
model_sweep = struct; 
%model_sweep.threshold = [0.01, 0.1, 0.3, 0.5, 0.7, 0.9];
model_sweep.pd1_us = [0.01, 0.1, 0.25, 0.5, 0.75];
model_sweep.pd2_us = [0.0001, 0.001, 0.01, 0.1];
model_sweep.pd1_cs = [0.01, 0.1, 0.25, 0.5, 0.75];
model_sweep.pd2_cs = [0.0001, 0.001, 0.01, 0.1];  % decay term from A2 to I for CS


thresholds_to_sweep = [0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];

% experiment settings
expparams = defaultexpparams;
expparams.trialpersession = [100, 50, 11, 6, 2];
%expparams.trialpersession = [100, 50, 50, 50, 50];
paramsweep_microstimSOP(model, exp_path, model_sweep, expparams, thresholds_to_sweep)

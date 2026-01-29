clearvars; clc; 
close all;
addpath('functions')
addpath('models')
addpath('configs')

%% inputs for sweep
% model name
model = 'microstimulus';
exp_path = '../DATA_simulation_outputs/microstimulus_scaling_sweep_extraTrials'
% Define the parameters and values to search over
model_sweep = struct;
model_sweep.k = [3.0e-4];
model_sweep.gamma = [0.99];
model_sweep.nmicrostimuli = [3];
model_sweep.d = [0.9]; 

thresholds_to_sweep = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];

% experiment settings
expparams = defaultexpparams;
expparams.trialpersession = [300, 300, 300, 300, 300];
paramsweep_microstimSOP(model, exp_path, model_sweep, expparams, thresholds_to_sweep)

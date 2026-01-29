clearvars; clc; 
close all;
addpath('functions')
addpath('models')
addpath('configs')

%% inputs for sweep
% model name
model = 'anccr';
exp_path = '../DATA_simulation_outputs/anccr_sweep'

%Define the parameters and values to search over
model_sweep = struct;
model_sweep.threshold = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
model_sweep.alpha0 = [1e-4, 8e-5, 6e-5, 4e-5, 2e-5, 1e-5, 8e-6];
model_sweep.k = [0.1, 0.3, 0.5, 0.7];

% experiment settings
expparams = defaultexpparams;
expparams.trialpersession = [100, 50, 11, 6, 2];

paramsweep_anccr(model, exp_path, model_sweep, expparams)

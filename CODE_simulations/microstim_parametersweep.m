clearvars; clc; 
close all;
addpath('functions')
addpath('models')
addpath('configs')

%% inputs for sweep
% model name
model = 'microstimulus';
exp_path = '../DATA_simulation_outputs/microstimulus_sweep'
% Define the parameters and values to search over
model_sweep = struct;

model_sweep.alpha = [0.001, 0.01, 0.1];
model_sweep.gamma = [0.8, 0.9, 0.99, 0.999, 0.9999];
model_sweep.nmicrostimuli = [3, 10, 100, 1000];
model_sweep.d = [0.8, 0.9, 0.99, 0.999, 0.9999];

thresholds_to_sweep = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];

% experiment settings
expparams = defaultexpparams;
expparams.trialpersession = [100, 50, 11, 6, 2];
%uncomment below for extra trial run (for asymptotic values)
%expparams.trialpersession = [100, 50, 50, 50, 50];
paramsweep_microstimSOP(model, exp_path, model_sweep, expparams, thresholds_to_sweep)

function anccrparams = defaultanccrparams
%DEFAULTANCCRPARAMS define anccr model parameters as anccrparam struct.
%   w (float between 0-1): determines weighting between SRC and PRC where 
%               NC = w*SRC + (1-w)*PRC.
%   minrate (float): If the baseline event rate of X is smaller than 
%               minimumrate, the model doesn't calculate SRC from PRC. 
%               This is to prevent SRC(X,Y) goes infinitely large 
%               number because of low baseline rate of X.
%   maxjitter (float): When two stimuli are presented at the same time, 
%               give perception delay b/w them. delay b/w them 
%               cannot be larger than maximumjitter.
%   beta (array): Innate salience of each event (cue, reward). 
%               Meaningfulness of a stimulus is determined by the sum of 
%               learned salience and innate salience.
%   threshold (float): Threshold for definining causal association; if 
%               NC(X,Y)>threshold, model forms a causal association b/w X 
%               and Y.
%   T (float): Decay constant of eligibility trace
%   k (float): If scaling T w/IRI, need to overwrite rate of learning 
%               baseline event rate.  
%   alpha0 (float):
%   alpha_r (float): Rate of learning R (reward magnitude).
%   dt (float): Sampling interval for the calculation of baseline event rate. 
%   optolog (array or nan): Default is NaN.
%   omidx (array or nan): State index/label identifying the omission state. 
%               Default is NaN.
%   nevent_for_edge: Default is NaN.
%   dropout: Default is NaN.
    anccrparams = struct;
    anccrparams.w = 0.5; 
    anccrparams.minrate = 1e-6;
    anccrparams.maxjitter = 0.1; 
    anccrparams.beta = [0, 0.8]; 
    anccrparams.threshold = 0.4;
    anccrparams.T = 500; 
    anccrparams.k = nan;   
    anccrparams.alpha0 = 4e-5; 
    anccrparams.alpha_r = 1;    
    anccrparams.dt = 0.2; 
    anccrparams.optolog = nan;
    anccrparams.omidx = nan;
    anccrparams.nevent_for_edge = nan;
    anccrparams.dropout = nan;
end
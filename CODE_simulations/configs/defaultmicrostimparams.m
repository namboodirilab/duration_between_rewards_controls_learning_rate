function microstimparams = defaultmicrostimparams
%DEFAULTMICROSTIMPARAMS generate struct with default microstimulus
%parameters.
%   rewardstate (int): Integer label for reward state.
%   statesize (float): Length (in seconds) of substate.
%   alpha (float): Learning rate.
%   gamma (float): Temporal discount factor.
%   lambda (float): Eligibility trace decay constant.
%   sigma (float): Defines the width of microstimuli.
%   nmicrostimuli (int): Specifies the number of microstimuli.
%   d (float): Sets height of microstimulus.
%   threshold (float): Value at which conditioned response is set to
%               emerge.
%   inhibitionlog (array): If simulating opto, specifies states where
%               inhibition is applied.
%   k (float or NaN): If using IRI scaling to set learning rate, k is
%               parameter relating learning rate and IRI, with relationship
%               alpha = = 1 - exp(-microstimparams.k*IRI).
%   maxstatelength (float): Truncate states at specified distance from each
%               cue onset (Default is NaN).

    microstimparams = struct;
    microstimparams.rewardstate = 2;
    microstimparams.statesize = 0.25;
    microstimparams.alpha = nan;
    microstimparams.gamma = nan;
    microstimparams.lambda = 0.99;
    microstimparams.sigma = 0.08;
    microstimparams.nmicrostimuli = nan;
    microstimparams.d = nan;
    microstimparams.threshold = nan;
    microstimparams.inhibitionlog = nan;
    microstimparams.maxstatelength = nan;
    microstimparams.k = nan;
   
end


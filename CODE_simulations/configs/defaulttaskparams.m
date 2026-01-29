function taskparams = defaulttaskparams
%DEFAULTTASKPARAMS generates struct with default task params for pavlovian
%               task with a single cue and reward.
%   trialpersession (int): Number of cue presentations in session.
%   nsession (int): Number of sessions in full experiment.
%   nIter (int): Number of iterations of experiment (proxy for number of
%               animals).
%   numcue (int): Total number of cue presentations, trials per session
%               multiplied by number of sessions.
%   meanITI (float): Mean inter-trial interval (ITI), time between reward
%               delivery (plus a buffer period) and next cue presentation.
%   cuerewdelay (float): Time between cue presentation and reward delivery.
%   postrewdelay (float): Buffer period after reward delivery, before ITI.
%   cue_label (int): Unique integer identifying the cue.
%   rew_label (int): Unique integer identifying the reward.
%   reward_mag (float): Magnitude of reward when delivered.
%   rew_prob (float): Probability that reward is delivered.
%   omissionlabel (int or NaN): If omission is being treated as distinct
%               state, unique integer identifying the omission event.
%   distribution (string): Specifies the distribution over which the ITI is
%               sampled (e.g. 'uniform' or 'exponential').
%   bgdrw_label (int): Unique integer identifying a background reward.
%   bgdrw_IRI (float): Specifies delays between background rewards.
%   bgdrw_cue_delay (float): Specifies a buffer period between background
%               reward and cue.
%   bdgrw_mag (float): Magnitude of delivered background reward.

    % iterations
    taskparams.trialpersession = 50;
    taskparams.nsession = 8;
    taskparams.nIter = 20;
    taskparams.numcue = taskparams.trialpersession*taskparams.nsession;
    % delays
    taskparams.meanITI = 30;
    taskparams.cuerewdelay = 1.25;
    taskparams.postrewdelay = 3;
    % labels
    taskparams.cue_label = 1;
    taskparams.rew_label = 2;
    taskparams.reward_mag = 1;
    taskparams.rew_prob = 1;  % assume 100% rew prob as default
    taskparams.omissionlabel = nan;  % ignore omission state as default
    taskparams.distribution = 'uniform';
    % default without background rewards
    taskparams.bgdrw_label = nan;
    taskparams.bgdrw_IRI = nan;
    taskparams.bgdrw_cue_delay = nan;
    taskparams.bgdrw_mag = nan;
end
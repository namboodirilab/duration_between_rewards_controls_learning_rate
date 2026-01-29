function expparams = defaultexpparams
%DEFAULTEXPPARAMS returns a struct with settings for learning rate scaling experiments.
%   ITIs (array): The intertrial interval for simulated behavior, in
%               seconds.
%   trialpersession (array): Number of trials in a given session for each
%               ITI in learning rate scaling experiment.

    expparams = struct; 
    expparams.ITIs = [30, 60, 300, 600, 3600];
    expparams.trialpersession = [100, 50, 11, 6, 2];
end


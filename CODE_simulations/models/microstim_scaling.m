function trials_to_threshold = microstim_scaling(microstimparams, exp_path, expparams, model_id, thresholds_to_sweep)
%% adapt inputs, filesaving path to generalize past single parameter sweep
    % generate eventlog, all CS/US timestamps
    taskparams = defaulttaskparams;
    taskparams.distribution = 'uniform';

    if ~isfolder(exp_path)
            mkdir(exp_path);
    end
    %% simulation
    nITI = length(expparams.ITIs);
    nIter = taskparams.nIter;  % this should probably not be like this
    nthresholds = length(thresholds_to_sweep);
    trials_to_threshold = nan(nthresholds, nITI, nIter);
    values = {nITI, nIter};
    rpes = {nITI, nIter};
    events = {nITI, nIter};
    for iITI = 1:nITI
        taskparams.meanITI = expparams.ITIs(iITI);
        taskparams.trialpersession = expparams.trialpersession(iITI);
        taskparams.numcue = taskparams.trialpersession*taskparams.nsession;
        for iIter = 1:nIter
            [eventlog, IRI] = simulateEvents(taskparams);
            [v, rpe, event] = microstimulus(eventlog, IRI, ...
                microstimparams);
            for ithresh = 1:nthresholds
                threshold_cross_idx = find(v > thresholds_to_sweep(ithresh));
                if ~isempty(threshold_cross_idx)
                    % Get the index of the first value that crosses the threshold
                    first_idx_above_thresh = threshold_cross_idx(1);
                    rewards_del_mask = event(1:first_idx_above_thresh,1) == 2;
                    % Use the sum function to count the number of
                    % occurrences of 2 (reward)
                    rewards_before_threshold = sum(rewards_del_mask);
                    trials_to_threshold(ithresh, iITI, iIter) = rewards_before_threshold;
                else
                    trials_to_threshold(ithresh, iITI, iIter) = nan;
                end
            end
               
            
            values(iITI, iIter) = {v};
            rpes(iITI, iIter) = {rpe};
            events(iITI, iIter) = {event(:,1)};
        end
    end
    
    save([exp_path, '/', model_id, ...
        '_simulationdata.mat'], 'microstimparams', 'expparams', ...
        'trials_to_threshold','values','rpes','events','-v7.3');
end

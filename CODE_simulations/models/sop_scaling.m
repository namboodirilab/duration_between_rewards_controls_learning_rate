function trials_to_threshold = sop_scaling(sop_params, exp_path, expparams, model_id, thresholds_to_sweep)

    % generate eventlog, all CS/US timestamps
    taskparams = defaulttaskparams;
    taskparams.distribution = 'uniform';

    if ~isfolder(exp_path)
            mkdir(exp_path);
    end
    %% simulation
    nITI = length(expparams.ITIs);
    nIter = taskparams.nIter;  
    nthresholds = length(thresholds_to_sweep);
    trials_to_threshold = nan(nthresholds, nITI, nIter);
    sop_timeseries_all = cell(nITI,nIter);
    sop_value_all = {nITI, nIter};
    events = {nITI, nIter};
    for iITI = 1:nITI
        taskparams.meanITI = expparams.ITIs(iITI);
        taskparams.trialpersession = expparams.trialpersession(iITI);
        taskparams.numcue = taskparams.trialpersession*taskparams.nsession;
        V_cue = nan(taskparams.numcue, nIter);
        for iIter = 1:nIter
            [eventlog, ~] = simulateEvents(taskparams);
            [V, sop_timeseries, event]= sop(eventlog, sop_params);
            for ithresh = 1:nthresholds
                threshold_cross_idx = find(V > thresholds_to_sweep(ithresh));
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
            V_cue(:, iIter) = V(floor(sop_timeseries.cs_times/ ...
                sop_params.dt));
            sop_timeseries_all{iITI, iIter} = {sop_timeseries};
            sop_value_all(iITI, iIter) = {V};
            events(iITI, iIter) = {event(:,1)};
        end
    end
    
    save([exp_path, '/', model_id, ...
        '_simulationdata.mat'],'sop_params', 'expparams', ...
        'trials_to_threshold', 'V_cue','sop_timeseries_all', 'events', ...
        'sop_value_all','-v7.3');
end
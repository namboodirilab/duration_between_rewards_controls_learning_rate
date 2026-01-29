function [V, sop_timeseries, eventtimeline] = sop(eventlog, sp)
%SOP runs the sometimes opponent process model on simulated behavioral data.
%   eventlog (array): Includes the stimulus label, timestamp, and reward
%               magnitude for a simulated behavioral session.
%   sp (struct): Defines model parameters (see configs/defaultsopparams for
%               further specification).

    dt = sp.dt;

    event_ids = unique(eventlog(:, 1));
    cs_id = event_ids(1); us_id = event_ids(2);
    
    nstimuli = length(unique(eventlog(:,1)));
    sessionendtime = eventlog(end,2)+5;
    nstate = floor(sessionendtime/dt);
    
    eventtimeline = zeros(nstate,2);
    for is = 1:nstimuli
       eventidx = ceil(eventlog(eventlog(:,1)==is,2)/dt);
       eventtimeline(unique(eventidx),1) = is;
       eventtimeline(unique(eventidx),2) = cellfun(@(x) sum(eventidx==x), ...
           num2cell(unique(eventidx)));
    end
    cs_times = eventlog((eventlog(:, 1) == cs_id), 2);
    us_times = eventlog((eventlog(:, 1) == us_id), 2);
    cs_duration = 0.25; % in s
    num_cs_timebins = ceil(cs_duration/dt); % assuming time bin matches the cue duration for our experiment
    total_time = us_times(end)+dt*2;  % find final timestep of behavior

    cs_time_trace = zeros(ceil(total_time/dt),1); % 1 when cs is on, 0 otherwise
    for j = 1:num_cs_timebins
        % find the indices of cs onset in time trace (to span cue duration)
        cs_time_trace(floor(cs_times/dt)+j-1) = 1;
    end
    us_time_trace = zeros(ceil(total_time/dt),1); % 1 when us is on, 0 otherwise
    us_time_trace(floor(us_times/dt)) = 1;
    
    % initialize timeseries for node substate activations, value, etc.
    pI_cs = ones(ceil(total_time/dt),1);
    pA1_cs = zeros(ceil(total_time/dt),1);
    pA2_cs = zeros(ceil(total_time/dt),1);
    pI_us = ones(ceil(total_time/dt),1);
    pA1_us = zeros(ceil(total_time/dt),1);
    pA2_us = zeros(ceil(total_time/dt),1);
    p2 = zeros(ceil(total_time/dt),1);
    V = zeros(ceil(total_time/dt),1);
    %us_to_learn = nan;
    
    for i = 2:ceil(total_time/dt)
        % increment A1_CS if we see CS for first time since prev timestep,
        % otherwise continue to decay according to (1 - pd1_cs)^t
        pA1_cs(i) = sp.p1_cs*pI_cs(i-1)*cs_time_trace(i) + (1 - sp.pd1_cs)*pA1_cs(i-1);
        % decay A2 CS through (1) decay from A1 via pd1_cs and (2) transition
        % to inactive state via (1 - pd2_cs)^t
        pA2_cs(i) = sp.pd1_cs*pA1_cs(i-1) + (1 - sp.pd2_cs)*pA2_cs(i-1);
        % accumulate I CS via decay from A2 scaled by pd2_cs, activity is
        % maintained but inversely scaled by CS elements
        pI_cs(i) = sp.pd2_cs*pA2_cs(i-1) + (1 - sp.p1_cs*cs_time_trace(i))*pI_cs(i-1);
        
        % calculate value at timestep i
        % coincidence of CS / US in A1 increase value
        % CS in A1 and US in A2 decreases value
        V(i) = V(i-1) + sp.L_plus*(pA1_cs(i-1)*pA1_us(i-1)) - sp.L_minus*(pA1_cs(i-1)*pA2_us(i-1));
        % if V(i) >= sp.threshold & isnan(us_to_learn)
        %     us_to_learn = length(nonzeros(us_times < i*dt));
        % end
        % p2 determines mutual influence of CS/US -> higher values of p2
        % will mean that more US elements are active during the CS
        p2(i) = min([1, V(i)*(sp.r1*pA1_cs(i) + sp.r2*pA2_cs(i))])*cs_time_trace(i);
        p2(i) = max([0, p2(i)]);

        % update active elements for the US
        % increment US A1 if seeing US for first time since prev timestep
        % otherwise decay according to (1 - pd1_us)^t 
        pA1_us(i) = sp.p1_us*pI_us(i-1)*us_time_trace(i) + (1 - sp.pd1_us)*pA1_us(i-1);
        % decay A2 US through (1) decay from A1 via pd1_us and (2) transition
        % to inactive state via (1 - pd2_us)^t
        pA2_us(i) = sp.pd1_us*pA1_us(i-1) + (1 - sp.pd2_us)*pA2_us(i-1) + p2(i)*pI_us(i-1);
        % accumulate I US via decay from A2 scaled by pd2_us, activity is
        % maintained but inversely scaled by US elements and elements of CS on
        % conferred via p2
        pI_us(i) = sp.pd2_us*pA2_us(i-1) + (1 - sp.p1_us*us_time_trace(i)- p2(i))*pI_us(i-1);
        
    end
    % save and return all timeseries data
    sop_timeseries = struct;
    sop_timeseries.cs_times = cs_times;
    sop_timeseries.us_times = us_times;
    sop_timeseries.pA1_cs = pA1_cs;
    sop_timeseries.pA2_cs = pA2_cs;
    sop_timeseries.pI_cs = pI_cs;
    sop_timeseries.p2 = p2;
    sop_timeseries.pA1_us = pA1_us;
    sop_timeseries.pA2_us = pA2_us;
    sop_timeseries.pI_us = pI_us;
   
end
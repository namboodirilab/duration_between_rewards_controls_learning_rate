function [valuetimeline, rpetimeline, eventtimeline] = microstimulus(eventlog, IRI, microstimparams)
%MICROSTIMULUS runs microstimulus model on simulated behavioral data.
%   eventlog (array): Includes the stimulus label, timestamp, and reward
%               magnitude for a simulated behavioral session.
%   IRI (float): The average interreward interval from the same session.
%   microstimparams (struct): Defines model parameters (see
%               configs/defaultmicrostimparams for further specification).

    if isnan(microstimparams.k)
        % if not using IRI scaling of learning rate, will have k = NaN
        alpha = microstimparams.alpha;
    else
        % if using IRI scaling of learning rate, set alpha using k and IRI
        alpha = 1 - exp(-microstimparams.k*IRI);
        
    end
    % unpack other model parameters from microstim params struct
    rewardstate = microstimparams.rewardstate;
    gamma = microstimparams.gamma;
    lambda = microstimparams.lambda;
    statesize = microstimparams.statesize;
    sigma = microstimparams.sigma;
    nmicrostimulus = microstimparams.nmicrostimuli;
    d = microstimparams.d;
    threshold = microstimparams.threshold;
    maxstatelength = microstimparams.maxstatelength;

    cuestate = 1; 
    rewardstate = 2;  
    maxstatelength = nan; 
    %% generate eventtimeline
    % eventtimeline: [state index, reward magnitude]
    % if reward happens multiple times within a single state, reward magnitude
    % increases linearly
    nstimuli = length(unique(eventlog(:,1)));
    sessionendtime = eventlog(end,2)+5;
    nstate = floor(sessionendtime/statesize);
    
    eventtimeline = zeros(nstate,2);
    for is = 1:nstimuli
       eventidx = ceil(eventlog(eventlog(:,1)==is,2)/statesize);
       eventtimeline(unique(eventidx),1) = is;
       eventtimeline(unique(eventidx),2) = cellfun(@(x) sum(eventidx==x), ...
           num2cell(unique(eventidx)));
    end

    %% calculate RPE - 
    [valuetimeline,rpetimeline] = deal(zeros(nstate,1));
    %weight (w), eligibility trace (e), microstimulus level (x), memory trace height (y)
    [w,e,x] = deal(zeros(nmicrostimulus,nstimuli));
    y = deal(zeros(1,nstimuli));
    nrewards = 0;
    threshold_crossed = false;
    
    % for first time bin 
    stimulusidx = cell(nstimuli,1);
    stimulusnum = nan(nstimuli,1);
    for is = 1:nstimuli
       stimulusidx{is} = find(eventtimeline(:,1)==is); 
       stimulusnum(is) = sum(eventtimeline(:,1)==is);
    end
    tempstimuli = zeros(1,nstimuli);
    
    rewarded = ismember(eventtimeline(1,1),rewardstate);
    if rewarded
       reward = eventtimeline(1,2);
    else
        reward = 0;
    end

    RPE = reward+gamma*valuetimeline(1);
    rpetimeline(1) = RPE;
    
    for is = 1:nstimuli
        w(:,is) = w(:,is)+alpha*rpetimeline(1)*e(:,is);
        e(:,is) = gamma*lambda*e(:,is)+x(:,is);
    end
    
    % iterate calculation for rest time bins
    for i = 2:nstate
        skip = 0;
    
        % activate a set of microstimuli when cs or us is delivered
        vtemp = 0;
        for is = 1:nstimuli
            if tempstimuli(is)+1<=stimulusnum(is)
                if i>=stimulusidx{is}(tempstimuli(is)+1)
                    tempstimuli(is) = tempstimuli(is)+1;
                end
            end
            if tempstimuli(is)>0
                if ~isnan(maxstatelength)
                    % if time longer than maxstatelength has passed since last
                    % event, truncate state by skipping calculation
                    if (i-stimulusidx{is}(tempstimuli(is)))*statesize>maxstatelength
                        valuetimeline(i) = valuetimeline(i-1);
                        skip = 1;
                        continue;
                    end
                end
               y(is) = d^(i-stimulusidx{is}(tempstimuli(is)));
               x(:,is) = (1/sqrt(2*pi))*exp(-((y(is)-[1:nmicrostimulus]'/nmicrostimulus).^2)/(2*sigma^2))*y(is);
            end
            vtemp = vtemp + w(:,is)'*x(:,is);
        end
        if skip==1
            continue;
        end
        valuetimeline(i) = vtemp;
        
   
        % reward: reward magnitude of next time bin
        rewarded = ismember(eventtimeline(i,1),rewardstate);
        if rewarded
            reward = eventtimeline(i,2);
            nrewards = nrewards + 1;
        else
            reward = 0;
        end
        
        
        RPE = reward+gamma*valuetimeline(i)-valuetimeline(i-1); 
        rpetimeline(i) = RPE;
        
        % update weights and eligibility traces for cs and us
        for is = 1:nstimuli
           w(:,is) = w(:,is)+alpha*rpetimeline(i)*e(:,is);
           e(:,is) = gamma*lambda*e(:,is)+x(:,is);
        end
    end

end


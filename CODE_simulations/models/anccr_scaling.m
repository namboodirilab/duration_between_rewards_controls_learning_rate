function thresholdtrial = anccr_scaling(anccrparams, exp_name, expparams, model_id)

    %% parameter set up
    beta = 5; % 
    taskparams = defaulttaskparams;
    taskparams.distribution = 'uniform';

    if ~isfolder(exp_name)
            mkdir(exp_name);
    end
    
    % make struct 
    modeldata = struct;
    ITInames = string(expparams.ITIs);

    %% simulation
    nITI = length(expparams.ITIs);
    nIter = taskparams.nIter; 
    numcue = expparams.trialpersession*taskparams.nsession;
    [cuersp,rwrsp,cuersp_nc,rwrsp_nc, cuevalue] = deal(nan(max(numcue),nIter,nITI));
    thresholdtrial = nan(nITI, nIter); 
    modeldata.PRC_cr = nan(nITI, nIter, max(numcue));
    modeldata.SRC_cr = nan(nITI, nIter, max(numcue));
    modeldata.NC_rr = nan(nITI, nIter, max(numcue));
    modeldata.PRC_rr = nan(nITI, nIter, max(numcue));
    modeldata.SRC_rr = nan(nITI, nIter, max(numcue));
    modeldata.NC_rr = nan(nITI, nIter, max(numcue));
    modeldata.base_c = nan(nITI, nIter, max(numcue));
    modeldata.base_r = nan(nITI, nIter, max(numcue));
    modeldata.cue_times = nan(nITI, nIter, max(numcue));
    modeldata.rew_times = nan(nITI, nIter, max(numcue));
    for iIter = 1:nIter
        for iITI = 1:nITI
            taskparams.meanITI = expparams.ITIs(iITI);
            taskparams.trialpersession = expparams.trialpersession(iITI);
            taskparams.numcue = taskparams.trialpersession*taskparams.nsession;
            % generate eventlog
            [eventlog, IRI] = simulateEvents(taskparams);
            % simulate ANCCR
            [DA,~,PRC,SRC,NC,R,~,~,Mi] = calculateANCCR(eventlog,anccrparams,IRI);
            incue = eventlog(:,1)==1;
            cue_time = eventlog(incue, 2);
            inrw = eventlog(:,1)==2;
            rew_time = eventlog(inrw, 2);
            cuersp(1:numcue(iITI),iIter,iITI) = DA(incue);
            rwrsp(1:numcue(iITI),iIter,iITI) = DA(inrw);
            %
            cuersp_nc(1:numcue(iITI),iIter,iITI) = NC(1,2,incue);
            rwrsp_nc(1:numcue(iITI),iIter,iITI) = NC(2,2,inrw);
            
            % cue value is estimated for later generation of behavior
            R(1,2,incue) = 1;
            cuevalue(1:numcue(iITI),iIter,iITI) = NC(1,2,incue).*R(1,2,incue);
            % threshold crossing trial (when animal associated cue nd reward) - where behavior can start emerging
            thresholdcrossingtrial = find(squeeze(NC(1,2,incue))>anccrparams.threshold,1,'first');
            if ~isempty(thresholdcrossingtrial)
                cuevalue(1:thresholdcrossingtrial-1,iIter,iITI) = 0;
                thresholdtrial(iITI, iIter) = thresholdcrossingtrial;
            else 
                cuevalue(1:numcue(iITI),iIter,iITI) = 0;
                thresholdtrial(iITI, iIter) = nan;
            end
            modeldata.PRC_cr(iITI,iIter,1:numcue(iITI)) = PRC(1,2,incue);
            modeldata.SRC_cr(iITI,iIter,1:numcue(iITI)) = SRC(1,2,incue);
            modeldata.NC_cr(iITI,iIter,1:numcue(iITI)) = NC(1,2,incue);
            modeldata.PRC_rr(iITI,iIter,1:numcue(iITI)) = PRC(2,2,inrw);
            modeldata.SRC_rr(iITI,iIter,1:numcue(iITI)) = SRC(2,2,inrw);
            modeldata.NC_rr(iITI,iIter,1:numcue(iITI)) = NC(2,2,inrw);
            modeldata.base_c = Mi(1, incue);
            modeldata.base_r = Mi(2, incue);
            modeldata.cue_times(iITI,iIter,1:numcue(iITI)) = cue_time;
            modeldata.rew_times(iITI,iIter,1:numcue(iITI)) = rew_time;
        end
    end
    
    modeldata.thresholdtrial = thresholdtrial;
    % 
    %% save data
    nmaxreward = 3; % number of rewards used to calculate max reward response
    
    
    nlast = [200, 100, 10, 5, 2];  
    
    % to keep number of analysis trials consistent despite having overall
    % variation in trial number across ITIs
    numanalcue = ceil(expparams.trialpersession(1)*taskparams.nsession./(expparams.ITIs/expparams.ITIs(1))); % total number of trial used for analysis
    
    prob = lickprobs(cuevalue, beta);
    trials_to_changepoint = nan(nITI, nIter);
    
    for iITI = 1:nITI
        [normDAcuersp,normDArewrsp,DAcuersp,DArewrsp] = deal(nan(nIter,numanalcue(iITI)));
        DAcuersp(:,:) = squeeze(cuersp(1:numanalcue(iITI),:,iITI))';
        DArewrsp(:,:) = squeeze(rwrsp(1:numanalcue(iITI),:,iITI))';
        rwdata_sort = sort(squeeze(rwrsp(1:numanalcue(iITI),:,iITI)),'descend');
        maxrewardrsp = mean(rwdata_sort(1:nmaxreward,:)); 
        normDAcuersp(:,:) = squeeze(DAcuersp(:,:))./repmat(maxrewardrsp',1,numanalcue(iITI));
        normDArewrsp(:,:) = squeeze(DArewrsp(:,:))./repmat(maxrewardrsp',1,numanalcue(iITI));
        
        databeh = squeeze(prob(1:numanalcue(iITI),:,iITI));
        datacue = squeeze(cuersp(1:numanalcue(iITI),:,iITI));
        databehcum = cumsum(databeh,1)./repmat(sum(databeh,1),numanalcue(iITI),1);
        [changetrial_beh, changetrial_DA] = deal(nan(nIter,1)); 
        for iIter = 1:nIter
            % probability of lick before threshold crossing trial is zero
            databehcum(1:numanalcue(iITI)<thresholdtrial(iITI, iIter),iIter) = 0;
            d_lick = point2line([[1:numanalcue(iITI)]',databehcum(:,iIter)],...
                [1,databehcum(1,iIter)], [numanalcue(iITI),1]);
            [~,changetrial_beh(iIter)] = max(d_lick);
            % this assumes that there is a change in behavior (i.e. it is
            % learned), otherwise will give misleading answer
            ntrial = round(changetrial_beh(iIter)*1.5);
            if ntrial > numanalcue(iITI)
                % if change trial is not correctly detected b/c no inflection
                % point, plot all points (changetrial at end means no change)
                ntrial = numanalcue(iITI);
            end
            ntrial = max(ntrial);
            datacuecum = cumsum(datacue(1:ntrial,iIter),1)./...
                repmat(sum(datacue(1:ntrial,iIter),1),ntrial,1);
            d_cue = point2line([[1:ntrial]',datacuecum],...
                [1,datacuecum(1)], [ntrial,1]);
            [~,changetrial_DA(iIter)] = max(d_cue);
        end
        trials_to_changepoint(iITI, :) = changetrial_beh;
        
        modeldata.(sprintf('iti'+ITInames(iITI))).normDAcuersp = normDAcuersp;
        modeldata.(sprintf('iti'+ITInames(iITI))).normDArewrsp = normDArewrsp;
        modeldata.(sprintf('iti'+ITInames(iITI))).DAcuersp = DAcuersp;
        modeldata.(sprintf('iti'+ITInames(iITI))).DArewrsp = DArewrsp;
        modeldata.(sprintf('iti'+ITInames(iITI))).lastbehrsp_sr = mean(databeh(end-nlast(iITI)+1:end,:),1)';
        modeldata.(sprintf('iti'+ITInames(iITI))).lastnormDAcuersp = squeeze(mean(modeldata.(sprintf('iti'+ITInames(iITI))).normDAcuersp(:,end-nlast(iITI)+1:end),3))'; 
        modeldata.(sprintf('iti'+ITInames(iITI))).behchangetrial = changetrial_beh;
        modeldata.(sprintf('iti'+ITInames(iITI))).DAchangetrial = changetrial_DA;
    end
    
    %% Save data
    
    save([exp_name, '/', model_id, ...
        '_simulationdata.mat'],'modeldata', 'nIter','nlast','nmaxreward', ...
        'anccrparams','taskparams','-v7.3');

end
function prob = lickprobs(cuevalue,beta)
%LICKPROBS applies softmax to calculate lick probability from estimated value of a state.
%   cuevalue (float): Estimated value of state.
%   beta (float): Inverse temperature parameter, determines how
%               significantly value drives reward probability. Large beta 
%               is similar to equiprobable action selection.

    temperature = 1./beta;
    cost = -0.3; % cost of lick
    qnull = zeros(size(cuevalue)); % action value of no lick 
    q = cuevalue+cost; % action value of lick = cue value + cost of lick
    prob = exp(q/temperature)./(exp(q/temperature)+exp(qnull/temperature));
end
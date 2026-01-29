function sop_params = defaultsopparams
%DEFAULTSOPPARAMS generate struct with default SOP params.
%   dt (float): Size of each time bin (in seconds)
%   r1 (float): Effective reward magnitude of CS in A1.
%   r2 (float): Effective reward magnitude of CS in A2.
%   L_plus (float): Scales magnitude of activation for coincidence of CS 
%               and US in A1.
%   L_minus (float): Scales magnitude of inhibition for CS in A1 and US in 
%               A2.
%   p1_cs (float): Magnitude of the CS at onset.
%   pd1_cs (float): Decay term from A1 to A2 for CS.
%   pd2_cs (float): Decay term from A2 to I for CS.
%   p1_us (float): Magnitude of US at onset.
%   pd1_us (float): Decay term from A1 to A2 for US.
%   pd2_us (float): Decay term from A2 to I for US.
%   threshold (float): Threshold at which value is sufficiently high to
%               generate behavior.

    sop_params.dt = 0.25;
    sop_params.r1 = 1; 
    sop_params.r2 = 0.5;
    sop_params.L_plus = 0.2; 
    sop_params.L_minus = 0.1;
    sop_params.p1_cs = 0.1; 
    sop_params.pd1_cs = 0.1; 
    sop_params.pd2_cs = 0.0065; 
    sop_params.p1_us = 0.6;
    sop_params.pd1_us = 0.1;
    sop_params.pd2_us = 0.5;
    sop_params.threshold = 0.5;
end
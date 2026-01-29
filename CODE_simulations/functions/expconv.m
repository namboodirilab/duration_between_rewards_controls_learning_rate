function convdata = expconv(data,binsize,T_decay,T_rise)
% EXPCONV returns the convoluted data with exponential kernel.
% data (array): Data that needs to be convoluted. ntime X nonbservation
% binsize (double): Timebin size of data
% win (double): Size of kernel on one side in the same unit as binsize. 
%               Total kernel size will be 2*win
% T_decay (double): Decay parameter of exponential kernel. Needs to be in the
%               same unit as binsize or win
% T_rise (double): Rise parameter of exponential kernel.

gamma_decay = exp(-1/(T_decay/binsize));
gamma_rise = exp(-1/(T_rise/binsize));
nbin = 10/binsize; % kernel exists for [-10,10] from each datapoint
kernel = [zeros(1,nbin),gamma_decay.^(0:nbin)-gamma_rise.^(0:nbin)];

nobs = size(data,2);
data_zeropadded = [zeros(nbin,nobs);data];
convdata = conv2(kernel,1,data_zeropadded,'same');
convdata = convdata(nbin+1:end,:);
end
function [combination_matrix, combination_configs, metadata] = sweepcombinations_microstimSOP(sweepparams, modelparams, thresholds_to_sweep)
%SWEEPCOMBINATIONS finds all paramter combinations for a specific sweep and 
%               generates configuration files for all resulting models.
%   sweepparams (struct): Contains all parameters to be included in
%               parameter study.
%   modelparams (struct): Default model parameter structure which will be
%               modified to generate full set of parameter configurations
%               for sweep. 
    paramnames = fieldnames(sweepparams);
    n_params = length(paramnames);
    n_comb = numcombinations(sweepparams);
    nthresholds = length(thresholds_to_sweep);
    % matrix to store all unique parameter combinations for study
    combination_matrix = nan(n_comb, n_params);
    % set of all model configurations corresponding to the parameter
    % combinations listed in the combination matrix
    combination_configs = cell(n_comb, 1);
    if n_params == 1
        % base case for recursion, only one parameter left to loop through
        paramname = cell2mat(paramnames(1));
        candidate_values = sweepparams.(paramname);
        assert(length(candidate_values) == n_comb, 'base case error')
        for j = 1:length(candidate_values)
            modelparams.(paramname) = candidate_values(j);
            combination_matrix(j) = candidate_values(j);
            combination_configs(j) = {modelparams};
        end
    else
        paramname = cell2mat(paramnames(1));
        candidate_values = sweepparams.(paramname);
        % trim parameter sweep object
        sweepparams = rmfield(sweepparams, (paramname));
        [combination_matrix_sub, combination_configs_sub, ~] = sweepcombinations_microstimSOP(sweepparams, modelparams,thresholds_to_sweep);
        [r, c] = size(combination_matrix_sub);
        for j = 1:length(candidate_values)
            for k = 1:length(combination_configs_sub)
                % have to access struct to change value (reason for
                % modelparams_sub)
                modelparams_sub = cell2mat(combination_configs_sub(k));
                modelparams_sub.(paramname) = candidate_values(j);
                % update combination matrix with candidate + sub comb
                combination_matrix(end-j*r+k, end-c:end) = [candidate_values(j), combination_matrix_sub(k, :)];
                % convert struct back to cell and update configs
                combination_configs(end-j*r+k) = {modelparams_sub};
            end
        end
    end

    % metadata object for final output (combination matrix with headers
    % identifying parameters)
    n_rows = n_comb * nthresholds;
    metadata = cell(n_rows+1, n_params+3);
    metadata(1, 1) = {'index'};
    metadata(1, 2) = {'model_id'};
    metadata(1, 3) = {'threshold'};
    metadata(1, 4:end) = (paramnames);
    metadata(2:end, 1) = num2cell(1:n_rows);
    metadata(2:end, 2) = num2cell(reshape(repelem(1:n_comb, nthresholds, 1), 1, []));
    metadata(2:end, 3) = num2cell(repmat(thresholds_to_sweep, 1, n_comb));
    metadata(2:end, 4:end) = num2cell(repelem(combination_matrix, nthresholds, 1));
end




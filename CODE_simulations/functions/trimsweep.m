function idxs = trimsweep(sweep_metadata,varname,values)
%TRIMSWEEP returns indices corresponding to a subset of models in a sweep.
%    sweep_metadata (struct): Summarizes variable configurations for each 
%               model in a sweep.
%    varname (string): Specifies the relevant variable (e.g. 'dt').
%    vaalues (float or array): Corresponds to the values of specified
%               variable for which the model indices will be returned.
    
    % isolate variable names from metadata header
    varname_candidates = sweep_metadata(1, :);
    % identify column index for relevant variable
    var_column_idx = strcmp(varname, varname_candidates);
    % isolate column for specific variable
    value_candidates = cell2mat(sweep_metadata(2:end, var_column_idx));
    % if multiple values are being retained, return indices of all values
    if length(values) > 1
        idxs = []; % initialize array of variable indices
        for i = 1:length(values)
            % return indices of individual variable value
            idx_single_value = find(value_candidates == values(i));
            % concatenate with array of all variable indices
            idxs = [idxs idx_single_value];
        end
        % when all indices have been found, return to ascending order
        idxs = sort(idxs);
    else
        % if only one value is being retained, simply return indices that
        % correspond to the specified value
        idxs = find(value_candidates == values);
    end
end
function n_comb = numcombinations(model_sweep)
%NUMCOMBINATIONS returns the number of parameter combinations from a given sweep config
%   model_sweep (struct): Specifies the set of parameters to test in a grid
%               search parameter study.
    param_names_sweep = fieldnames(model_sweep);
    n_params = numel(param_names_sweep);
    n_comb = 1;
    for i = 1:n_params
        n_comb = n_comb * length(model_sweep.(cell2mat(param_names_sweep(i, 1))));
    end
end


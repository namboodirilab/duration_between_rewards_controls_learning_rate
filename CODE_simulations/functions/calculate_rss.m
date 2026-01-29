function rss = calculate_rss(behavior, model_fit)
%CALCULATE_RSS find residual sum of squares. Here, RSS is calculated on log
%               transformed data to account for the wide variation in 
%               trials to learn across IRIs.
%   behavior (array): Observed number of trials required for emergence of
%               conditioned response (CR) in animal behavior.
%   model_fit (array): Predicted number of trials to learn CR by a model.

    y = log(behavior);
    y_pred = log(model_fit);
    % Set all the predictions where model did not learn to "infinite"
    % trials to learn to exclude them from fitting
    y_pred(isnan(y_pred)) = inf;
    rss = nan(size(y_pred,1),1);
    for i = 1:length(y_pred)
        rss(i) = sum((y - y_pred(i,:)).^2, 'all', "omitnan");
    end
end
function [aic, caic] = calculate_aic(behavior, model_fit, num_params)
%CALCULATE_AIC returns the Akaike information criterion and corrected AIC.
%   behavior (array): Ground truth to compare to model predictions. Here,
%               trials to learn conditioned response (CR).
%   model_fit (array): Model predictions for trials to learn CR.
%   num_params (int): Number of model parameters.
    
    y = behavior;
    y_pred = model_fit;
    num_animals = sum(~isnan(y), 'all');
    meanrss = mean((y - y_pred).^2, 'all', "omitnan");
    % calculate AIC
    aic =  2*num_params + num_animals*log(meanrss);
    % calculate corrected AIC, recommended for small sample size
    caic = aic + (2*num_params*(num_params+1)) / (num_animals - num_params - 1);
end
function [response] = mergeResponses(response_cf, response_pwp, alpha, merge_method)
%MERGERESPONSES interpolates the two responses with the hyperparameter ALPHA
    if strcmp(merge_method, 'const_factor')
        response = (1 - alpha) * response_cf + alpha * response_pwp;
    end

    if strcmp(merge_method, 'fit_gaussian')
        [~, cov2D_cf] = fitGaussian(response_cf);
        [~, cov2D_pwp] = fitGaussian(response_pwp);
        response_u = ones(size(response_cf));
        [~, cov2D_u] = fitGaussian(response_u);
        w_cf = 1 - sqrt(det(cov2D_cf)/det(cov2D_u));
        w_pwp = 1 - sqrt(det(cov2D_pwp)/det(cov2D_u));
        sum_cf_pwp = w_cf + w_pwp;
        w_cf = w_cf / sum_cf_pwp;
        w_pwp = w_pwp / sum_cf_pwp;

        response = w_cf * response_cf + w_pwp * response_pwp;
        fprintf('w_cf: %.3f    w_pwp: %.3f\n', w_cf, w_pwp);
    end
end

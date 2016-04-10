function [P_O] = getColourMap(patch, bg_hist, fg_hist, n_bins, grayscale_sequence)
%% GETCOLOURMAP computes pixel-wise probabilities (PwP) given PATCH and models BG_HIST and FG_HIST
    % check whether the patch has 3 channels
    [h, w, d] = size(patch);
    % figure out which bin each pixel falls into
    bin_width = 256/n_bins;
    % convert image to d channels array
    patch_array = reshape(double(patch), w*h, d);
    % to which bin each pixel (for all d channels) belongs to
    bin_indices = floor(patch_array/bin_width) + 1;
    % Get pixel-wise posteriors (PwP)
    P_bg = getP(bg_hist, h, w, bin_indices, grayscale_sequence);
    P_fg = getP(fg_hist, h, w, bin_indices, grayscale_sequence);

    % Object-likelihood map
    P_O = P_fg ./ (P_fg + P_bg);
end

function [tracker] = initTracker_webcam(im, tracker, p)
    
	%% INITIALIZATION
	tracker.pos = p.init_pos;
    tracker.target_sz = p.target_sz;
    % patch of the target + padding
    patch_padded = getSubwindow(im, tracker.pos, p.norm_bg_area, tracker.bg_area);
    % initialize hist model
    tracker.new_pwp_model = true;
    [tracker.bg_hist, tracker.fg_hist] = updateHistModel(tracker.new_pwp_model, patch_padded, tracker.bg_area, tracker.fg_area, ...
                                            tracker.target_sz, p.norm_bg_area, p.n_bins, p.grayscale_sequence);
    tracker.new_pwp_model = false;

    % Hann (cosine) window is used to remove ripple artifacts due to going back and forth the Fourier domain
    tracker.hann_window = single(hann(p.cf_response_size(1)) * hann(p.cf_response_size(2))');

    % gaussian-shaped desired response, centred in (1,1)
    % bandwidth proportional to target size
    output_sigma = sqrt(prod(p.norm_target_sz)) * p.output_sigma_factor / p.hog_cell_size;
    y = gaussianResponse(p.cf_response_size, output_sigma);
    tracker.yf = fft2(y);

    
	%% SCALE ADAPTATION INITIALIZATION
    if p.scale_adaptation
        % Code from DSST 
        tracker.currentScaleFactor = 1;
        tracker.base_target_sz = tracker.target_sz;
        scale_sigma = sqrt(p.num_scales) * p.scale_sigma_factor;
        ss = (1:p.num_scales) - ceil(p.num_scales/2);
        ys = exp(-0.5 * (ss.^2) / scale_sigma^2);
        tracker.ysf = single(fft(ys));

        if mod(p.num_scales,2) == 0
            tracker.scale_window = single(hann(p.num_scales+1));
            tracker.scale_window = scale_window(2:end);
        else
            tracker.scale_window = single(hann(p.num_scales));
        end;

        ss = 1:p.num_scales;
        tracker.scaleFactors = p.scale_step.^(ceil(p.num_scales/2) - ss);

        if p.scale_model_factor^2 * prod(p.norm_target_sz) > p.scale_model_max_area
            p.scale_model_factor = sqrt(p.scale_model_max_area/prod(p.norm_target_sz));
        end

        tracker.scale_model_sz = floor(p.norm_target_sz * p.scale_model_factor);

        % find maximum and minimum scales
        tracker.min_scale_factor = p.scale_step ^ ceil(log(max(5 ./ tracker.bg_area)) / log(p.scale_step));
        tracker.max_scale_factor = p.scale_step ^ floor(log(min([size(im,1) size(im,2)] ./ tracker.target_sz)) / log(p.scale_step));    
    end
    
    %% Run for first frame    
    [tracker, ~] = updateTracker_webcam(im, tracker, true, p);    
end
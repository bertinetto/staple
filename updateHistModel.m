function [bg_hist_new, fg_hist_new] = updateHistModel(new_model, patch, bg_area, fg_area, target_sz, norm_area, n_bins, grayscale_sequence, bg_hist, fg_hist, learning_rate_pwp)
%UPDATEHISTMODEL create new models for foreground and background or update the current ones

	% Get BG (frame around target_sz) and FG masks (inner portion of target_sz)
	pad_offset1 = (bg_area-target_sz)/2; % we constrained the difference to be mod2, so we do not have to round here
	assert(sum(pad_offset1==round(pad_offset1))==2, 'difference between bg_area and target_sz has to be even.');

	bg_mask = true(bg_area); % init bg_mask
	pad_offset1(pad_offset1<=0)=1;
	bg_mask(pad_offset1(1)+1:end-pad_offset1(1), pad_offset1(2)+1:end-pad_offset1(2)) = false;

	pad_offset2 = (bg_area-fg_area)/2; % we constrained the difference to be mod2, so we do not have to round here
	assert(sum(pad_offset2==round(pad_offset2))==2, 'difference between bg_area and fg_area has to be even.');
	fg_mask = false(bg_area); % init fg_mask
	pad_offset2(pad_offset2<=0)=1;
	fg_mask(pad_offset2(1)+1:end-pad_offset2(1), pad_offset2(2)+1:end-pad_offset2(2)) = true;

	fg_mask = mexResize(fg_mask, norm_area, 'auto');
	bg_mask = mexResize(bg_mask, norm_area, 'auto');

	%% (TRAIN) BUILD THE MODEL
	if new_model
		% from scratch (frame=1)
		bg_hist_new = computeHistogram(patch, bg_mask, n_bins, grayscale_sequence);
		fg_hist_new = computeHistogram(patch, fg_mask, n_bins, grayscale_sequence);
	else
		% update the model
		bg_hist_new = (1 - learning_rate_pwp)*bg_hist + learning_rate_pwp*computeHistogram(patch, bg_mask, n_bins, grayscale_sequence);
		fg_hist_new = (1 - learning_rate_pwp)*fg_hist + learning_rate_pwp*computeHistogram(patch, fg_mask, n_bins, grayscale_sequence);
	end

end
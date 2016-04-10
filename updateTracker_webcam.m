function [tracker, rect_position] = updateTracker_webcam(im, tracker, is_first, p)

    if ~is_first
        %% TESTING step
        % extract patch of size bg_area and resize to norm_bg_area
        im_patch_cf = getSubwindow(im, tracker.pos, p.norm_bg_area, tracker.bg_area);
        pwp_search_area = round(p.norm_pwp_search_area / tracker.areaResizeFactor);
        % extract patch of size pwp_search_area and resize to norm_pwp_search_area
        im_patch_pwp = getSubwindow(im, tracker.pos, p.norm_pwp_search_area, pwp_search_area);
        % compute feature map
        xt = getFeatureMap(im_patch_cf, p.feature_type, p.cf_response_size, p.hog_cell_size);          
        % apply Hann window
        xt_windowed = bsxfun(@times, tracker.hann_window, xt);
        % compute FFT
        xtf = fft2(xt_windowed);
        % Correlation between filter and test patch gives the response
        % Solve diagonal system per pixel.
        if p.den_per_channel
            tracker.hf = tracker.hf_num ./ (tracker.hf_den + p.lambda);
        else
            tracker.hf = bsxfun(@rdivide, tracker.hf_num, sum(tracker.hf_den, 3)+p.lambda);
        end
        
        response_cf = ensureReal(ifft2(sum(conj(tracker.hf) .* xtf, 3)));

        % Crop square search region (in feature pixels).
        response_cf = cropFilterResponse(response_cf, ...
            floorOdd(p.norm_delta_area / p.hog_cell_size));
        if p.hog_cell_size > 1
            % Scale up to match center likelihood resolution.
            response_cf = mexResize(response_cf, p.norm_delta_area,'auto');
        end

        likelihood_map = getColourMap(im_patch_pwp, tracker.bg_hist, tracker.fg_hist, p.n_bins, p.grayscale_sequence);
        % (TODO) it should probably be at 0.5 (unseen colors shoud have max entropy)            
        likelihood_map(isnan(likelihood_map)) = 0;            

        % each pixel of response_pwp represents the likelihood that
        % the target (of size norm_target_sz) si centred on it            
        response_pwp = getCenterLikelihood(likelihood_map, p.norm_target_sz);

        %% ESTIMATION
        response = mergeResponses(response_cf, response_pwp, p.merge_factor, p.merge_method);
        [row, col] = find(response == max(response(:)), 1);
        center = (1+p.norm_delta_area) / 2;
        tracker.pos = tracker.pos + ([row, col] - center) / tracker.areaResizeFactor;  
        rect_position = [tracker.pos([2,1]) - tracker.target_sz([2,1])/2, tracker.target_sz([2,1])];                

        %% SCALE SPACE SEARCH
        if p.scale_adaptation
            % DSST code
            im_patch_scale = getScaleSubwindow(im, tracker.pos, tracker.base_target_sz, tracker.currentScaleFactor * tracker.scaleFactors, ...
                                                                            tracker.scale_window, tracker.scale_model_sz, p.hog_scale_cell_size);
            xsf = fft(im_patch_scale,[],2);
            scale_response = real(ifft(sum(tracker.sf_num .* xsf, 1) ./ (tracker.sf_den + p.lambda) ));
            recovered_scale = ind2sub(size(scale_response),find(scale_response == max(scale_response(:)), 1));
            %set the scale
            tracker.currentScaleFactor = tracker.currentScaleFactor * tracker.scaleFactors(recovered_scale);

            if tracker.currentScaleFactor < tracker.min_scale_factor
                tracker.currentScaleFactor = tracker.min_scale_factor;
            elseif tracker.currentScaleFactor > tracker.max_scale_factor
                tracker.currentScaleFactor = tracker.max_scale_factor;
            end

            % use new scale to update bboxes for target, filter, bg and fg models
            tracker.target_sz = round(tracker.base_target_sz * tracker.currentScaleFactor);
            avgDim = sum(tracker.target_sz)/2;   
            tracker.bg_area = round(tracker.target_sz + avgDim);
            if(tracker.bg_area(2)>size(im,2)),  tracker.bg_area(2)=size(im,2)-1;    end    
            if(tracker.bg_area(1)>size(im,1)),  tracker.bg_area(1)=size(im,1)-1;    end        

            tracker.bg_area = tracker.bg_area - mod(tracker.bg_area - tracker.target_sz, 2);
            tracker.fg_area = round(tracker.target_sz - avgDim * p.inner_padding);
            tracker.fg_area = tracker.fg_area + mod(tracker.bg_area - tracker.fg_area, 2);

            % Compute the rectangle with (or close to) params.fixedArea and
            % same aspect ratio as the target bboxget_scale_subwindow
            tracker.areaResizeFactor = sqrt(p.fixed_area/prod(tracker.bg_area));
        end               
 
        if p.visualization_dbg==1
            mySubplot(2,1,5,1,im_patch_cf,'FG+BG','gray');
            mySubplot(2,1,5,2,likelihood_map,'obj.likelihood','parula');
            mySubplot(2,1,5,3,response_cf,'CF response','parula');
            mySubplot(2,1,5,4,response_pwp,'center likelihood','parula');
            mySubplot(2,1,5,5,response,'merged response','parula'); 
            drawnow
        end                                          
    end

    %% TRAINING
    % extract patch of size bg_area and resize to norm_bg_area
    im_patch_bg = getSubwindow(im, tracker.pos, p.norm_bg_area, tracker.bg_area);
    % compute feature map, of cf_response_size
    xt = getFeatureMap(im_patch_bg, p.feature_type, p.cf_response_size, p.hog_cell_size);
    % apply Hann window
    xt = bsxfun(@times, tracker.hann_window, xt);        

    % compute FFT
    xtf = fft2(xt);

    %% FILTER UPDATE
    % Compute expectations over circular shifts,
    % therefore divide by number of pixels.
    new_hf_num = bsxfun(@times, conj(tracker.yf), xtf) / prod(p.cf_response_size);
    new_hf_den = (conj(xtf) .* xtf) / prod(p.cf_response_size);

    if is_first
        % first frame, train with a single image
        tracker.hf_den = new_hf_den;
        tracker.hf_num = new_hf_num;
    else
        % subsequent frames, update the model by linear interpolation
        tracker.hf_den = (1 - p.learning_rate_cf) * tracker.hf_den + p.learning_rate_cf * new_hf_den;
        tracker.hf_num = (1 - p.learning_rate_cf) * tracker.hf_num + p.learning_rate_cf * new_hf_num;

        %% BG/FG MODEL UPDATE
        % patch of the target + padding
        [tracker.bg_hist, tracker.fg_hist] = updateHistModel(tracker.new_pwp_model, im_patch_bg, tracker.bg_area, tracker.fg_area, tracker.target_sz, ...
                                                                p.norm_bg_area, p.n_bins, p.grayscale_sequence, tracker.bg_hist, tracker.fg_hist, p.learning_rate_pwp);  
    end

    %% SCALE UPDATE
    if p.scale_adaptation
        % DSST code
        im_patch_scale = getScaleSubwindow(im, tracker.pos, tracker.base_target_sz, tracker.currentScaleFactor*tracker.scaleFactors, ...
                                                    tracker.scale_window, tracker.scale_model_sz, p.hog_scale_cell_size);
        xsf = fft(im_patch_scale,[],2);
        new_sf_num = bsxfun(@times, tracker.ysf, conj(xsf));
        new_sf_den = sum(xsf .* conj(xsf), 1);
        if is_first
            tracker.sf_den = new_sf_den;
            tracker.sf_num = new_sf_num;
        else
            tracker.sf_den = (1 - p.learning_rate_scale) * tracker.sf_den + p.learning_rate_scale * new_sf_den;
            tracker.sf_num = (1 - p.learning_rate_scale) * tracker.sf_num + p.learning_rate_scale * new_sf_num;
        end
    end

    % update bbox position
    if is_first==1
        rect_position = [tracker.pos([2,1]) - tracker.target_sz([2,1])/2, tracker.target_sz([2,1])]; 
    end
    rect_position_padded = [tracker.pos([2,1]) - tracker.bg_area([2,1])/2, tracker.bg_area([2,1])];

    if p.fout > 0,  fprintf(p.fout,'%.2f,%.2f,%.2f,%.2f\n', rect_position(1),rect_position(2),rect_position(3),rect_position(4));   end

    %% VISUALIZATION
    im = insertShape(im, 'Rectangle', rect_position, 'LineWidth', 4, 'Color', 'black');
    im = insertShape(im, 'Rectangle', rect_position_padded, 'LineWidth', 4, 'Color', 'yellow');
    % Display the annotated video frame using the video player object.
    step(p.videoPlayer, im);
end


% We want odd regions so that the central pixel can be exact
function y = floorOdd(x)
    y = 2*floor((x-1) / 2) + 1;
end

function y = ensureReal(x)
    assert(norm(imag(x(:))) <= 1e-5 * norm(real(x(:))));
    y = real(x);
end
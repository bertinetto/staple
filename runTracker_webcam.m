function run_tracker_webcam
% RUN_TRACKER  is the *external* function of the tracker - does configuration and calls THISTRACKER

    %% Read params.txt
    tracker = struct();   
    params = readParams('params.txt');
    params.webcam = true;
    %% init webcam
    params.myWebcam = webcam;
    % Capture one frame to get its size.
    videoFrame = snapshot(params.myWebcam);
    frameSize = size(videoFrame);
    %% set up global variables, changed in key_pressed_fcn
    global BBOXW;
    global BBOXH;
    global BBOXX;
    global BBOXY;    
    global STOPTRACKING;
    global DOTRAINING;
    BBOXW = 200;
    BBOXH = 280;
    BBOXX = (frameSize(2) - BBOXW)/2;
    BBOXY = (frameSize(1) - BBOXH)/2;
    STOPTRACKING = false;
    DOTRAINING = true;    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%par
    % Create the video player object.
    params.videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);    
    frameTraining = 0;
    timeTraining = 0;
    % loop to initialize the tracker on a visible target    
    while DOTRAINING
        bboxGT = [BBOXX BBOXY BBOXW BBOXH];
        % Get the next frame.        
        videoFrame = snapshot(params.myWebcam);
        videoFrame = insertShape(videoFrame, 'Rectangle', bboxGT, 'LineWidth', 4, 'Color', 'red');
        videoFrame = insertText(videoFrame, [40 40], 'Hook the target...', 'FontSize', 30);
        videoFrame = insertText(videoFrame, [40 100], 'W/E: +/- width', 'FontSize', 20, 'BoxColor', 'red');
        videoFrame = insertText(videoFrame, [40 140], 'S/D: +/- height', 'FontSize', 20, 'BoxColor', 'red');
        videoFrame = insertText(videoFrame, [40 180], 'arrows: move the box', 'FontSize', 20, 'BoxColor', 'red');
        videoFrame = insertText(videoFrame, [40 220], 'space: start tracking', 'FontSize', 20, 'BoxColor', 'red');
        videoFrame = insertText(videoFrame, [40 260], 'Q: exit', 'FontSize', 20, 'BoxColor', 'red');
        
        % Display the annotated video frame using the video player object.
        step(params.videoPlayer, videoFrame);
        if frameTraining==0
            set(0, 'ShowHiddenHandles', 'on') % Revert this back to off after you get the handle
            videoPlayerHandle = gcf;
%             ishandle(h)
%             get(h, 'Visible') % will return 'off' if the figure is not visible.
            set(videoPlayerHandle,'KeyPressFcn', @key_pressed_fcn);
        end    
        frameTraining = frameTraining + 1;
        if STOPTRACKING
            return;
        end
    end

    %%
    % init_pos is the centre of the initial bounding box
    cx = BBOXX + BBOXW/2;
    cy = BBOXY + BBOXH/2;
    params.init_pos = [cy cx];
    params.target_sz = [BBOXH BBOXW];

    [params, tracker.bg_area, tracker.fg_area, tracker.areaResizeFactor] = initializeAllAreas(videoFrame, params);

	% in run_tracker we do not output anything because it is just for debug
	params.fout = -1;  
    
    init_rect = [BBOXY BBOXX BBOXH BBOXW];
    rect = init_rect;
    prevpad = 0;
    frame = 1; 
    
    while ~STOPTRACKING
        % pad = round(rand() * 100);
        pad = 0;
        diff = pad - prevpad;
        rect = rect + diff;

        im = snapshot(params.myWebcam);        
        im=padarray(im,[pad pad], NaN);

        prevpad = pad;

        [tracker, rect] = track(im, tracker, rect, frame, params);
        frame = frame + 1;
    end
    
    %% define cleanup in case of interrupt
    finishup = onCleanup(@() myCleanupFun(params));    
    % close all open files    
    fclose('all');
end

function [tracker, obj_rect] = track(im, tracker, rect, frame, params)
    if frame==1
        [tracker] = initTracker_webcam(im, tracker, params);
        obj_rect = rect;
    else
        [tracker, obj_rect] = updateTracker_webcam(im, tracker, false, params);
    end
end

function key_pressed_fcn(fig_obj,eventDat)
    
    % get the global variables
    global STOPTRACKING;
    global DOTRAINING; 
    global BBOXW;
    global BBOXH;
    global BBOXX;
    global BBOXY;    
    
    pressedKey = get(fig_obj, 'CurrentKey');
   
    switch pressedKey
        case 'space'
            disp('Stop training, start tracking.');
            DOTRAINING = false;
        case 'q'
            disp('STOP.');
            STOPTRACKING = true;
        case 'w'
            BBOXW = BBOXW + 6;
        case 'e'
            BBOXW = BBOXW - 6;
        case 's'
            BBOXH = BBOXH + 6;
        case 'd'
            BBOXH = BBOXH - 6;
        case 'rightarrow'
            BBOXX = BBOXX + 6;
        case 'leftarrow'
            BBOXX = BBOXX - 6;
        case 'downarrow'
            BBOXY = BBOXY + 6;
        case 'uparrow'
            BBOXY = BBOXY - 6;
    end
end
function runTracker_VOT(hp_name, hp_value)
%RUN_TRACKER_VOT executes the tracker within the evaluation of the VOT toolkit

    %% Read params.txt
	if nargin>0
		% hyperparams mode
	    params = readParams('params.txt', hp_name, hp_value);
	else
		% normal mode
		params = readParams('params.txt');
	end

    %% Read files
    fid = fopen('images.txt','r'); 
    inter = textscan(fid,'%[^\n]'); 
    params.img_files = inter{1,1};
    im = imread(params.img_files{1});
    fclose(fid);

    % check if sequence is grayscale
    if(size(im,3)==1)
        params.grayscale_sequence = true;
    end

    params.bb_VOT = csvread('region.txt');
    region = params.bb_VOT(1,:);
    params.img_path = '';
    % save sequence name
    C = strsplit(params.img_files{1},'/');
    if ~isempty(C)
        params.sequence = C{end-1};
    else
        params.sequence = 'error_sequence_not_detected';
    end
    %% Convert to axis-aligned bbox
    if(numel(region)==8)
        % polygon format
        [cx, cy, w, h] = getAxisAlignedBB(region);
    else
        x = region(1);
        y = region(2);
        w = region(3);
        h = region(4);
        cx = x+w/2;
        cy = y+h/2;
    end

    % init_pos is the centre of the initial bounding box
    params.init_pos = [cy cx];
    params.target_sz = round([h w]);

    [params, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, params);

    params.fout = fopen('output.txt','w');

    % start actual tracking
    trackerMain(params,im, bg_area, fg_area, area_resize_factor);
    fclose('all');
    % within VOT benchmark the tracker has to terminate at the end of each sequence
    exit
end

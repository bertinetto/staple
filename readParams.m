function params = readParams(params_file_name, hp_name, hp_value)
% read params.txt and convert into struct
	fparams = fopen(params_file_name);
	C = textscan(fparams, '%s', 'Delimiter', '', 'CommentStyle', '%');
	fclose(fparams);
	% feed the lines one by one into eval to create the variables in the MATLAB workspace:
	cellfun(@evalc, C{1}, 'UniformOutput', false);
	% clear all the variables not in the params file
	clear C fparams
	% save current workspace in a struct
	this_workspace = evalin('caller','who');
	% save everything in a struct
	for i=1:size(this_workspace,1)
	    thisvar=evalin('caller', this_workspace{i});
	    params.(this_workspace{i})=thisvar;
	end

	if(isfield(params,'ans'))
	    rmfield(params,'ans');
    end

    if nargin>1
        % if hyperparam is set: override default parameters with specified one
        params.(hp_name) = hp_value;
    end
end

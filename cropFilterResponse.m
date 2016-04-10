function new_response = cropFilterResponse(response_cf, response_size)
%CROPFILTERRESPONSE makes RESPONSE_CF of size RESPONSE_SIZE (i.e. same size of colour response)

    [h,w] = size(response_cf);
    b = response_size(1);
    a = response_size(2);

    % a and b must be odd, as we want an exact center
    if ~all_odd([a, b])
        error('dimensions must be odd');
    end
    half_width = floor(a/2);
    half_height = floor(b/2);

    new_response = response_cf(...
        mod_one(-half_height:half_height, h), ...
        mod_one(-half_width:half_width, w));
end

function y = mod_one(a, b)
    y = mod(a-1, b)+1;
end

function y = all_odd(x)
    y = all(mod(x, 2) == 1);
end

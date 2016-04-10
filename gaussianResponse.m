function y = gaussianResponse(rect_size, sigma)
%GAUSSIANRESPONSE create the (fixed) target response of the correlation filter response
    half = floor((rect_size-1) / 2);
    i_range = -half(1):half(1);
    j_range = -half(2):half(2);
    [i, j] = ndgrid(i_range, j_range);
    i_mod_range = mod_one(i_range, rect_size(1));
    j_mod_range = mod_one(j_range, rect_size(2));
    y = zeros(rect_size);
    y(i_mod_range, j_mod_range) = exp(-(i.^2 + j.^2) / (2 * sigma^2));
end

function y = mod_one(a, b)
    y = mod(a-1, b)+1;
end

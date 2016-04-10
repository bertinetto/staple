function im_patch = getSubwindow(im, pos, model_sz, scaled_sz)
%GET_SUBWINDOW Obtain image sub-window, padding is done by replicating border values.
%   Returns sub-window of image IM centered at POS ([y, x] coordinates),
%   with size MODEL_SZ ([height, width]). If any pixels are outside of the image,
%   they will replicate the values at the borders

% with 3 input, no scale. With 4 params, scale adaptation
if nargin < 4, sz = model_sz;   
else, sz = scaled_sz;    
end

%make sure the size is not to small
sz = max(sz, 2);
%if sz(1) < 1, sz(1) = 2; end;
%if sz(2) < 1, sz(2) = 2; end;

%xs = floor(pos(2)) + (1:sz(2)) - floor(sz(2)/2);
%ys = floor(pos(1)) + (1:sz(1)) - floor(sz(1)/2);
xs = round(pos(2) + (1:sz(2)) - sz(2)/2);
ys = round(pos(1) + (1:sz(1)) - sz(1)/2);

%check for out-of-bounds coordinates, and set them to the values at
%the borders
xs(xs < 1) = 1;
ys(ys < 1) = 1;
xs(xs > size(im,2)) = size(im,2);
ys(ys > size(im,1)) = size(im,1);

%extract image
im_patch_original = im(ys, xs, :);

% (if rescaling is introduced) resize image to model size
% im_patch = imresize(im_patch, model_sz, 'bilinear');
if nargin>=4
%     im_patch = mexResize(im_patch_original, model_sz, 'auto');
    im_patch = mexResize(im_patch_original, model_sz, 'auto');
else
    im_patch = im_patch_original;
end

end


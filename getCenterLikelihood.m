function center_likelihood = getCenterLikelihood(object_likelihood, m)
%GETCENTERLIKELIHOOD computes the sum over rectangles of size M.
% CENTER_LIKELIHOOD is the 'colour response'
    [h,w] = size(object_likelihood);
    n1 = h - m(1) + 1;
    n2 = w - m(2) + 1;

    %% integral images
    % compute summed area table
%     SAT = zeros(h, w);
%     for y=1:h
%         for x=1:w
%             if x>1, SAT_left = SAT(y,x-1);
%             else    SAT_left = 0; end
%             if y>1, SAT_up = SAT(y-1,x);
%             else    SAT_up = 0; end
%             if y>1 && x>1, SAT_left_up = SAT(y-1,x-1);
%             else    SAT_left_up = 0; end
%
%             SAT(y,x) = object_likelihood(y,x) + SAT_left + SAT_up - SAT_left_up;
%         end
%     end
%     SAT = padarray(SAT,[1 1], 'pre');

%% equivalent MATLAB function
    SAT = integralImage(object_likelihood);
    i = 1:n1;
    j = 1:n2;
    center_likelihood = (SAT(i,j) + SAT(i+m(1), j+m(2)) - SAT(i+m(1), j) - SAT(i, j+m(2))) / prod(m);
end

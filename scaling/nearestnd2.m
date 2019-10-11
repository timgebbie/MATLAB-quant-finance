function [N,h,x] = nearestnd2(d,p,n)
% NEARESTND2 Next-nearest neighbour distance
%
% [N,H,X] = NEARESTND2(D,P,N) THe next-nearest neighbour distance
% is found from vector D, the eigenvalues vector, and P 
% the order and N the number of sample points. N and H are
% from PDF(X) and X points.
%
% See Also: UNFOLDING2, BROADENING

% $ Author Tim Gebbie

% the unfolding procedure
[pxi,xi,x] = unfolding2(d,10);
% find the differences
N = length(d) * (xi(p+1:end) - xi(1:end-p));
% create the histogram
[h,x]=broadening(N,24);

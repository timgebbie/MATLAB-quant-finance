function [nd,h,x] = nearestnd(d,p)
% NEARESTND Next-nearest neighbour distance
%
% [NNDIST,PDF,X] = NEARESTND(D,P,N) The next-nearest neighbour distance
% is found from vector D, the eigenvalues vector, and P 
% the order and N the number of sample points. 
%
% See Also: UNFOLDING, KSDENSITY

% $ Author Tim Gebbie

% the unfolding procedure
[pxi,xi,x] = unfolding(d);
% find the differences
nd = length(d) * (xi(p+1:end) - xi(1:end-p));
% create the histogram
[h,x] = ksdensity(nd,nd,'function','pdf');

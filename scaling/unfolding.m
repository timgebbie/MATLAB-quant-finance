function [dpdf,dcdf,xi] = unfolding(d)
% [PDF,CDF,X] = UNFOLDING(D) Unfolding of eigenvalues
%
% Here D is the vector of eigenvalues. Unfold eigenvalues to scaling 
% that is in units of the average eigenvalue spacing using Guassian
% broadening.
%
% See Also: KSDENSITY

% $ Author Tim Gebbie

% FIXME use gaussian broadening to find the pdf and cdf
[dpdf,xi] = ksdensity(d,d,'function','pdf');
% FIXME create the cdf by integrating the pdf
[dcdf,xi] = ksdensity(d,xi,'function','cdf');
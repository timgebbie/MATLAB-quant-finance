function [dpdf,dcdf,x] = unfolding2(d,w),
% [PDF,CDF,X] = UNFOLDING2(D,W) Unfolding of eigenvalues
%
% Here D is the vector of eignevalues and W is the
% window size for the gaussian broadening scheme.
% Unfold eigenvalues to scaling that is in units of the
% average eigenvalue spacing
%
% See Also: BROADENING, CUMINEGRATE

% $ Author Tim Gebbie

% use gaussian broadening to find the pdf and cdf
[dpdf,x]=broadening(d,w);
% create the cdf by integrating the pdf
dcdf = cumintegrate(dpdf,x);
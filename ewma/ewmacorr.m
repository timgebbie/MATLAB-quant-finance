function [rf,vf,mf]=ewmcorr(varargin)
% EWMACORR exponentially weighted moving average correlation coefficients
%
% [C,V,M] = EWMACORR(X,LAMBDA,INIT_CORR) Find the EWMA correlation matrices
% give the input matrix X. The outputs are correlation matrix C and 
% variance V and means M.
% 
% [C,V,M] = EWMACORR(X,LAMBDA) Find the EWMA correlations with LAMBDA
% between 0 and 0.9999.
%
%  R(i,j)_t = LAMBDA * R(i,j)_{t-1} + (1-LAMBDA) * X(i)_{t-1} * X(j)_{t-1};
%
% See Also: EWMACOV

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $

switch nargin
    case 1
        x      = varargin{1};
        lambda = 0.98;        % weighting coefficient
    case 2
        x      = varargin{1};
        lambda = varargin{2}; % weighting coefficient
    otherwise
        error('Input error');
end
  
  % initialize the filter
  v0=cov(x); m0=mean(x);
  % find the variances
  [c0,c,m] = ewmacov(x,lambda,v0,m0);
  % get the initial means
  mf = m(end,:);
  % construct the initial correlation matrix
  [vf,rf] = cov2corr(c0);
 
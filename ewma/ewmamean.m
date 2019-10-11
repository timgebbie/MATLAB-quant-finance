function [m0,m]=ewmamean(varargin)
% EWMAMEAN Exponentially weighted moving average mean estimator
%
% [M0,M]=EWMAMEAN(X) Uses an exponentially weighted moving average 
% to estimate the correlation. Default LAMBDA is 0.98.
%
% [M0,M]=EWMAMEAN(X,LAMBDA) Uses an exponentially weighted moving average 
% to estimate the correlation. For LAMBDA between 0 and 1.
%
% See Also : EWMACOV, EWMACORR, EWMAACORR

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $

switch nargin
    case 1
        x   = varargin{1};
        lambda  = 0.98;
    case 2
        x   = varargin{1};
        lambda = varargin{2};;
    otherwise
        error('Incorrect Input Arguments');
end

% estimate the covariance and the mean and initialized with cov and mean
[c0,c,m]=ewmacov(x,lambda);

% the last entry ensure that it is empty if m is empty
if ~isempty(m), m0 = m(end,:); else, m0 = []; end
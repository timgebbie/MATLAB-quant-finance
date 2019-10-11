function [v0,v,m]=ewmavar(varargin)
% EWMAVAR exponentially weighted moving average variance
%
% [C0,C,M] = EWMAVAR(X) Uses an exponentially weighted moving average to 
% estimate the variance. Following the convention of using LAMBDA = 0.98 
% as the coefficient unless specified. Here X_t is the input at time t:
%
%   H_t = LAMBDA * H_{t-1} + (1-LAMBDA) X_{t-1}^2
%   M_t = LAMBDA * M_{t-1} + (1-LAMBDA) X_{t-1}
%
% [C0,C,M] = EWMAVAR(X,LAMBDA) Uses LAMBDA as a number between 0 and 0.999.
%
% See Also: EWMACOV, EWMAMEAN, EWMACORR

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $

% Notes :
%
% If this used iteratively then the input x is not demeaned. 
% If X has a length > 1 it will be demeanded using EWMAMEAN.
%

switch nargin
case 1
    x      = varargin{1}; 
    lambda = 0.98;
case 2
    x      = varargin{1};
    lambda = varargin{2}; 
otherwise
    error('Incorrect Input Arguments');
end

% get the estimated covariance and mean (initialize with cov and mean)
[c0,c,m] = ewmacov(x,lambda);
% find the variance
for i=1:size(c,3), v(i,:) = transpose(diag(c(:,:,i))); end;
% find the variance from the diagonal
 v0 = diag(c0);
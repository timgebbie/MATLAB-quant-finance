function fts=ewmavar(varargin)
% @FINTS/EWMAVAR exponentially weighted moving average variance
%
% V = EWMAVAR(X) Uses an exponentially weighted moving average to 
% estimate the variance. Following the convention of using LAMBDA = 0.98 
% as the coefficient unless specified. Here X_t is the input at time t:
%
%   H_t = LAMBDA * H_{t-1} + (1-LAMBDA) X_{t-1}^2
%   M_t = LAMBDA * M_{t-1} + (1-LAMBDA) X_{t-1}
%
% V = EWMAVAR(X,LAMBDA) Uses LAMBDA as a number between 0 and 0.999.
%
% See Also: EWMACOV, EWMAMEAN, EWMACORR, FINTS

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

% Notes :
%
% If this used iteratively then the input x is not demeaned. 
% If X has a length > 1 it will be demeanded using EWMAMEAN.
%

switch nargin
case 1
    fts      = varargin{1}; 
    lambda = 0.98;
case 2
    fts      = varargin{1};
    lambda = varargin{2}; 
otherwise
    error('Incorrect Input Arguments');
end

% get the estimated covariance and mean (initialize with cov and mean)
[c0,c,m] = ewmacov(fts,lambda);
% find the variance
for i=1:size(c,3), v(i,:) = transpose(diag(c(:,:,i))); end;
% assign the output data
fts.data{4} = v;
% assign the output description
fts.data{1} = sprintf('EWMA: %s',fts.data{1});
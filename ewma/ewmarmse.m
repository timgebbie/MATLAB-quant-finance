function [rmse,mse] = ewmarmse(varargin)
% EWMARMSE Exponetially weights moving average root-mean square error
%
% [RMSE,MSE] = EWMARMSE(YHAT,YTILDE) EWMA Root-mean square error of
% the measured data YTILDE with respect to the estimated data YHAT.
% LAMBDA is by default 0.98.
%
% [RMSE,MSE] = EWMARMSE(YHAT,YTILDE,LAMBDA) LAMBDA is a number between
% 0 and 1.
%
% RMSE = sqrt(E[(YHAT-YTILDE)^2]) 
%
% See Also: EWMAMEAN, EWMACOV

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $

switch nargin
    case 2
        yhat = varargin{1};
        ytilde = varargin{2};
        lambda = 0.98;
    case 3
        yhat = varargin{1};
        ytilde = varargin{2};
        lambda = varargin{3};
    otherwise
        error('Incorrect Input Arguments');
end

% root mean square error
x     = (yhat - ytilde).^2;
% EWMA mean to find mean-square error
mse   = ewmamean(x,lambda);
% find the root mean square error
rmse  = sqrt(mse);
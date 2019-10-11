function [varargout] = ewmacov(varargin)
% @FINTS/EWMACOV Recursive mean and covariance estimator with forgetting factor
%
%    [C, S, M] = EWMACOV(FTS, LAMBDA, ICOV, IMEAN) Recursively estimates the mean
%    M and the covariance S of the data Y using the forgetting factor LAMBDA
%    and the initial mean IMEAN and covariance ICOV. C is the last entry of S
%    which is the current best estimate of the EWMA covariance.
%
%    [C, S, M] = EWMACOV(FTS, LAMBDA) Same as above but takes the the initial mean
%    and covariance as the mean and covariance of Y.
%
%    Alternative output forms are:
%        [S, M] = EWMACOV(...)
%        [C]    = EWMACOV(...)
%
%    If LAMBDA = [], i.e., is empty then the default LAMBDA = 0.98. As LAMBDA
%    tends to 1 it will recover the usual estimator (use LAMBDA = 0.99999).
%
%    Uses an exponentially weighted moving average to estimate the
%    covariance.
%
%        M(n+1)    = Lambda*M(n) + (1-Lambda)*Y(n)
%         i                  i                 i
%
%        S(n+1)    = Lambda*S(n) + (1-Lambda)*(Y(n) -  M(n))*(Y(n) -  M(n))
%         i,j                i,j                i       i      j       j
%
%       where M is the mean and S is the covariance
%
% NOTE: Requires the EWMACOV toolbox
%
% See Also : FINTS, EWMACOV

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

% get the data
fts    = varargin{1};
data   = fts.data{4};
data(isnan(data))=0;

switch nargin
case 1
  lambda = [];
  s0     = cov(data);
  m0     = mean(data);
case 2
  lambda = varargin{2};
  s0     = cov(data);
  m0     = mean(data);
case 4
  lambda = varargin{2};
  s0     = varargin{3};
  m0     = varargin{4};
otherwise
  error('Incorrect number of input arguments.');
end;

switch nargout
case 0
  varargout{1} = ewmacov(data,lambda,s0,m0);
case 1
  varargout{1} = ewmacov(data,lambda,s0,m0);
case 2
  % assign moving average
  [data, fts.data{4}] = ewmacov(data,lambda,s0,m0);
  varargout{2} = fts;
  varargout{2}.data{1} = sprintf('EWMA: %s',fts.data{1});
  % assign variance
  if (size(data,1)==1),
      fts.data{4}  = squeeze(data(1,:,:));
      fts.data{1}  = sprintf('EWMA: %s',fts.data{1});
      varargout{1} = fts;
  elseif (size(data,2)==1),
      fts.data{4}  = squeeze(data(:,1,:));
      fts.data{1}  = sprintf('EWMA: %s',fts.data{1});
      varargout{1} = fts;
  else
      varargout{1} = data;
  end;
case 3
  [varargout{1}, data, fts.data{4}] = ewmacov(data,lambda,s0,m0);
  % assign moving average
  varargout{3} = fts;
  varargout{3}.data{1} = sprintf('EWMA: %s',fts.data{1});
  % assign variance
  if (size(data,1)==1),
      fts.data{4}  = squeeze(data(1,:,:));
      fts.data{1}  = sprintf('EWMA: %s',fts.data{1});
      varargout{2} = fts;
  elseif (size(data,2)==1),
      fts.data{4}  = squeeze(data(:,1,:));
      fts.data{1}  = sprintf('EWMA: %s',fts.data{1});
      varargout{2} = fts;
  else
      varargout{2} = data;
  end; 
  varargout{3} = fts;
otherwise
  error('Too many output arguments.');
end;
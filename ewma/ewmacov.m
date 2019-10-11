function [out1,out2,out3] = ewmacov (varargin)
%EWMACOV Recursive mean and covariance estimator with forgetting factor
%
%    [C, S, M] = EWMACOV(Y, LAMBDA, ICOV, IMEAN) Recursively estimates the mean
%    M and the covariance S of the data Y using the forgetting factor LAMBDA
%    and the initial mean IMEAN and covariance ICOV. C is the last entry of S
%    which is the current best estimate of the EWMA covariance.
%
%    [C, S, M] = EWMACOV(Y, LAMBDA) Same as above but takes the the initial mean
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

% Author: Tim Gebbie 

% Developer notes: This is based on conversations with J. Solms.

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $

switch nargin
case 1
  y      = varargin{1};
  lambda = [];
  s0     = cov(y);
  m0     = mean(y);
case 2
  y      = varargin{1};
  lambda = varargin{2};
  s0     = cov(y);
  m0     = mean(y);
case 4
  y      = varargin{1};
  lambda = varargin{2};
  s0     = varargin{3};
  m0     = varargin{4};
otherwise
  error('Incorrect number of input arguments.');
end;

% Check for empty
if isempty(y),
  out1=[];
  out2=[];
  out3=[];
  return;
end;

%% Default lambda
if isempty(lambda), lambda = 0.98; end;
if length(lambda) ~= 1, error('Lambda must be a scalar.'); end;
[p,q] = size(y);
%% Special vectorisation matrices
lambda_col = lambda .^ transpose(p-1:-1:0);
lambda_mat = repmat(lambda_col, 1, q);
lambda_mat_mat = repmat(lambda_mat, 1, q);
%% Compute the mean
if p>1, M0 = repmat(m0, p, 1); else M0 = m0; end;
m =   lambda*flipud(lambda_mat).*M0 + (1-lambda)* cumsum(lambda_mat .* y,1)./lambda_mat;
%% Remove the mean
ym = y - m;
%% Special column ordering for computing covariances in columns
i2 = repmat(1:q, 1, q);
i1 = sort(i2);
y1 = ym(:,i1);
y2 = conj(ym(:,i2));
%% Compute covariances
if p > 1, S0 = repmat(transpose(s0(:)), p, 1); else S0 = transpose(s0(:)); end;
s =  lambda*flipud(lambda_mat_mat(:,:)).*S0 + (1-lambda)*cumsum(lambda_mat_mat .* y1.*y2,1)./lambda_mat_mat(:,:);
%% the output array
S = reshape(transpose(s), q, q, p);
%% Return only last values
% m = m(end,:);
C = transpose(reshape(s(end,:),q,q));

switch nargout
case 0
  out1 = C;
case 1
  out1 = C;
case 2
  out1 = S;
  out2 = m;
case 3
  out1 = C;
  out2 = S;
  out3 = m;
otherwise
  error('Too many output arguments.');
end;


%% Alternative faster repmat function
function y = repmat(x, m, n)
[p,q]= size(x);
r = mod((1:(p*m))-1, p)+1;
s = mod((1:(q*n))-1, q)+1;
y = x(r,s);

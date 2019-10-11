function Y = epsclean(varargin)
%epsclean Sets nearly zero values to zero.
%
%    ESPCLEAN(X) Applies the test ABS(X(i,j)) < EPS to set the values of X
%    that meet this criterion to zero. EPS is the floating point relative
%    accuracy, i.e, the distance from 1.0 to the next largest floating point
%    number.
%
%    ESPCLEAN(X,N) Applies the test ABS(X(i,j)) < N*EPS instead.
%

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:51:18 $ $Author: Tim Gebbie $
switch nargin
case 1
  X = varargin{1};
  N = 1;
case 2
  X = varargin{1};
  N = varargin{2};
otherwise
end;
Y = X.*(abs(X) >= N*eps);
return

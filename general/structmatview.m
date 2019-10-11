function Y = structmatview(varargin)
%epsclean Sets nearly zero values to zero.
%
%    STRUCTMATVIEW(X) Applies the test ABS(X(i,j)) < EPS to set the values of X
%    that meet this criterion to zero. EPS is the floating point relative
%    accuracy, i.e, the distance from 1.0 to the next largest floating point
%    number.
%
% See Also: STRUCTFTSVIEW

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

for i=1:size(varargin{1},2),
   openvar(varargin{1}{i}); 
end
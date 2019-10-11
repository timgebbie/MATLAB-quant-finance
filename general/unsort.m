function x = unsort(y,I)
% UNSORT unsort a matrix given the sort index.
%
% [X,iI] = UNSORT(Y,I) inverse of sort where 
% Y = X(I) from [Y,I]=sort(X), and X = Y(iI).
%
% See also: SORT

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

[n,m]=size(I);
% invert the sorting index
for i=1:m, for j=1:n, iI(I(j,i),i)=j; end; end;
% construct the unsorted output variable
for j = 1:m, x(:,j) = y(iI(:,j),j); end;
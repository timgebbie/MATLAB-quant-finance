function [n,x]=intnumber(x,int)
% INTNUMBER Generate the interval number list
%
% [N,X] = INTNUMBER(X,INT) From eigenvalues X
% and i-th interval size INT, for vector INT
% find all the elements of X in i-th interval.
% N is the number of elements in i-th interval.
%
% See Also: TWOPOINT

% $ Author Tim Gebbie

% generate the interval list

% find the number of x's in INT
minx = x - int/2;
maxx = x + int/2;
for i=1:length(x),
  n(i)=sum( x>=minx(i) & x <= maxx(i)); 
end
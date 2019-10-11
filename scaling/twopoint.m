function [s,int]=twopoint(x),
% TWOPOINT The number of eigenvalues in each interval
%
% [S,L] = TWOPOINT(X)
%
% See Also: INTNUMBER

% $ Author Tim Gebbie

% the interval sizes
int = eps:0.01:10;
% the number of eigenvalues in each interval
for i=1:length(int),
  [n,x] = intnumber(x,int(i));
  s(i) = mean(((n-int(i)).^2));
end;
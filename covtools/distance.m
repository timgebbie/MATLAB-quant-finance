function Y = distance(X,s)
% DISTANCE Pairwise distance between observations.
%
%   Y = DISTANCE(X,METRIC) returns a vector which contains all the
%   distances between each pair of observations in X computed using
%   the given METRIC.  
%
%   X is a M by N matrix, treated as M observations of N objects. 
%   Since there are M*(M-1)/2 pairs of objects in X, the size of 
%   Y is M*(M-1)/2 by 1. 
%
%      'euclid'         --- Euclidean
%      'mahal'          --- Mahalanobis metric
%      'corr-ewma'      --- Correlation distance using ewmacov
%      'corr-clean'     --- Correlation distance using cleancov 
%      'corr'           --- Correlation distance 
%
%   The output Y is arranged in the order of ((1,2),(1,3),..., (1,M),
%   (2,3),...(2,M),.....(M-1,M)).  i.e. the upper right triangle of
%   the M by M square matrix. To get the distance between observation
%   i and observation j, either use the formula Y((i-1)*(M-i/2)+j-i)
%   or use the helper function Z = SQUAREFORM(Y), which will return a
%   M by M symmetric square matrix, with Z(i,j) equaling the distance
%   between observation i and observation j.

% $ Author Tim Gebbie

% n observations of m objects
[n, m] = size(X);
% must be at least two objects
if m < 2, error('Must be at least two objects'); end;

switch s
case 'euclid' % Euclidean
   Y = vectdiff(X');
   Y = sum(Y.^2,1);
   Y = sqrt(Y);
case 'mahal' % Mahalanobis
   Y = vectdiff(X');
   v = inv(cov(X')); % cross-sectional covariance (correlated variability)
   Y = sqrt(sum((v*Y).*Y,1));
case 'corr-ewma' % exponetially weight moving average cov with NaN's
          v = ewmacov(X); 
    [std,c] = cov2corr(v); 
          Y = 1 - c; % correlation distance matrix
          Y = utri2vect(Y);
case 'corr-clean' % clean covariance
  if (sum(sum(isnan(X)))>=1),
    v = nancov(X);
    v = cov2clean(v,length(X));
  else
    v = cleancov(X);
  end
    [std,c] = cov2corr(v); 
          Y = 1 - c; % correlation distance matrix
          Y = utri2vect(Y);
case 'corr' % clean correlations
          v = nancov(X);
    [std,c] = cov2corr(v);
          Y = 1 - c; % correlation distance matrix
          Y = utri2vect(Y);
otherwise
   error('no such method.');
end

% helper function dist to find order upper triangular part
function d=utri2vect(X)
[m,n]=size(X);
for i=1:n-1, 
  for j=i+1:n,
    d((i-1)*(m-i/2)+j-i) = X(i,j); 
  end
end

function [Y,I,J]=vectdiff(X)
% n observations of m objects
[m, n] = size(X);
% reference defining all the pair of objects
p = (m-1):-1:2;
I = zeros(m*(m-1)/2,1);
I(cumsum([1 p])) = 1;
I = cumsum(I);
J = ones(m*(m-1)/2,1);
J(cumsum(p)+1) = 2-p;
J(1)=2;
J = cumsum(J);
% the difference matrix between all object measurements
Y = (X(I,:)-X(J,:))';

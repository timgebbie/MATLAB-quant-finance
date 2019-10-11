function [F,x]=cumintegrate(f,x)
% CUMINTEGRATE Cumulative integral of F(X)
%
% CI = CUMINTEGRATE(F,X) For range F and domain X
%
%        X(i)=X(j)
% CI(j) = Sum f(X_i- 0.5 * dX_i) dX_i
%        i=1
%
% for dX_i = (X_i - X_i-1)
%

% $ Author Tim Gebbie

% sort input arguments
[x,i]=sort(x);
% sort the function
f = f(i);
% find the infinitesimal for the integration
h = x(2:end) - x(1:end-1);
% use trapezoidal rule 
fh = 0.5*(f(1:end-1) + f(2:end));
% sum the functions f along the mid points to find normalization
nh = fh(:) .* h(:);
% cumsum the areas under the curve
F = cumsum(nh);
% ensure that the normalization of the total area is one
% F = F ./ F(end);

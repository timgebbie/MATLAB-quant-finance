function I=integrate(f,x)
% INTEGRATE Numerical integration using using trapeziodal rule
%
% I = INTEGRATE(F,X) For data matrix domain X and function
% range values F the function is integrated to find I
%
%       N
% I = Sum f(X_i- 0.5 * dX_i) dX_i
%     i=1
%
% for dX_i = (X_i - X_i-1)
%
% See Also:

% $ Author Tim Gebbie

% sort input arguments
[x,i]=sort(x);
% sort the function
f = f(i);
% find the infinitesimal for the integration
h = x(2:end) - x(1:end-1);
% use trapezoidal rule 
fh = 0.5*(f(1:end-1) + f(2:end));
% sum the functions f along the mid points
I = sum(fh .* h);
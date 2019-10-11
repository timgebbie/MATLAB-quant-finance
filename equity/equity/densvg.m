function y = densvg(x,sigma, nu, theta)
% DENSVG CGM Variance Gamma Model density function
%
% Y = DENSVG(X,SIGMA,NU,THETA) compute the density functions at X for
% parameters SIGMA, the variance, NU the jumps, THETA the drift.
%
% See page 51 notes 
%
% Example 1:
%
% >> sigma = 0.2;
% >> nu = 0.9
% >> theta = -0.2
% >> densvg(x,sigma,nu,theta)
%
% See Also : GAMMA, BESSELK

% Author: Tim Gebbie 2006

% Modified bessel function of 3rd kind (sometimes use called 2nd kind)
C = 1/nu;
G = (sqrt( theta^2 * nu^2/4 + sigma^2 * nu/2) - theta * nu/2 )^(-1);
M = (sqrt( theta^2 * nu^2/4 + sigma^2 * nu/2) + theta * nu/2 )^(-1);
y = ((G * M)^C) / ( sqrt(pi) * gamma(C)) * exp( (G-M) * x/2) .*  ... 
    (abs(x) /(G+M)) .^(C - 0.5) .* Besselk(C-0.5+eps,(G+M) * abs(x)/2);

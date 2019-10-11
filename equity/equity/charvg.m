function phi = charvg(u,sigma, nu, theta)
% CHARVG CGM Variance Gamma Model characteristic function
%
% Y = CHARVG(U,SIGMA,NU,THETA) compute the characteristic functions at U for
% parameters SIGMA, the variance, NU the jumps, THETA the drift.
%
% See page 51 notes 
%
% Example 1:
%
% >> sigma = 0.2;
% >> nu = 0.9
% >> theta = -0.2
% >> charvg(u,sigma,nu,theta)
%
% See Also :

% Author: Tim Gebbie 2006

% See pg 65 notes Wim Schouten
phi = (1 - I * u * theta * nu + sigma^2 * nu * (u .* u) / 2)^(1/nu);
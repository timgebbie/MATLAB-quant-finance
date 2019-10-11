function [rho,lambda,lmax,lmin] = eigendensity(Q,pvar),
% EIGENDENSITY Find the analytic expected density of eigenvalues  
%
% [RHO,L,LMAX,LMIN]=EIGENDENSITY(Q,PVAR) RHO(L) is found from the 
% domain of eigenvalues for a data matrix with N data points and M
% objects give Q the quality factor. The average eigenvalue is PVAR.
% 
% Example : 
%   [N,M]   = size(data);
%   [V,D,s] = condeig(cov(data));
%   PVAR    = mean(diag(D));
%
% See also: CLEANCOV

% $ Author : Tim Gebbie 
  
% the number of data points    (length) N 
% and the number of securities (width)  M
% Q = n/m; % quality ratio
% upper and lower random matrix eigenvalues
lmax = pvar * ( 1 + (1/Q) + 2 * sqrt(1/Q));
lmin = pvar * ( 1 + (1/Q) - 2 * sqrt(1/Q));
% find the domain
lambda = lmin: 0.001*(lmax - lmin):lmax;
% scalling factor
s1 = (Q / (2  * pi * pvar));
% functional factor
s2 =  sqrt( (lmax - lambda) .* (lambda - lmin)) ./ lambda;
% density of eigenvalues
rho = s1 * s2;

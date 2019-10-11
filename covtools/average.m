function [g,X]=average(X,h)
% [G,X]=AVERAGE(X,h)
%
% function to normalize and remove the market mode
% of financial data through recursive averaging.
%
%   iterate in k until convergence
%
%  x_i(2k+1,t) = (x_i(2k,t) - r_i(2k))/s_i(2k)
%  x_i(2k+2,t) = (x_i(2k+1,t)-R_i(2k+1))/S_i(2k+1)
%
% Here:
%       <...> = sum_t ... /T  - time 
%       |...| = sum_i ... /A  - assets
%   and
%       s_i = sqrt((<x_i(2k,t)-<x_(2k,t)>)^2>)
%       R_i = sqrt((|x_i(2k,t)-|x_(2k,t)||^2>)
%
% time and state averageing K times. Default is
% until convergence in norm.

% $ Author Tim Gebbie

 % store original data
 g=X; 
 % remove NaN's
 g(isnan(g))=0;
 % get the size of the data block   
 [m,n]=size(g);  
 % initialize
 converged = logical(0); e1 = 0; k = 1;
 % warnings off
 warning off;
 % infinite k
 if ~exist('h','var') | isempty(h), h=1e+20; end;
 % remove market mode and normalize through iterated averaging
 while ~converged 
  % time averaging
  m1 = repmat(nanmean(g),m,1); % remove mean
  s1 = repmat(nanstd(g),m,1); % normalize
  g1 = (g - m1) ./ s1;
  % state averaging
  m2 = repmat(nanmean(g1')',1,n);
  s2 = repmat(nanstd(g1')',1,n);
  g2 = (g1 - m2) ./ s2;
  % ensure that NaN's are removed
  g2(isnan(g2)) = 0;
  % calculate residual 
  e2 = nanmean(nanmean(abs(g2-g)));
  % check for cauchy convergence 
  if e2 < eps, converged = logical(1); end;
  if k==h, converged = logical(1); else k=k+1; end;
  % update the residuals
  e1=e2;
  % update the data
  g = g2;
 end
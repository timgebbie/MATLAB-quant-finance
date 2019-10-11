function [lc,s,ns,cs,gs] = slikelihood(varargin)
% SLIKELIHOOD Structure Log-likelihood function of structure S 
%
% [LC,S,NS,CS,GS] = slikelihood(X,S)
%
% S is a sparse matrix with non-zero rows of length 
% NS and M columns. The number of columns give the
% the number of objects and the number of elements 
% that are non-zero in each column gives the number 
% of elements.
%
% If no initial structure S is provide the structure
% with N objects is returned with its log likelihood.
% The expected form is that of a sparse matrix where
% the rows index the objects and the columns the 
% cluster sectors to which the object belongs.
%
% LC : log=liklihood
%  S : the strucutre
% NS : number of objects in each cluster group
% CS : the cluster correlations relationships
% GS : cluster factor coefficientss
%

% $ Author Tim Gebbie $ 
% $ Revision 1.4 %

% 1.2 2009/02/06 13:11:50 Tim Gebbie

switch nargin
case 1
     x = varargin{1};
 [m,n] = size(x);
     s = speye(n);
case 2
     x = varargin{1};
     s = varargin{2};
otherwise
     error('Incorrect Input Arguments');
end

% find the number of entries in each object
ns = full(sum(s==1));
% find the pearson coeffcient
c = pearson(x);
% find the correlation coefficient
cs = sum(c * s);
% optimal factor coefficient
gs = sqrt(max(0,(cs-ns) ./ (ns .* ns - ns)));
% first term
t1 = log(ns ./ cs);
% second term
t2 = log(((ns .* ns - ns) ./ (ns .* ns - cs)).^(ns-1));
% log-likelihood
lc = 0.5 * sum(max(0,t1 + t2));
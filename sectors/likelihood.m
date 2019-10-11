function lc = likelihood(ns,cs)
% LIKELIHOOD The log-likelihood of the configuration.
%
% LC = LIKELIHOOD(NS,CS) This function uses NS, the number of 
% objects per cluster, and CS, the internal correlations of clusters
%
% NOTE: The functions sums up all internal energies in a given 
% configuration algorithm (see L. Giada & M. Marsili (2005)). 

% Authors: Bongani Mbambiso, Tim Gebbie 

% 1.2 2009/02/06 13:11:50 Tim Gebbie

% condition the data
ns = ns(:);
cs = cs(:);

% exclusion indices
for j = 1 : size(ns)
    % condition from Eq.4, Marsili (2002) 
    i(j) = (ns(j) > 1 & cs(j) > ns(j));
end

% rescall inputs
ns = ns(i);
cs = cs(i);

% optimal factor coefficient
gs = sqrt(max(0,(cs-ns) ./ (ns .* ns - ns)));

% first term
t1 = log(ns ./ cs);

% second term 
t2 = log(((ns - 1) ./ (ns - (cs ./ ns ))).^(ns-1));

% log-likelihood
lc = 0.5 * sum(max(0,t1 + t2));
 

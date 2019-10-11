function [e,gs] = energy(ns,cs)
% ENERGY Calculates the energy of each configuration
% 
% [E, GS] = ENERGY(NS,CS) Compute E the energy of each cluster or 
% configuration of clusters, and the optimal factor coefficient. The 
% inputs NS and CS are, the number of objects in each cluster S of the 
% configuration, and the pearson coefficient for the cluster of objects, 
% respectively.
%
% NOTE: The method is based on the method by L. Giada & M. Marsili (2005). 

% Authors: Bongani Mbambiso, Tim Gebbie 

% 1.2 2009/02/06 13:11:50 Tim Gebbie

% exclusion indices
index = (ns > 1) & (cs>ns);

% initialize lc
e = zeros(size(ns)); 

% initialize gs
gs = e;

% the number of elements
ns = ns(index);

% the pearson coefficient
cs = cs(index);

% optimal factor coefficient
gs = sqrt(max(0,(cs-ns) ./ (ns .* ns - ns)));

% control parameters
chi = cs ./ ns;

% energy 
e(index) = log(chi) + (ns-1) .* log((ns-chi)./(ns -1));


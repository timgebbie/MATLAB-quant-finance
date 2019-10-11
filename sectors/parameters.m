function [s, cs, ns, index] = parameters(a, c)
% PARAMETERS Find new cluster parameters of a new configuration.
%
% [S,CS,NS,INDEX] = PARAMETERS(A, C) From the previous configuration's 
% index vector A and correlation matrix C, computes S, the configuration
% logical cluster matrix with columns as clusters and rows as objects. 
% '1' (True) indicates that an object is in that cluster, false or '0' if 
% it is not. 
%
% Also computes CS, the pearson coefficient for the new configuration of
% clusters. NS is the umber of objects per cluster in the new 
% configuration. The cluster number is given by the position in INDEX.
%
% NOTE 1: The index matrix, I(i,k)=j, j-th object in the original data is 
% the k-th object in the in i-th cluster of the current configuration.
%
% NOTE 2: j - is indexing original data objects, i - is indexing clusters, 
% and k - objects of the i-th / currrent cluster. This gives an index of 
% all the k objects in i-th cluster. Rows (i's) are clusters and values 
% are elements in the cluster. This give membership.
%
% See Also : UNIQUE, REPMAT, SPARSE, FULL.

% Authors: Bongani Mbambiso, Tim Gebbie 

% 1.2 2009/02/06 13:11:50 Tim Gebbie


% The size of the configuration vector
[m,n] = size(a);

% Find the unique clusters
cn  = unique(a);  

% Find the number of unique clusters
nc = length(cn);

% Find the logical cluster matrix
s = transpose(sparse(repmat(a,nc,1) - repmat(cn',1,n)==0));

% Find the number of members in each clusters
ns = full(sum(s))';

% Initialize the cluster index matrix
index = NaN * zeros(nc,max(ns));

% Find the cluster index matrix
for i=1:nc
    index(i,1:ns(i)) = find(a == cn(i)); 
end;
    
% the size of the pearson coefficient matrix
cs = full(diag(s' * sparse(c) * s));


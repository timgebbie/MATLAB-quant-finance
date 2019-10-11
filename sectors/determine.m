function [Z] = determine(varargin)
% DETERMINE Clusters by deterministic recursive cluster merging 
%
% [Z] = DETERMINE(X) Compute the linkage for the data X, and MxN 
% matrix with M objects and N realizations. The data is first averaged
% using AVERERAGING which removes the bias from the data i.e. the
% market mode is removed.
%
% Cluster information will be returned in the matrix Z with size m-1
% by 3, where m is the number of observations in the original data.
% Column 1 and 2 of Z contain cluster indices linked in pairs
% to form a binary tree. The leaf nodes are numbered from 1 to
% m. They are the singleton clusters from which all higher clusters
% are built. Each newly-formed cluster, corresponding to Z(i,:), is
% assigned the index m+i, where m is the total number of initial
% leaves. Z(i,1:2) contains the indices of the two component
% clusters which form cluster m+i. There are m-1 higher clusters
% which correspond to the interior nodes of the output clustering
% tree. Z(i,3) contains the corresponding linkage distances between
% the two clusters which are merged in Z(i,:), e.g. if there are
% total of 30 initial nodes, and at step 12, cluster 5 and cluster 7
% are combined and their distance at this time is 1.5, then row 12
% of Z will be (5,7,1.5). The newly formed cluster will have an
% index 12+30=42. If cluster 42 shows up in a latter row, that means
% this newly formed cluster is being combined again into some bigger
% cluster. 
% 
% [Z] = DETERMINE(X,METHOD) Compute the linkage for the data X, and MxN 
% matrix with M objects and N realizations. The correlation matrix isdata 
% is first averaged computed using the method in METHOD. METHOD can take 
% on values 1, 2 or 3, which imply 'pearson', 'kendall' or 'spearman', 
% respectively. The data is first averaged using AVERERAGING which removes
% the bias from the data i.e. the market mode is removed.
% 
% Example 1:
%       c = cov(randn(10,1000));
%       Z = determine(c);
%
% Example 2:
%       x = randn(10,1000);
%       x = average(x,5);
%       Z1 = determine(x,1);  %for 'pearson'
%       Z2 = determine(x,2);  %for 'kendall'
%       Z3 = determine(x,3);  %for 'spearman'
%
% Note 1: To plot the dendrogram if the tree is simply connected use
% see DENDROGRAM(Z,0). 
%
% Note 2: The algorithm iterates MINIMAL until convergence see
% MINIMAL and PARAMETERS to find out which data structures are iterated.
% Based on the method by L. Giada & M. Marsili (2005). 
%
% See Also : ANNEALING, PEARSON, KENDALL, SPEARMAN, LIKELIHOOD, MINIMAL,
%            DENDROGRAM, AVERAGING

% Authors: Bongani Mbambiso, Tim Gebbie 

% 1.2 2009/02/06 13:11:50 Tim Gebbie


% ---- Developer Notes ------------------------
% DESCRIPTION OF VARIABLES
% a     - cluster configuration
% index - cluster array index
% C     - correlation matrix
% cs    - pearsons coefficient
% ns    - number of elements in cluster 
% --------------------------------------------
%
% See paper by Matteo Marsili : 
%
% Sector(time)   : rows index time and columns assets.
% States(assets) : rows index asset and columns time.

% Input arguments
switch nargin,
    case 1,
        % get the correlation matrix
        c = varargin{1};
        % find the matrix rank
        [m,n]= size(c); 
      
    case 2,
        % get the input data          
        d = varargin{1,1};            
        % Get the correlation matrix
        if varargin{2} == 1,  
            % using Pearson's Coefficient
            c = pearson(d);
        elseif varargin{2} == 2,
            % using Kendall's rank correlation coefficient
            c = kendall(d);
        elseif varargin{2} == 3,
            % using Spearman Rank order correlation matrix 
            c = spearman(d);
        else
            error('Incorrect Correlation method');
        end;
        
        % Get the size of the correlation matrix
        [m,n]=size(c);
    otherwise
        error('Incorrect number of input arguments');
end;

% IINITIALIZE CONFIGURATION
% Cluster configuration (index)
a = 1:n;  
% Linkage matrix output
Z = [];     
% Initialize the loop
many_clusters = logical(1);  
% Initialize configuration variables
[s,cs,ns,index] = parameters(a,c);  
% Find the energy of the initial configuration
[e,gs] = energy(ns,cs); 
% Exit parameter (no. of clusters per configuration)
lns = length(ns);  
% set the number of links to zero
h = 0;

% MAIN ALGORITHM - LOOP OVER CLUSTER MERGING
% Loop until only one cluster 
while (lns>1),
    
    % find the next minimal combination of existing clusters
    % ------------ MINIMAL ENERGY CONFIGURATION ------------
    [e,c,ns,ij,d] = minimal(e,c,ns);
    % ------------------------------------------------------
    
    % find the new linkage number
    h = h + 1;
    % the log-likelihood of the structure
    lc(h) = likelihood(ns, diag(c));
    % new linkage from current cluster numbers and likelihood
    Z =[Z; [a(ij(1)),a(ij(2)),lc(h)]]; 
    % set the new unique cluster number for linkage variable
    a(ij(1))= n + h;
    % shorten the cluster linkage variable by one
    if ij(2)==length(c)+1,
        index = 1:length(c);
    else,
        index = [1:ij(2)-1,ij(2)+1:length(c)+1];
    end;
    
    % re-assign without the merged cluster
    a = a(index);  
    % update length of number of objects vector
    lns = length(ns);
      
end; % end while





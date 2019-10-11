%% Test Script #2 Deterministic Merging Cluster with Synthetic Data 
%
% Name: SECTORS_TEST_DETERMINE_002.M
%
% Authors: Bongani Mbambiso, Tim Gebbie
%
% This test script does the same thing as in test script #1, but the 
% correlation matrix used to generate the correlated data has been changed
% a bit; more objects are generated and the clusters are different. This 
% is done to make sure that the algorithm or the method of Marsili (2002)
% is working properly. Larger synthetic data sets were used to construct
% clusters using recursive deterministic merging. This test script is part 
% of the "Sector and State" toolbox SECTOR.ZIP. The data sets considered
% are in tests 2.1, 2.2 and 2.3:
% 
%  2.1. Uncorrelated Assets
%  2.2. Correlated Assets
%  2.3. Random Assets
%
% The likelihood function used is as in LIKELIHOOD.M
%
% $$L(G,S) = \sum_{i=1}^{N} \left( { log\left({n_{s_i} \over c_{s_i}}\right) - (n_{s_i} - 1) log \left( {{n_{s_i}^2-n_{s_i}} \over {n_{s_i} - c_{s_i}}} \right) } \right) $$
%
% Where
%
% $$n_s > 1$$
%
% $$c_s > n_s$$
%
% ASSUMPTION #1: All clusters are assumed (by construction) to be 
%                uncorrelated 
%
% ASUMMPTION #2: All the internal correlation are assumed 
%                (by construction) to be positive.
%
% NOTE: Correlations from synthetic are calculated from three methods- 
%       Pearson, Kendall, and Spearman.
%
% References:
%
%  1. L. Giada & M. Marsili (2005) ...
%  2. Marsili (2002) ... 
%
% See Also: SECTORS, DETERMINE, MINIMAL, ENERGY, LIKELIHOOD 

% $Revision: 1.1 $ $Date: 2009/02/06 13:12:20 $ $Author: Tim Gebbie $

%% Clear the workspace
clear all; clc;

%% The algorithm used to control the entire algorithm
help determine

%% The merging algorithm iterated at each level 
help minimal 

%% Test 2.1 : Uncorrelated Data
r21 = eye(40);
x21 = mvnrnd(zeros(40,1),r21,100);

%% Test 2.1.1 : Use MATLAB functions to generate tree
% Pairwise distance between observations. 
y211 = pdist(transpose(x21),'correlation'); 
% the linkage matrix
z211 = linkage(y211) 
% Plotting the dendrogram 
dendrogram(z211,0,'colorthreshold','default');
title('Uncorrelated Synthetic Data Test #2.1.1');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.1.2(a) : Use DETERMINE to generate linkage from the correlations
% Correlation matrix is taken as an input data
[z212a] = determine(r21)
dendrogram(z212a,0,'colorthreshold','default');
title('Uncorrelated Synthetic Data Test #2.1.2(a)');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.1.2(b) : Use DETERMINE & PEARSON to generate linkage from data
% using Pearson's Coefficient on uncorrrelated synthetic data
[z212b] = determine(x21,1)
dendrogram(z212b,0,'colorthreshold','default');
title('Uncorrelated Synthetic Data Test #2.1.2(b): PEARSON');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.1.2(c) : Use DETERMINE & KENDALL to generate linkage from data
% using Kendall's rank correlation coefficient on uncorrrelated data
[z212c] = determine(x21,2)
dendrogram(z212c,0,'colorthreshold','default');
title('Uncorrelated Synthetic Data Test #2.1.2(c): KENDALL');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.1.2(d) : Use DETERMINE & SPEARMAN to generate linkage from data
% using Spearman Rank order correlation matrix on uncorrrelated data
[z212d] = determine(x21,3)
dendrogram(z212d,0,'colorthreshold','default');
title('Uncorrelated Synthetic Data Test #2.1.2(d): SPEARMAN');
ylabel('Likelihood');
xlabel('Object');


%% Test 2.2 : Correlated Data
r22=[[ 1, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0.45]; ...
    [0.4,   1, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...
    [0.4, 0.4,   1, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...
    [0.4, 0.4, 0.4,   1, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...
    [0.4, 0.4, 0.4, 0.4,   1, 0.4, 0.4, 0.4, 0.4, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0.4, 0.4, 0.4, 0.4, 0.4,   1, 0.4, 0.4, 0.4, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...   
    [0.4, 0.4, 0.4, 0.4, 0.4, 0.4,   1, 0.4, 0.4, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...  
    [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,   1, 0.4, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...   
    [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,   1, 0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0,-.3,0,0,0,0,0,0,0,0]; ...
    [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,   1,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  -.4,0,0,0,0,0,0,0,0,0]; ...
          
    [0,0,0,0,0,0,0,0,0,0,     1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,  -0.1,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...  
    [0,0,0,0,0,0,0,0,0,0,   0.5,   1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,  -0.2,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0.5, 0.5,   1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,  -0.3,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...
    [0,0,0,0,0,0,0,0,0,0,   0.5, 0.5, 0.5,   1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,  -0.4,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0.5, 0.5, 0.5, 0.5,   1, 0.5, 0.5, 0.5, 0.5, 0.5,  -0.6,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...  
    [0,0,0,0,0,0,0,0,0,0,   0.5, 0.5, 0.5, 0.5, 0.5,   1, 0.5, 0.5, 0.5, 0.5,  -0.5,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...
    [0,0,0,0,0,0,0,0,0,0,   0.5, 0.5, 0.5, 0.5, 0.5, 0.5,   1, 0.5, 0.5, 0.5,  -0.4,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ...
    [0,0,0,0,0,0,0,0,0,0,   0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,   1, 0.5, 0.5,  -0.3,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,   1, 0.5,  -0.2,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,   1,  -0.1,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0]; ... 
          
    [0,0,0,0,0,0,0,0,0,0,   -.1,-.2,-.3,-.4,-.6,-.5,-.4,-.3,-.2,-0.1,   1, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,  0,0,0,0,0,0,0,0,0,0]; ... 
        
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3,   1, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,  0,0,0,0,0,0,0,0,0,0]; ...  
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3, 0.3,   1, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3, 0.3, 0.3,   1, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3, 0.3, 0.3, 0.3,   1, 0.3, 0.3, 0.3, 0.3, 0.3,  0,0,0,0,0,0,0,0,0,0]; ...  
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3, 0.3, 0.3, 0.3, 0.3,   1, 0.3, 0.3, 0.3, 0.3,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3, 0.3, 0.3, 0.3, 0.3, 0.3,   1, 0.3, 0.3, 0.3,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,   1, 0.3, 0.3,  0,0,0,0,0,0,0,0,0,0]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,   1, 0.3,  0,0,0,0,0,0,0,0,0,0]; ...  
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,   1,  0,0,0,0,0,0,0,0,0,0]; ... 
          
    [0,0,0,0,0,0,0,0,0,-0.4,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,    1, 0.1, 0.1, 0.1,-0.1,-0.2, 0.1, 0.3, 0.4, 0.5]; ... 
    [0,0,0,0,0,0,0,0,-.3,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0.1,   1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.4]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0.1, 0.1,   1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.3]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0.1, 0.1, 0.1,   1, 0.1, 0.1, 0.1, 0.1, 0.1,-0.1]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0.1, 0.1, 0.1, 0.1,   1, 0.1, 0.1, 0.1, 0.1,-0.2]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0, -0.2, 0.1, 0.1, 0.1, 0.1,   1, 0.1, 0.1, 0.1, 0.1]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0, -0.1, 0.1, 0.1, 0.1, 0.1, 0.1,   1, 0.1, 0.1, 0.1]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0.3, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,   1, 0.1, 0.1]; ... 
    [0,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0.4, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,   1, 0.1]; ... 
    [0.45,0,0,0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,  0.5, 0.4, 0.3,-0.1,-0.2, 0.1, 0.1, 0.1, 0.1,  1]];   
      
x22 = mvnrnd(zeros(40,1),r22,100);

% Pseudocolor plot of the Correlation Matrix  
pcolor (r22);
title('A pseudocolor plot of the Correlation Matrix');


%% Test 2.2.1 : Use MATLAB functions to generate tree
% Pairwise distance between observations. 
y221 = pdist(transpose(x22),'correlation'); 
% the linkage matrix
z221 = linkage(y221) 
% Plotting the dendrogram 
dendrogram(z221,0,'colorthreshold','default');
title('Correlated Synthetic Data Test #2.2.1');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.2.2(a) : Use DETERMINE to generate linkage from the correlations
[z222a] = determine(r22)
dendrogram(z222a,0,'colorthreshold','default');
title('Correlated Synthetic Data Test #2.2.2(a)');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.2.2(b) : Use DETERMINE & PEARSON to generate linkage from data
% using Pearson's Coefficient
[z222b] = determine(x22,1)
dendrogram(z222b,0,'colorthreshold','default');
title('Correlated Synthetic Data Test #2.2.2(b): PEARSON');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.2.2(c) : Use DETERMINE & KENDALL to generate linkage from data
% using Kendall's rank correlation coefficient
[z222c] = determine(x22,2)
dendrogram(z222c,0,'colorthreshold','default');
title('Correlated Synthetic Data Test #2.2.2(c): KENDALL');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.2.2(d) : Use DETERMINE & SPEARMAN to generate linkage from data
% using Spearman Rank order correlation matrix 
[z222d] = determine(x22,3)
dendrogram(z222d,0,'colorthreshold','default');
title('Correlated Synthetic Data Test #2.2.2(d): SPEARMAN');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.3 : Random Normal Data 
% random normal data
x23 = randn(100,40);
% correlation matrix
r23 = pearson(x23);

%% Test 2.3.1 : Use MATLAB functions to generate tree
% Pairwise distance between observations. 
y231 = pdist(transpose(x23),'correlation'); 
% the linkage matrix
z231 = linkage(y231) 
% Plotting the dendrogram 
dendrogram(z231,0,'colorthreshold','default');
title('Random Normal Data Test #2.3.1'); 
ylabel('Likelihood');
xlabel('Object');

%% Test 2.3.2(a) : Use DETERMINE to generate linkage from the correlations
[z232a] = determine(r23)
dendrogram(z232a,0,'colorthreshold','default');
title('Random Normal Data Test #2.3.2(a)');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.3.2(b) : Use DETERMINE & PEARSON to generate linkage from data
% using Pearson's Coefficient
[z232b] = determine(x23,1)
dendrogram(z232b,0,'colorthreshold','default');
title('Random Normal Data Test #2.3.2(b): PEARSON');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.3.2(c) : Use DETERMINE & KENDALL to generate linkage from data
% using Kendall's rank correlation coefficient
[z232c] = determine(x23,2)
dendrogram(z232c,0,'colorthreshold','default');
title('Random Normal Data Test #2.3.2(c): KENDALL');
ylabel('Likelihood');
xlabel('Object');

%% Test 2.3.2(d) : Use DETERMINE & SPEARMAN to generate linkage from data
% using Spearman Rank order correlation matrix 
[z232d] = determine(x23,3)
dendrogram(z222d,0,'colorthreshold','default');
title('Random Normal Data Test #2.3.2(d): SPEARMAN');
ylabel('Likelihood');
xlabel('Object');


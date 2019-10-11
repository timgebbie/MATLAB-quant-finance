%% Test Script #1 Deterministic Merging Cluster with Synthetic Data 
%
% Name: SECTORS_TEST_DETERMINE_001.M
%
% Authors: Bongani Mbambiso, Tim Gebbie
%
% This test script demonstrates the method of Marsili (2002) using small
% synthetic data sets to construct clusters using recursive deterministic
% merging. This test script is part of the "Sector and State" toolbox 
% SECTOR.ZIP. The data sets considered are in tests 1.1, 1.2 and 1.3:
% 
%  1.1. Uncorrelated Assets
%  1.2. Correlated Assets
%  1.3. Random Assets
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
% ASSUMPTION #1: All clusters are assumed (by construction) to be uncorrelated 
%
% ASUMMPTION #2: All the internal correlation are assumed (by construction) to be positive.
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

%% Test 1.1 : Uncorrelated Data
r11 = eye(6);
x11 = mvnrnd(zeros(6,1),r11,100);

%% Test 1.1.1 : Use MATLAB functions to generate tree
% Pairwise distance between observations. 
y111 = pdist(transpose(x11),'correlation'); 
% the linkage matrix
z111 = linkage(y111) 
% Plotting the dendrogram 
dendrogram(z111,0,'colorthreshold','default');
title('Uncorrelated Synthetic Data Test #1.1.1');
ylabel('Likelihood');
xlabel('Object');

%% Test 1.1.2 : Use DETERMINE to generate linkage
[z112] = determine(r11)
dendrogram(z112,0,'colorthreshold','default');
title('Uncorrelated Synthetic Data Test #1.1.2');
ylabel('Likelihood');
xlabel('Object');

%% Test 1.2 : Correlated Data
r12     = [[  1, 0.1,  0.1,     0,     0, -0.3]; ...
          [ 0.1,   1,  0.1,     0,     0,    0]; ...
          [ 0.1, 0.1,    1,     0,     0,    0]; ...
          [   0,   0,    0,     1,  0.45,  0.6]; ...
          [   0,   0,    0,  0.45,     1,  0.6]; ...
          [-0.3,   0,    0,   0.6,   0.6,    1]];
x12 = mvnrnd(zeros(6,1),r12,100);

% Pseudocolor plot of the Correlation Matrix  
pcolor (r12);
title('A pseudocolor plot of the Correlation Matrix');

%% Test 1.2.1 : Use MATLAB functions to generate tree
% Pairwise distance between observations. 
y121 = pdist(transpose(x12),'correlation'); 
% the linkage matrix
z121 = linkage(y121) 
% Plotting the dendrogram 
dendrogram(z121,0,'colorthreshold','default');
title('Correlated Synthetic Data Test #1.2.1');
ylabel('Likelihood');
xlabel('Object');

%% Test 1.2.2 : Use DETERMINE to generate linkage
[z122] = determine(r12)
dendrogram(z122,0,'colorthreshold','default');
title('Correlated Synthetic Data Test #1.2.2');
ylabel('Likelihood');
xlabel('Object');

%% Test 1.3 : Random Normal Data 
% random normal data
x13 = randn(30,6);
% correlation matrix
r13 = pearson(x13);

%% Test 1.3.1 : Use MATLAB functions to generate tree
% Pairwise distance between observations. 
y131 = pdist(transpose(x13),'correlation'); 
% the linkage matrix
z131 = linkage(y131) 
% Plotting the dendrogram 
dendrogram(z131,0,'colorthreshold','default');
title('Random Normal Data Test #1.3.1');
ylabel('Likelihood');
xlabel('Object');

%% Test 1.2.2 : Use DETERMINE to generate linkage
[z132] = determine(r13)
dendrogram(z132,0,'colorthreshold','default');
title('Random Normal Data Test #1.3.2');
ylabel('Likelihood');
xlabel('Object');

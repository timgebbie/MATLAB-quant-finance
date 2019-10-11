%% Test Script #3 Simulated Annealing with small Synthetic Data 
%
% Name: SECTORS_TEST_ANNEALING_001.M
%
% Authors: Bongani Mbambiso, Tim Gebbie
%
% This test script is part of the "Sector and State" toolbox SECTOR.ZIP.
% The data set considered is only Correlated Assets. There are three small 
% data sets used, the first one has as single cluster, the second one has
% two clusters, and the third one has three clusters in it.
% The test script is developed to show that the algorithm picks up 
% those clusters.
%
%
% References:
%
%  1. J. D. Noh, Phys. Rev. E 61, 5981 (2000)
%  1. L. Giada & M. Marsili (2005) ...
%  2. Marsili (2002) ... 
%
% See Also: ANNEALING, CHANGE, SWEEP, MERGE, SPLIT, GROUND, RECALCULATE 

% Author: Tim Gebbie, Bongani Bambiso 2006

% $Revision: 1.1 $ $Date: 2009/02/06 13:12:20 $ $Author: Tim Gebbie $


%% Clear the workspace
clear all; clc;

%% The algorithm used to control the entire algorithm
help annealing 

%% Rearrange the configuration several times for each cooling schedule 
help change 

%% Input Data and Variables 
% Initial beta
ib      = 1.1;     
% Final beta
fb      = 5;  
% Number of sweeps between changes in temperature
t_steps = 15;    % temperature changes every t_steps 
% Max. number of annealing cycles                   
n_cycles= 1; 
% Cooling Factor for delta_temperature
cf      = 0.997; 

%% Test 3.1: Correlated data with a Single Cluster
C31 = [[   1, 0.4, 0.5,  0,  0,   0]; ...
       [ 0.4,   1, 0.2,  0,  0,   0]; ...
       [ 0.5, 0.2,   1,  0,  0,   0]; ...
       [   0,   0,   0,  1,  0,   0]; ...
       [   0,   0,   0,  0,  1,   0]; ...
       [   0,   0,   0,  0,  0,   1]];
% Generating Correlated Data 
data31 = mvnrnd(zeros(6,1),C31,100); 

% Test 3.1.1: Use ANNEALING to generate clusters from the correlations    
[A] = annealing(C31,ib,fb,t_steps,n_cycles,cf);

% Membership Matrix: Rows-Clusters, Columns-Objects
A.gs.I
 
%% Test 3.2: Correlated data with Two Clusters
C32 = [[  1, -0.1, -0.2,     0,     0,    0]; ...
      [-0.1,    1, -0.3,     0,     0,    0]; ...
      [-0.2, -0.3,    1,     0,     0,    0]; ...
      [   0,    0,    0,     1,   0.5,  0.6]; ...
      [   0,    0,    0,   0.5,     1,  0.6]; ...  
      [   0,    0,    0,   0.6,   0.6,    1]];
% Generating Correlated Data
data32 = mvnrnd(zeros(6,1),C32,100); 

% Test 3.2.1: Use ANNEALING to generate clusters from the correlations    
[A] = annealing(C32,ib,fb,t_steps,n_cycles,cf);

% Membership Matrix: Rows-Clusters, Columns-Objects
A.gs.I

%% Test 3.3: Correlated data with Three Clusters
C33 = [[  1, 0.65,    0,    0,    0,    0]; ...
      [0.65,    1,    0,    0,    0,    0]; ...
      [   0,    0,    1,  0.2,    0,    0]; ...
      [   0,    0,  0.2,    1,    0,    0]; ...
      [   0,    0,    0,    0,    1, -0.1]; ...
      [   0,    0,    0,    0, -0.1,    1]];
% Generating Correlated Data
data33 = mvnrnd(zeros(6,1),C33,100); 

% Test 3.3.1: Use ANNEALING to generate clusters from the correlations    
[A] = annealing(C33,ib,fb,t_steps,n_cycles,cf);

% Membership Matrix: Rows-Clusters, Columns-Objects
A.gs.I
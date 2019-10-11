%% Simulated Annealing Profile test script
ib      = 1.1;     
fb      = 5;  
t_steps = 15;    % temperature changes every t_steps 
n_cycles= 1; 
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

profile on
% Test 3.1.1: Use ANNEALING to generate clusters from the correlations    
[A] = annealing(C31,ib,fb,t_steps,n_cycles,cf);  
profile viewer
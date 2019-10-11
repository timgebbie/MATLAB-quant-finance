%%  Test code for KALMANF1
%
% Authors: Tim Gebbie, Raphael Nkomo

%% Load the test data
load test_kalmanf1_workspace;

%% Test the function on vector
x = fts2mat(test_agl.NOSH);
[xhat k] = kalmanf1(x);
figure;
plot([xhat x]);

%% Test the function on matrix
x = fts2mat(test_agl);
Q = 1; 
R = 0.9;
[xhat k] = kalmanf1(x,Q,R);
figure;
plot([xhat x]);
title('Kalman Filter order 1');

%% Compare
y=hpfilter(x,10)
figure
plot([y x]);
title('Hodrick Prescott');
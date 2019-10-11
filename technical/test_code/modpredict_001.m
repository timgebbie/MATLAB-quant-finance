%% Test Scripti for the N-D Next-Nearest-Neighbour Algo
%
% N-D nearest neighbour and next-nearest-neighbour

%% test data
clear all; clc;
m = 100; % 100 points
n = 10; % is the number of stocks
x = randn(m,n);

%% Next Nearest Neighbour on delay data
% embedding dimension
t = 3;
% k neighbours
k = 15;
% dimension of embedding 
d = 6;
% find the T step ahead predition
[yt,y0] = modpredict(x,k,d,t);
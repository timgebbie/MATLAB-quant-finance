%% Test Scripti for the N-D Next-Nearest-Neighbour Algo
%
% N-D nearest neighbour and next-nearest-neighbour

% $Revision: 1.1 $ $Date: 2008/07/01 14:42:48 $ $Author: Tim Gebbie $

%% test data
clear all; clc;
n=100; % 100 points
d=10; % in d-dimensional space
x = randn(n,d);

%% embedding vector
xi = median(x);

%% Next Nearest Neighbour
delay = 2; % time delay is 2
k = 15; % k neighbours
[xt,x0] = nextnearneigh(x,xi,k,delay);

%% Next Nearest Neighbour on delay data
y0 = randn(100,1);
% embedding dimension
d = 6;
% create the embedding state-space
y = lagmatrix(y0,1:d);
% edit of the initial padded data
y = y(6:end,:);
% find the T step ahead predition
[yt,y0,d0] = nextnearneigh(y,y(50,:),k,delay);

%% Next Nearest Neighbour on surface data
delay = 2; % time delay is 2
k = 15; % k neighbours
xs = randn(100,10,5);
xsi = squeeze(median(xs));
[xst,xs0] = nextnearneigh(xs,xsi,k,delay);
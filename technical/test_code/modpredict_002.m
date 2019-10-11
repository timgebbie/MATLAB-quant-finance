%% Test Scripti for the N-D Next-Nearest-Neighbour Algo
%
% N-D nearest neighbour and next-nearest-neighbour

%% test data
load workspace_modpredict;

%% Next Nearest Neighbour on delay data
% find the T step ahead predition
[yt,y0] = modpredict(x,15,4,5);
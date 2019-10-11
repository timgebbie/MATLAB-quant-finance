%%  Test code for FRAMAFILT
%
% Authors: Tim Gebbie, Raphael Nkomo

% $Revision: 1.1 $ $Date: 2008/09/26 14:13:58 $ $Author: Tim Gebbie $

%% Generate test data
p = cumsum(randn(50,5)* 0.10);

%% Help files
help framafilt

%% Run without plot
[f] = framafilt(p);

%% Run with plots
framafilt(p);
%%  Test code for EHLERSFILT
%
% Authors: Tim Gebbie, Raphael Nkomo

% $Revision: 1.2 $ $Date: 2008/10/03 09:03:04 $ $Author: Tim Gebbie $

%% Generate test data
p = cumsum(randn(50,5)* 0.10);

%% Help files
help ehlersfilt

%% Run without plot
s = [zeros(5,size(p,2)); abs(diff(p,5))];
[f] = ehlersfilt(p,s,15);

%% Run with plots
ehlersfilt(p);
function rex = rescale(x)
% RESCALE(X) rescales time series from [t1,t2] to [0,2*pi]
%
% REX = RESCALE(X)
%
% p - time series
% 
% RESCALE(x) rescales a one-dimension time series from [t1,t2]
% to [0,2*pi] using the formula:
%      rex(i,1) = (x(i) - x(1))/(x(nrPoints) - x(1))*2*pi;
%
% Example: 
%
% Input:
% ------
%                      
%  x     =      0      
%               0.2
%               0.4
%               0.6
%               0.8
%               1
%
% REX = RESCALE(x)
%
% Output:
% -------
%  rex   =      0
%               1.5708
%               3.1416
%               4.7124
%               6.2832
%
% See also fcvar.m

% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: user $

% $Author Chanel Malherbe

%determine the length of the matrix
nrPoints = length(x);
%rescale the data
for i = 1:nrPoints
    rex(i,1) = (x(i) - x(1))/(x(nrPoints) - x(1))*2*pi;
end
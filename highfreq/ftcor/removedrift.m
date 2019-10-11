function newP = removeDrift(p)
% REMOVEDRIFT remove drift
%
% NEWP = REMOVEDRIFT(p)
%
% p - [1:N,1:M] where 1st dimension is time rescaled to [0,2pi],
%     and the other dimensions contain price process.
% 
% REMOVEDRIFT(p) removes the drift from process p using the 
% following formula:
%   newP(t) = p(t) + t/(2pi)*(p(0) - p(2pi))
% Note that the processes p and newP will have the same volatility.
%   
% Example: 
%
% Input:
% ------
%                      
% p   =   0   10.0000
%         1.2566   12.0018
%         2.5133   12.2190
%         3.7699   11.8997
%         5.0265   12.5054
%         6.2832   12.2539
%
% NEWP = REMOVEDRIFT(p)
%
% Output:
% -------
% p   =   0   10.0000
%         1.2566   11.5510
%         2.5133   11.3174
%         3.7699   10.5474
%         5.0265   10.7023
%         6.2832   10.0000
%
% See also ftvar.m, rescale.m
%
% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: user $
%
% $Author Chanel Malherbe

%get the size of the input vector p
[row,column] = size(p);
%determine the length of the time series
nrRows = max(row,column);
%determine the number of time series
nrSeries = min(row,column)-1;
%remove drift for each time series
for j = 1:nrSeries
    for i = 1 : nrRows
        newP(i,1) = p(i,1);
        newP(i,j+1) = p(i,j+1) + p(i,1)/(2*pi)*(p(1,j+1) - p(nrRows,j+1));
    end
end
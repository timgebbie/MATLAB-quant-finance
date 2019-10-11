function tau = kendall(x,y)
% KENDALL Kendall's rank correlation coefficient.
%   TAU = KENDALL(X) returns a matrix TAU of pairwise Kendall's rank
%   correlation coefficients between columns of the matrix X.
%
%   TAU = KENDALL(X,Y) returns Kendall's rank correlation coefficient TAU
%   between the vectors X and Y.

%   Written by Peter Perkins, The MathWorks, Inc.
%   $Revision: 1.1 $  Date: 2003/09/05
%   This function is not supported by The MathWorks, Inc.
%
%   Requires MATLAB R14.

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:12 $ $Author: Tim Gebbie $

if nargin == 1
    [n,p] = size(x);
    tau = eye(p);
    for row = 1:(p-1)
        for col = (row+1):p
            s = 0;
            for i = 1:n
                s = s + sum(sign(x(i:n,row)-x(i,row)).*sign(x(i:n,col)-x(i,col)));
            end
            tau(row,col) = s .* 2./(n.*(n-1));
            tau(col,row) = tau(row,col);
        end
    end

else
    if ~((ndims(x) == 2) & any(size(x) == 1)) | ...
       ~((ndims(y) == 2) & any(size(y) == 1)) | (numel(x) ~= numel(y))
        error('X and Y must be vectors of the same length.');
    end
    n = numel(x);
    tau = 0;
    for i = 1:n
        tau = tau + sum(sign(x(i:n)-x(i)).*sign(y(i:n)-y(i)));
    end
    tau = tau .* 2./(n.*(n-1));
end

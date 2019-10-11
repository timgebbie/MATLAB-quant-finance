function [a] = adjacency(z)
%ADJACENCY Convert a distance matrix to adjacency matrix
%
% A = ADJACENCY(Z) For Z a distance matrix with the distance from the i-th
% object to the j-th object being the Z(i,j) entry in the distance matrix.
% A has it first two columns as node labels and the third column as the
% distance between the nodes i.e. the first and second columns defined
% edges (2 vertices) and the third is the edges weight.
%
% See Also : MINSPANTREE, MSTCOORDS, MSTPLOT

% Author: Tim Gebbie

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:12 $ $Author: Tim Gebbie $

% check orientation
if (size(z,1)==1) | (size(x,2)==1),
    z = squareform(z); % from vector to matrix
else
    % assume that it is a matrix
end
% adjancency entry counter
k = 1;
for i=1:size(z,1)
    for j=1:size(z,2)
        % exclude vertices
        if i==j,
        else
            a(k,1) = i;
            a(k,2) = j;
            a(k,3) = z(i,j);
            k=k+1;
        end
    end
end
end


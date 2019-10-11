function [xy] = coordinates(t)
% COORDINATES Coordinates from minimal spanning tree adjacency matrix
%
%   [XY,T] = COORDINATE(T) Generates vertex coordinates XY for the adjacency
%       matrix T for the visualisation of minimal spanning trees. The
%       algorithm starts with the most connected node and the looks for all
%       connections from this moving in the direction away from the most
%       connected prior nodes.
%
% See Also: MINSPANTREE, ADJACENCY

% find the number of connections
cn = full(sum(t));
% find the maximum node and start at (0,0)
[dummy,v0]=max(cn);
% initialise the coordinates
xy(v0,:) = [0,0,1];

while sum(sum(length(t)))>0 % loop over all vertices eliminating one at a time
    % the current vertex
    v = v0; 
    % find the connecting vertices
    c = find(t(:,v));
    % loop over the connections to vertex
    for j=c
        % compute the angles
        dth(j) = 2*pi / cn(v);
        % compute cartesian coord from polar coords
        [xj, yj] = [x0j, y0j] + pol2cart(th(j),r(j));
        % check distance from other points
        xy(v,1) = xj;
        xy(v,2) = yj;
        % eliminate from adjacency matrix
        t(v,j) = 0;
        t(j,v) = 0; 
    end
    % find the current vertex
    v0 = 
    % remaining vertices
end

end


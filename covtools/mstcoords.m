function [xy,th,cv] = mstcoords(varargin)
% MSTCOORDS Coordinates from minimal spanning tree adjacency matrix
%
% [XY] = MSTCOORDS(T) Generates vertex coordinates XY for the 
%   adjacency matrix T for the visualisation of minimal spanning trees. 
%   The algorithm starts with the most connected node and the looks 
%   for all connections from this moving in the direction away from 
%   the most connected prior nodes. The tree is searched recursively.
%
% [XY] = MSTCOORDS(T,V,TH0,V0,XY0) V is the parent vertex, TH0 the prior edge 
%   angle into the parent vertex, V0 is the prior parent vertex label and
%   XY0 is the prior parents coordinates. At each step the child vertices 
%   are return for a given parent node. This is carried out until the tree 
%   terminates.
%
% [XY] = MSTCOORDS(T,V,TH0,V0,XY0,R0) Radius lengths for each vertex. By
%   defaults R0=1. R0 is a vector of the length of the number for nodes.
%
% See Also: MINSPANTREE, ADJACENCY

% Author: Tim Gebbie

% $Revision: 1.2 $ $Date: 2009/05/28 11:38:52 $ $Author: Tim Gebbie $

% radius variable 
r0      = 1; % the default radius of each edge
dth     = pi/5; % the pre-set delta theta between edges from a given node
tilt    = 0; % control the tilt away from the median centroid of the graph
sprd    = 5; % controls the sigmoid response function that increase spread

switch nargin
    case 1
        % find the maximum node and start at (0,0)
        [dummy,v]=max(full(sum(varargin{1})));
        % initialise the coordinates
        xy(v,:) = [0,0];
        % call the MST coord function
        [xy]=mstcoords(varargin{1},v,[],[],xy);
        return
    case 5
        t   = varargin{1};
        v   = varargin{2};
        th0 = varargin{3};
        v0  = varargin{4};
        xy  = varargin{5};
        r0  = r0*ones(size(t,1),1);
    case 6
        t   = varargin{1};
        v   = varargin{2};
        th0 = varargin{3};
        v0  = varargin{4};
        xy  = varargin{5};
        r0  = varargin{6};
    otherwise
        error('Incorrect Input Arguments');
end

% ensure that all entries in t are 0 or 1
t(t>0) = 1;
% find the connecting vertices
cv = find(t(:,v));
% remove where it came from (termination condition)
cv = cv(~ismember(cv,v0));
% the radius length for each edge
r0 = r0(cv);
% if tree terminates return
if isempty(cv)
    return;
else
    % find the connectivity of each child node
    for i=1:length(cv), cn(i) = sum(t(:,cv(i))); end
    % re-order cv based on the connectivity to spread tree out
    [ci]=folding(cn);
    % use the spreadout index
    cv = cv(ci);
    % get the previous angle
    if isempty(th0)
        % compute the angles
        thj   = cumsum((2*pi / length(cv)) * ones(length(cv),1));
    else
        if length(cv)==1
            % if only one connection continue in same direction
            thj = th0;
        else
            % spread factor
            sdth = dth*(0.5*(tanh((length(cv)-sprd)/2)+1)+1);
            % compute tilt (to tilt away fron the nearest neighbours)
            [xyr] = xy(v,:)-median(xy);
            % convert cartesian distance to radial distance
            tilt = cart2pol(xyr(1),xyr(2));
            % increment angles
            dthj = (sdth*2)/(length(cv)-1);
            % compute the radial coordiantes from increments
            thj = cumsum([0; dthj*ones(length(cv)-1,1)]);
            % get the input angle (pi/3) is key angle
            thj = tilt - sdth + thj;
        end
    end
    % loop over the connections to vertex
    for j=1:length(cv),
        % compute cartesian coord from polar coords with r0 radius
        [xj,yj] = pol2cart(thj(j),r0(j));
        % update the coordinates relative to the parents coordinates
        xy(cv(j),:) = xy(v,:) + [xj,yj];
        % recurse the tree until termination
        [xy]=mstcoords(t,cv(j),thj(j),v,xy);
    end
end
end

function [ci]=folding(cn)
% SPREADOUT Spread out index string number

% sort integers
[cn,ci]=sort(cn,'descend');
if length(cn)>2,
    % pad to keep length and integer
    if (mod(length(ci),2)==1), ci = [ci 0]; cn = [cn 0]; end;
    % reshape the vector by halving
    ci = reshape(ci,2,length(ci)/2);
    % transpose the matrix order (to get large and small connectivity
    % spread out in the leaves)
    ci = transpose(ci);
    % reshape back 
    ci = reshape(ci,2*length(ci),1);
    % recentre (to get large connectivity in centre of leaf)
    ci = [ci(length(ci)/2+1:length(ci)); ci(1:length(ci)/2)];
    % non-zero elements
    ci1  = ci(1:length(ci)/2); % first half
    nzc1 = ci1>0; % find the zero padding
    ci1  = ci1(nzc1); % remove zero padding
    ci2  = ci(length(ci)/2+1:length(ci)); % second half
    nzc2 = ci2>0; % find the zero padding
    ci2  = ci2(nzc2); % remove the zero padding
    % recurse
    [ci10] = folding(cn(ci1));
    [ci20] = folding(cn(ci2)); 
    % re-order
    ci1 = [ci1(ci10)];
    ci2 = [ci2(ci20)];
    % merge
    ci(find(nzc1)) = ci1;
    ci(find(nzc2)+length(ci)/2) = ci2;
    % remove the padding numbers
    ci = ci(ci>0); 
else
end

end

% EOF

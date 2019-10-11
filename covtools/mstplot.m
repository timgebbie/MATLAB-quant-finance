function varargout=mstplot(varargin)
% MSTPLOT Plot minimal spanning tree graph
%
%   MSTPLOT(T,XY) plots the MST specified by T and XY. The adjacency
%   matrix, T has T(i,j) nonzero if and only if node i is connected to
%   node j. The coordinates array, XY, is an N-by-2 matrix with the
%   position for node i in the i-th row, XY(i,:) = [x(i) y(i)].
%
%   MSTPLOT(T,XY,LINESPEC,LABEL,WTS,PROP,BC) The non-zero entries of T are the
%   distances or between the nodes that are used if MST is TRUE. LABEL is
%   a cellstring array of size Nx1 with a label for each node. WTS is TRUE
%   to have weights used in plots and by default it is FALSE. PROP is the
%   vertex property as a Nx1 double. BC is the color vector associated with
%   the property bins in PROP. By default PROP are numbers refering to
%   three bins 1,2,3 and this are associated with BC = {'r','b','g'}.
%
%   See also MSTCOORDS, MINSPANTREE, GPLOT

% Author: Tim Gebbie

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:12 $ $Author: Tim Gebbie $

% initialise descriptors
labels = [];
wtsflag = false;
vp = [];
% bin colors
bc = {'r','b','g'};

switch nargin
    case 2
        lc.Color = 'b';
        lc.LineStyle = '-';
        lc.LineMarker = 'o';
        % plot the graph
        mstplot(varargin{1},varargin{2},lc);
        return;
    case 3
        t = varargin{1};
        xy = varargin{2};
        lc0 = varargin{3};
    case 4
        t = varargin{1};
        xy = varargin{2};
        if isempty(varargin{3}),
            lc0.Color = 'b';
            lc0.LineStyle = '-';
            lc0.LineMarker = 'o';
        end
        labels = varargin{4};
    case 5
        t = varargin{1};
        xy = varargin{2};
        if isempty(varargin{3}),
            lc0.Color = 'b';
            lc0.LineStyle = '-';
            lc0.LineMarker = 'o';
        end
        labels = varargin{4};
        wtsflag = varargin{5};
    case 6
        t = varargin{1};
        xy = varargin{2};
        if isempty(varargin{3}),
            lc0.Color = 'b';
            lc0.LineStyle = '-';
            lc0.LineMarker = 'o';
        end
        labels = varargin{4};
        wtsflag = varargin{5};
        vp = varargin{6};
    case 7
        t = varargin{1};
        xy = varargin{2};
        if isempty(varargin{3}),
            lc0.Color = 'b';
            lc0.LineStyle = '-';
            lc0.LineMarker = 'o';
        end
        labels = varargin{4};
        wtsflag = varargin{5};
        vp = varargin{6};
        bc = varargin{7};
    otherwise
        error('Incorrect Input Arguments');
end

% convert LineSpec to LineSpec structure
if size(lc0,1)==1,
    for k=1:2*(length(xy)-1),
        lc.Color(k)             = lc0.Color;
        lc.LineStyle(k)         = lc0.LineStyle;
        lc.LineMarker(k)        = lc0.LineMarker;
        lc.LineWidth(k)         = 1;
        lc.MarkerFaceColor(k)   = cellstr('w');
        lc.MarkerEdgeColor(k)   = lc0.Color;
        if ~isempty(labels)
            lc.MarkerSize(k)        = 20;
        else
            lc.MarkerSize(k)        = 8;
        end
    end
else
    lc = varargin{3};
end

% try and align the graph on the horzontal axis if possible
xy = lefthorzalign(xy);

% initialise the plot
if nargout>1
else
    h = newplot;
end

% find the vertices
[i,j] = find(t);

% generate coordinates for edges for adjaceny index
x = [xy(i,1) xy(j,1)]'; % x pos of node i and node j
y = [xy(i,2) xy(j,2)]'; % y pos of node i and node j

% process the line types and marker types
if wtsflag
    % cope with single marker case
    if size(t,1)==1 & size(t,2)==1,
    else
        % line width between 3 and 1 FIXM
        wts = t - min(t(t>=0));
        % scale between on [0,1]
        wts = wts / max(max(wts));
        % keep postive weights
        wts(wts<0)=0;
        % rescale on [1,3]
        wts = (3*wts + 1);
        % set the line widths
        for k=1:2*(length(xy)-1),
            lc.LineWidth(k)         = wts(i(k),j(k));
        end
        % if vertex property is set then look for nodes with the same property
        if ~isempty(vp)
            for k=1:length(i)
                if vp(i(k))==vp(j(k))
                    lc.Color(k) = char(bc{vp(i(k))});
                end
            end
        end
    end
else
end

% process the line types and marker types into three colour bins
% based on input argument of vertex property.
if ~isempty(vp)
    % LineSpec
    lm = lc;
    % set the marker properties for each vertex
    for k=1:length(vp),
        lm.Color(k)           = char(bc{vp(k)});
        lm.MarkerFaceColor(k) = cellstr(bc{vp(k)});
        lm.MarkerEdgeColor(k) = char(bc{vp(k)});
    end
    % if most of the connections share a property the edge shares the prop
else
    lm = lc;
end

if nargout<2
    % generate the lines on the edges
    for k=1:size(x,2)
        % lines
        h(k+1)=line('XData',x(:,k),'YData',y(:,k), ...
            'Color',lc.Color(k), ...
            'LineWidth',lc.LineWidth(k), ...
            'Marker','none');
    end
    
    % generate the markers looping over vertices
    for k=1:length(xy),
        h(k+1)=line('XData',xy(k,1),'YData',xy(k,2), ...
            'Color',lm.Color(k), ...
            'LineWidth',1, ...
            'Marker',lm.LineMarker(k), ...
            'LineStyle',lm.LineStyle(k), ...
            'MarkerFaceColor',lm.MarkerFaceColor{k},...
            'MarkerEdgeColor',lm.MarkerEdgeColor(k),...
            'MarkerSize',lm.MarkerSize(k));
    end
    
    % write text into the centre of each marker
    if ~isempty(labels)
        for k=1:length(xy)
            text(xy(k,1)-0.5*(lm.MarkerSize(k)/(lm.MarkerSize(k)*10)),xy(k,2),...
                cellstr(labels(k)),'FontSize',7);
        end
    end
    varargout{1} = h;
else
    % multiple output without plotting the graph
    varargout{2}.lm = lm;
    varargout{2}.lc = lc;
    varargout{2}.labels = labels;
    varargout{2}.xy = xy;
end
end

function xy=lefthorzalign(xy)
% HORZALIGN Align the tree on the horizontal axis

% get the distance between all the points and zero
[th0,r0]=cart2pol(xy(:,1),xy(:,2));
% find the maximum difference
[i,j]=max(r0);
% get the coordiante for the maximum distance
th0 = th0(j);
% iteratively rotate all the xy coords by tilt angle
for k=1:size(xy,1)
    [thk,rk]=cart2pol(xy(k,1),xy(k,2));
    [xy(k,1),xy(k,2)]= pol2cart(thk-th0,rk);
end
end
% EOF



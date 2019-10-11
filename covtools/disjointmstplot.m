function [mst,nMST,t] = disjointmstplot(varargin)
% DISJOINTMSTPLOT Plot disjoint minimal spanning trees 
%
%   DISJOINTMSTPLOT(T,XY,LINESPEC,LABEL,WTS,PROP,BC) The non-zero entries 
%   of T{I} are the distances or between the nodes that are used if MST is 
%   TRUE for the I disjoint graphs. LABEL is a cellstring array of size Nx1 
%   with a label for each node. WTS is TRUE to have weights used in plots 
%   and by default it is FALSE. PROP is the vertex property as a Nx1 
%   double. BC is the color vector associated with the property bins in 
%   PROP. By default PROP are numbers refering to three bins 1,2,3 and this 
%   are associated with BC = {'r','b','g'}.
%
% Example 1:
% 
% See Also: MINSPANTREE, ADJACENCY, MSTCOORDS, MSTPLOT, DMSTPLOT

% $Revision: 1.2 $ $Date: 2009/05/28 11:38:33 $ $Author: Tim Gebbie $

switch nargin
    case 7
        t= varargin{1};
        xy = varargin{2};
        LineSpec = varargin{3};
        labels = varargin{4};
        wtsflag = varargin{5};
        vp = varargin{6};
        bc = varargin{7};
    otherwise
        error('Incorrect input arguments');
end

% iniitalise the figure
h = newplot;

for i=1:length(t)
    % [h,mst{i}]  = mstplot(t{i},xy{i},LineSpec,labels{i},wtsflag,vp{i},bc); 
    [h,mst{i}]  = mstplot(t{i},xy{i},LineSpec,labels{i},wtsflag,vp,bc);
end
% compute the number of subplots
pn = ceil(sqrt(length(t)));
pm = ceil(length(t)/pn);
varargout{1}=[];
s0 = 1;

% loop over disjoint graphs
for i=1:length(t)
    h = subplot(pm,pn,i);
    % find the vertices
    [ii,ij] = find(t{i});
    % the co-ordinates
    x = [mst{i}.xy(ii,1) mst{i}.xy(ij,1)]'; % x pos of node i and node j
    y = [mst{i}.xy(ii,2) mst{i}.xy(ij,2)]'; % y pos of node i and node j
    % plot
    for k=1:size(x,2)
        % lines
        h(k+1)=line('XData',x(:,k),'YData',y(:,k), ...
            'Color',mst{i}.lc.Color(k), ...
            'LineWidth',mst{i}.lc.LineWidth(k), ...
            'Marker','none');
    end
    % generate the markers looping over vertices
    for k=1:size(mst{i}.xy,1),
        h(k+1)=line('XData',mst{i}.xy(k,1),'YData',mst{i}.xy(k,2), ...
            'Color',mst{i}.lm.Color(k), ...
            'LineWidth',1, ...
            'Marker',mst{i}.lm.LineMarker(k), ...
            'LineStyle',mst{i}.lm.LineStyle(k), ...
            'MarkerFaceColor',mst{i}.lm.MarkerFaceColor{k},...
            'MarkerEdgeColor',mst{i}.lm.MarkerEdgeColor(k),...
            'MarkerSize',mst{i}.lm.MarkerSize(k));
    end
    % write text into the centre of each marker
    if ~isempty(mst{i}.labels)
        for k=1:size(mst{i}.xy,1)
            text(mst{i}.xy(k,1)-0.5*(mst{i}.lm.MarkerSize(k)/(mst{i}.lm.MarkerSize(k)*10)),mst{i}.xy(k,2),...
                cellstr(mst{i}.labels(k)),'FontSize',7);
        end
    end
    % min and max extent
    set(gca,'Ylim',[min(min(y)), max(max(y))]+s0*[-0.5,+0.5],'Xlim',[min(min(x)), max(max(x))] + s0*[-0.5,0.5]);
    % set the aspect ratio
    daspect([1 1 1]);
    % turn off the axis
    axis off;
    % output arguments
    varargout{1} = [varargout{1} h];
end


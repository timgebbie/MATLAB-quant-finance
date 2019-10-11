%% Script file to generate minimal spanning tree 
%
% See Also : COVTOOLS

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:05 $ $Author: Tim Gebbie $

%% initialise
clear all; clc;

%% Keep only the 50 largest stocks by MV
x = randn(50,7);
mv = ret2tick(x);
mv = mv(2:end,:);
tickers0 = {'A','B','C','D','E','F','G'};

%% construct the correlation matrix
% remove the market mode
x0 = x;
x0(isnan(x0))=0;
x0 = average(x);
[c,s,m]=ewmacov(x0);

%% find the 4 accumlated return bins
PriceIndex = ret2tick(x);
nt=ntile(PriceIndex',3)';
ntc = {'red','yellow','green'};

%% find the 4 accumlated return bins
nt = m;
nt(m>0) = 3;
nt(m<=0) = 1;
ntc = {'red','yellow','green'};

%% Process the correlation matrices
clear Dmov;
aviobj = avifile('MST.avi','FPS',1);
scrsz = get(0,'ScreenSize');
fig=figure('Position',scrsz);
% axes1 = axes(fig,'Position',[0.13 0.688 0.775 0.237]);
for ti=1:size(s,3),
    r0 = squeeze(s(:,:,ti));
    % remove nan correlations
    r0(isnan(r0)) = 0;
    % correlation matrix to distance measure
    d0 = 1 - r0; % correlation distance matrix
    [m,n]=size(d0);
    for i=1:n-1,
        for j=i+1:n,
            d((i-1)*(m-i/2)+j-i) = d0(i,j);
        end
    end
    % create the linkage vector
    z0 = linkage(d);
    % find the minimal spanning tree
    a0 = adjacency(d);
    % find the minimal spanning tree using kruskal algo
    [mst,nmst,t]=minspantree(a0);
    % find the coordinates
    [xy] = mstcoords(t);
    % plot
    mstplot(t,xy,[],tickers0,true,nt(ti,:),{'r','b','g'})
    set(gca,'Ylim',[-5 5],'Xlim',[-5 14]);
    daspect([1 1 1]);
    % title
    title(sprintf('Tree on %s',datestr(today-size(s,3)+ti)));
    Dmov(ti) = getframe(fig);
    F = getframe(fig);
    aviobj = addframe(aviobj,F);
end
close(fig)
aviobj = close(aviobj);

%% Script file to generate minimal spanning tree 
%
% See Also : COVTOOLS, SECTOR

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:05 $ $Author: Tim Gebbie $

%% initialise
clear all; close all; clc;

%% Keep only the 50 largest stocks by MV
x = randn(50,10);
mv = ret2tick(x);
mv = mv(2:end,:);
tickers0 = {'A','B','C','D','E','F','G','H','I','J'};
nc = 3; % number of disjoint clusters
nci{1} = [1,2,3];
nci{2} = [4,5,6];
nci{3} = [7,8,9,10];

%% construct the correlation matrix
% remove the market mode
x0=x; 
x0(isnan(x0))=0;
x0 = average(x);

%% find the 4 accumlated return bins
PriceIndex = ret2tick(x);
% nt = ntile(PriceIndex',3)';
ntc = {'red','yellow','green'};

%% find the 4 accumlated return bins
ntc = {'red','yellow','green'};

%% Process the correlation matrices
clear Dmov;
aviobj = avifile('DMST-TEST.avi','FPS',1);
scrsz = get(0,'ScreenSize');
fig=figure('Position',scrsz);
% axes1 = axes(fig,'Position',[0.13 0.688 0.775 0.237]);
for ti=10:size(x0,1),
    for cj=1:nc
        r0 = corr(x0(ti-9:ti,nci{cj}));
        % the median
        m = median(x0(ti-9:ti,nci{cj}));
        nt0 = m; nt0(m>0) = 3; nt0(m<=0) = 1;
        nt{cj} = nt0;
        % remove nan correlations
        r0(isnan(r0)) = 0;
        % correlation matrix to distance measure
        d0 = 1 - r0(); % correlation distance matrix
        [m0,n0]=size(d0);
        d = []; % re-initialise distances
        for i=1:n0-1,
            for j=i+1:n0,
                d((i-1)*(m0-i/2)+j-i) = d0(i,j);
            end
        end
        % create the linkage vector
        z0 = linkage(d);
        % find the minimal spanning tree
        a0 = adjacency(d);      
        % find the minimal spanning tree using kruskal algo
        [mst{cj},nmst{cj},t{cj}]=minspantree(a0);
        % find the coordinates
        [xy{cj}] = mstcoords(t{cj});
        % the tickers
        tickers{cj} = tickers0(nci{cj});
    end
    % plot
    disjointmstplot(t,xy,[],tickers,true,nt,{'r','b','g'});
    title(sprintf('Tree on %s',datestr(today-size(x0,1)+ti)));
    Dmov(ti) = getframe(fig);
    F = getframe(fig);
    aviobj = addframe(aviobj,F);
end
close(fig)
aviobj = close(aviobj);

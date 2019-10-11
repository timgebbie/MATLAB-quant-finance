%% Script file to generate dendrogram for JSE
%
% Dataset #1: EPC_SPT_FAC_JSE_workspace_2008b_daily
%
% Dataset #2: JSE_D_DJSEOVER_31Jan1994_22Jan2009
%             LSE_D_LTOTMKUK_31-JAn1994_21Jan2009
%             JSE_TOP40_Tick_5mins_2008_2009
%
% See Also : COVTOOLS

% $Revision: 1.2 $ $Date: 2009/02/27 07:34:42 $ $Author: Tim Gebbie $

%% initialise
clear all; clc;
load('data/JSE_D_LJSEOVER_31Jan1994_22Jan2009');

%% Keep only the 50 largest stocks by MV
mv = jse_fts{3};
mv = mv('31-Jan-2008::20-Jan-2009');
mv = fts2mat(mv); % MV
tickers = fieldnames(jse_fts{3},1);
[smv, si]= sort(nanmedian(mv),'descend');
sizeidx = si(1:50);
tickers0 = tickers(sizeidx);
mv = mv(:,sizeidx);
xfts = jse_fts{2}; % RI
xfts = xfts.(tickers0);

%% construct the correlation matrix
% find the date range April 2008 - Jan 2009
xfts = xfts('31-Jan-2008::20-Jan-2009');
% find continuous time returns
rfts = tick2ret(xfts);
% convert into matrix
x = fts2mat(rfts);
% remove the market mode
x0 = average(x);
% covariance matrix : can use EWMA
% r0 = corr(x,'rows','pairwise');
[c,s,m]=ewmacov(x0);

%% Construct the market portfolio
MarketWts = mv ./ repmat(transpose(sum(transpose(mv))),1,size(mv,2));
MarketRet = x .* MarketWts;
MarketRet = transpose(sum(transpose(MarketRet)));
MarketRet(isnan(MarketRet))=0;
MarketRet(1) = 1;
MarketPrice = cumsum(MarketRet);
MarketPrice = fints(rfts.dates,MarketPrice,'JSE',rfts.freq,'Index');

%% find the 4 accumlated return bins
PriceIndex = ret2tick(rfts);
nt=ntile(fts2mat(PriceIndex)',3)';
ntc = {'red','yellow','green'};

%% Process the correlation matrices
clear Dmov;
aviobj = avifile('JSE_D_LJSEOVER_dendrogram.avi','FPS',5);
fig=figure;
% axes1 = axes(fig,'Position',[0.13 0.688 0.775 0.237]);
for ti=1:10 % size(s,3),
    r0 = squeeze(s(:,:,ti));
    % remove nan correlations
    r0(isnan(r0)) = 0;
    % cleaned covariance matrix
    Q = size(x,1)/size(x,2); % quality ratio N-dates, M-securities
    r0 = cov2clean(r0,Q);
    % make the correlation matrix positive semi-definite
    r0 = posdef(r0);
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
    % [xy] = coordinates(t);
    % create the date line
    subplot(2,2,2);
    h=plot(MarketPrice);
    h1=line(MarketPrice.dates(ti) * ones(1,2),get(gca,'YLim'),'Color','b','LineWidth',2);
    % create the spanning tree plot
    subplot(2,2,4);
    % gplot / treedisp 
    % create the dendrogram
    subplot(2,2,[1,3],'replace');
    [hd,td]=dendrogram(z0,0,'colorthreshold','default','orientation','left');
    % axes('Parent',fig,'Position',[0.13 0.11 0.775 0.4912]);
    title(sprintf('Tree on %s',datestr(rfts.dates(ti))));
    Dmov(ti) = getframe(fig);
    F = getframe(fig);
    aviobj = addframe(aviobj,F);
end
close(fig)
aviobj = close(aviobj);

%% Run animation
movie(Dmov,5);
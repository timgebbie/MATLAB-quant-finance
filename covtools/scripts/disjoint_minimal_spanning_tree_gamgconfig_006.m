%% Script file to generate minimal spanning tree (without market mode)
%
% See Also : COVTOOLS, SECTOR

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:05 $ $Author: Tim Gebbie $

%% initialise
clear all; close all; clc;

%% initialise
load('data/JSE_D_LJSEOVER_31Jan1994_22Jan2009');

%% Frequency
% convertto
for i=1:length(jse_fts), 
    jse_fts{i} = toweekly(jse_fts{i}); 
end;

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
% find the dates
end_date = datenum('22-Jan-2009');
% find continuous time returns
rfts = tick2ret(xfts);
% convert into matrix
x = fts2mat(rfts);
% remove the market mode
x0 = x;
x0(isnan(x0))=0;
% -- REMOVE MARKET MODE
x0 = average(x0);
% ---------------------
% covariance matrix : can use EWMA
% r0 = corr(x,'rows','pairwise');
[c,s,m]=ewmacov(x0);

%% Construct the market portfolio
MarketWts = mv ./ repmat(transpose(sum(transpose(mv))),1,size(mv,2));
MarketRet = x .* MarketWts(1:end-1,:);
MarketRet = transpose(sum(transpose(MarketRet)));
MarketRet(isnan(MarketRet))=0;
MarketRet(1) = 1;
MarketPrice = cumsum(MarketRet);
MarketPrice = fints(rfts.dates,MarketPrice,'JSE',rfts.freq,'Index');

%% find the 4 accumlated return bins
PriceIndex = ret2tick(rfts);
nt=ntile(fts2mat(PriceIndex)',3)';
ntc = {'red','yellow','green'};

%% find the 4 accumlated return bins
nt = m;
nt(m>0) = 3;
nt(m<=0) = 1;
ntc = {'red','yellow','green'};

%% Process the correlation matrices
clear Dmov;
aviobj = avifile('JSE_D_LJSEOVER_SPIN_MARKET.avi','FPS',1);
scrsz = get(0,'ScreenSize');
cxfts = fints;
% axes1 = axes(fig,'Position',[0.13 0.688 0.775 0.237]);
t0 = 60;
for ti=t0:t0+5; % size(s,3),
    c0 = squeeze(s(:,:,ti));
    % remove nan correlations
    nanidx = isnan(c0);
    c0(nanidx) = 0;
    % cleaned covariance matrix
    Q = size(x,1)/size(x,2); % quality ratio N-dates, M-securities
    c0 = cov2clean(c0,Q);
    % convert covariance to correlation matrix
    % make the correlation matrix positive semi-definite
    c0 = posdef(c0);
    [s0,r0]=cov2corr(c0)
    % Simulated annealing disjoint clustering algo
    [cx(ti,:),fval]=gamgconfig(r0,300,600,600,true);
    % Membership Matrix: Rows-Clusters, Columns-Objects
    disp(cx(ti,:));
    % CIXY  for cluster CJ CIXY(CJ,:) has the i-th element true if the 
    % i-th element is in cluster CJ otherwise the i-th element is false.
    % CIXY is of size number of cluster CJ and number objects dim(r0,1).
    cixy = false(max(cx(ti,:)),size(r0,1));
    for cj=1:max(cx(ti,:)),
       cixy(cj,(cx(ti,:)==cj)) = true;
    end
    % clear data structures
    clear t mst nmst tickersc xy;
    for cj=1:size(cixy,1)
        % correlation matrix to distance measure of stocks within cluster
        if sum(cixy(cj,:))>1,
            d0 = 1 - r0(cixy(cj,:),cixy(cj,:)); % correlation distance matrix
            [m,n]=size(d0);
            d = [];
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
            [mst{cj},nmst{cj},t{cj}]=minspantree(a0);
            % find the coordinates
            [xy{cj}] = mstcoords(t{cj});
            % the tickers
            tickersc{cj} = tickers0(cixy(cj,:));
        else
            % single point
            xy{cj} = [0,0];
            t{cj} = 1;
            tickersc{cj} = tickers0(cixy(cj,:));
        end
    end
    % plot
    % clf('reset');
    fig = figure('Position',scrsz);
    disjointmstplot(t,xy,[],tickersc,true,nt,{'r','b','g'});
    title(sprintf('Tree on %s',datestr(xfts.dates(ti))));
    % update cifts
    if isempty(cxfts)
        cxfts = fints(xfts.dates(ti),cx(ti,:),tickers0);
    else
        cxfts = vertcat(cxfts,fints(xfts.dates(ti),cx(ti,:),tickers0));
    end
    % get movie frame
    % Dmov(ti-t0+1) = getframe(fig);
    F = getframe(fig);
    aviobj = addframe(aviobj,F);
    % close(fig);
end
close(fig)
aviobj = close(aviobj);

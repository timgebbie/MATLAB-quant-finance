%% Script file to generate minimal spanning tree 
%
% See Also : COVTOOLS, SECTOR

% $Revision: 1.2 $ $Date: 2009/05/28 11:40:00 $ $Author: Tim Gebbie $

%% initialise
clear all; close all; clc;

%% initialise
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
    
    
end
aviobj = close(aviobj);
aviobj1 = close(aviobj1);

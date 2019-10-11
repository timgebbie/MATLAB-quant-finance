%% Script file to generate minimal spanning tree 
%
% See Also : COVTOOLS, SECTOR

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:05 $ $Author: Tim Gebbie $

%% initialise
clear all; close all; clc;

%% Input Data and Variables 
% Initial beta
ib      = 1;     
% Final beta
fb      = 50;  
% Number of sweeps between changes in temperature
t_steps = 100;    % temperature changes every t_steps 
% Max. number of annealing cycles                   
n_cycles= 150; 
% Cooling Factor for delta_temperature
cf      = 0.997; 

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
% find continuous time returns
rfts = tick2ret(xfts);
% convert into matrix
x = fts2mat(rfts);
% remove the market mode
x0 = x;
x0(isnan(x0))=0;
% x0 = average(x0);
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

%% find the 4 accumlated return bins
nt = m;
nt(m>0) = 3;
nt(m<=0) = 1;
ntc = {'red','yellow','green'};

%% Process the correlation matrices
clear Dmov;
aviobj = avifile('JSE_D_LJSEOVER_dendrogram.avi','FPS',1);
scrsz = get(0,'ScreenSize');
fig=figure('Position',scrsz);
% axes1 = axes(fig,'Position',[0.13 0.688 0.775 0.237]);
for ti=60:size(s,3),
    r0 = squeeze(s(:,:,ti));
    % remove nan correlations
    r0(isnan(r0)) = 0;
    % cleaned covariance matrix
    Q = size(x,1)/size(x,2); % quality ratio N-dates, M-securities
    r0 = cov2clean(r0,Q);
    % make the correlation matrix positive semi-definite
    r0 = posdef(r0);
    % Simulated annealing disjoint clustering algo
    [A] = annealing(r0,ib,fb,t_steps,n_cycles,cf);
    % Membership Matrix: Rows-Clusters, Columns-Objects
    A.gs.I
    % The configuration index I, where I(i,j)=k gives k object as the
    % j-th element of the i-th cluster.
    cin = max(max(A.gs.I));
    tci = 0;
    for ci=1:size(A.gs.I,1)
        ci0 = A.gs.I(ci,:);
        ci0 = ci0(ci0~=0);
        cixy0 = false(1,cin);
        if ~isempty(ci0),
            cixy0(ci0)=true;
            tci = tci+1;
            cixy(tci,:) = cixy0;
        end
    end
    for cj=1:size(cixy,1)
        % correlation matrix to distance measure of stocks within cluster
        if sum(cixy(cj,:))>1,
            d0 = 1 - r0(cixy(cj,:),cixy(cj,:)); % correlation distance matrix
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
    disjointmstplot(t,xy,[],tickersc,true,nt,{'r','b','g'});
    title(sprintf('Tree on %s',datestr(today-size(x0,1)+ti)));
    Dmov(ti) = getframe(fig);
    F = getframe(fig);
    aviobj = addframe(aviobj,F);
end
close(fig)
aviobj = close(aviobj);

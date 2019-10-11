%% Test script for covariance matrix arbitrage
%
% Long high-freq covariance matrix - Short low-freq covariance matrix
%
% Using JSE top 40 stocks we consider a 20 day rolling covariance matrix
% estimated daily. The low-frequency version is estimated at month end the
% high frequency version is estimate each day. We consider the different
% lead lags between covariance matrices and plot the return of the strategy
% of the lead-lag holding period.
%  
%

%% The Dataset
% JSE_D_LJSEOVER_31Jan1994_22Jan2009 Has 3909 datetimes for 166 stocks for
% item P, RI, MV, VO
%
load data\JSE_D_LJSEOVER_31Jan1994_22Jan2009.mat
% static data
mv = str2double(jse_data.MV);
tickers = jse_data.MNEM;
icb = str2double(jse_data.ICBSUC);
icbic = str2double(jse_data.ICBIC);
% sort by size into the largest 30 stocks
x = fts2mat(jse_fts{2});
[smv, si]= sort(mv,'descend');
sizeidx = si(1:40);
tickers0 = tickers(sizeidx);
icb0 = icb(sizeidx);
icbic0 = icbic(sizeidx);
[tickers0(:) num2cell(icbic0(:)) num2cell(icb0(:))]
% keep only the first two stocks
x = x(:,sizeidx);
x(isnan(x)) = 0;
x0 = tick2ret(x)+1;
x = tick2ret(x)+1;
[n0,d0]=size(x);
x(isnan(x))=1;
x0(isinf(x0))=1;
x0(isnan(x0))=1;
% datetimes
[n0,d0] = size(x0);

%% Compute the covariance matrix
% 1. Compute the daily EWMA covariance matrix
[c,s,m]=ewmacov(x0-1,0.96);

%% Optimal fully-Invested portfolio
% Compute the fully invested optimal portfolio for 1 to 20 day lagged
%       covariance matrix

% constraints
% controls sum to one
Aeq = ones(1,d0);
beq = 1;
% upper and lower bounds on [0,1] control sum to unity
Aineq = [Aeq;-Aeq;[eye(d0)];-[eye(d0)]];
bineq = [beq;-beq;0.10 * ones(d0,1);zeros(d0,1)];
% mean returns are zero
m0 = zeros(1,size(m,2));
b0 = 1/d0 * ones(size(m0)); % equally weighted initial control value
% portfolio options
qpoptions = optimset('quadprog');
qpoptions = optimset(qpoptions,'Display','off','LargeScale','off');
% loop over time
wh = waitbar(0,'optimization...');
for n=1:n0
    waitbar(n/n0,wh,'optimization...');
    Sigma = squeeze(s(:,:,n));
    [Std, Rho]= cov2corr(H);
    f = m0;
    H = Rho;
    [b(n,:),fval,exitflag] = quadprog(-H,-f,Aineq,bineq,[],[],[],[],b0,qpoptions);
    b(n,:) = epsclean(b(n,:));
end % n
close(wh);

%% Compute the returns
% 3. Compute the realised returns for the long 1 day covaraince and short
%       the lagged covariance matrix.
%

for n=1:n0-1
    for m=1:20
        % find the long-short portfolio
        bH(:,m,n) = [b(max(1,n-m),:) - b(n,:)];
        % compute the performance of the portfolio
        rS(n+1,m) = transpose(bH(:,m,n)) * transpose(x0(n+1,:));
    end % m
end % n

%% Accumulate the returns
TrS = cumprod(rS + 1);

%% Plot the simulation output
surf(TrS);
shading interp;

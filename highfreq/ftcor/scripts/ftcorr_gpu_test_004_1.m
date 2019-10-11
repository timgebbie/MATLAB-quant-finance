%% Test FTCOR using exponentially distributed data
% $ Author: C Malherbe, T Gebbie, D Hendricks $ $Date: 11/1/2006$

%% Detailed description
% This script file tests FTCOR by calculating the correlation of two
% synchronous series extracted from a simulated time series generated with
% different correlation coefficients.

%% Variable Declarations
clear                               % clear workspace
j = 1;                              % initialize variables
i = 1;
% N0 = 100;                           % set sample size of series
P1 = 0.90;                          % 10% of the data is missing
% nrsim = 20;                         % set number of monte carlo simulations
% expmean = 1;                        % set exponential mean
gpuOn = true;

resample_type{1} = 'Real Synchronous Data';
resample_type{2} = 'Real Asynchronous Data';

load('workspace_transactions_correltest_18stocks_1hour','transactionsTSresampled','transactionsTS','stocks'); %1 hour
%% define workers
if gpuOn
    cp = gcp('nocreate');
    if ~isempty(cp), delete(gcp); end
    mp = parpool(3);
end

%% Single iteration
% rho = ftcorrgpu(p,t,nR,mp);

%% Calculate correlation
% run ftcorrgpu for all stock-pairs in data set
[stockPairs] = combnk(1:size(stocks,1),2);
[numStockPairs] = size(stockPairs,1);
[numStocks] = size(stocks,1);
pSynch = double(transactionsTSresampled.Price);
priceReturnsSynch = (pSynch(2:end,2:end) - pSynch(1:end-1,2:end))./(pSynch(1:end-1,2:end));
priceReturnsSynch = zeroorderhold(priceReturnsSynch);

mergedPricesAsynch = mergets(transactionsTS);
pAsynch = double(mergedPricesAsynch.Price);
[idHolesAll] = isnan(pAsynch);
priceReturnsAsynch = (pAsynch(2:end,2:end) - pAsynch(1:end-1,2:end))./(pAsynch(1:end-1,2:end));
priceReturnsAsynch(isnan(priceReturnsAsynch)) = 0;
                
% elapsedTime = zeros(nrsim,1);
% ksim = -1:(2/(nrsim-1)):1;
% run simulations for different data types
for rt=1:length(resample_type)          
    ftac = zeros(numStocks,numStocks) + diag(diag(ones(numStocks))); 
    fourierMetrics(rt,1).ftac = zeros(numStocks,numStocks) + diag(diag(ones(numStocks))); 
    ftsg = zeros(numStocks,1);
    pc = zeros(numStocks,numStocks) + diag(diag(ones(numStocks))); 
    sg = zeros(numStocks,1);
    errftac = zeros(numStocks,numStocks);
    errpc = zeros(numStocks,numStocks);
    meanftac = zeros(1,numStocks);
    meanpc = zeros(1,numStocks);
    stdftac = zeros(1,numStocks);
    stdpc = zeros(1,numStocks);
    rmseftac = zeros(1,numStocks);
    rmsepc = zeros(1,numStocks);
    
    clear simdata;
    clear data;    
                
    for i=1:numStockPairs
        switch resample_type{rt}
            case 'Real Synchronous Data'        
                [p] = zeros(size(pSynch,1),3);
                [p(:,2:3), p(:,1)] = ret2tick([priceReturnsSynch(:,stockPairs(i,1)),priceReturnsSynch(:,stockPairs(i,2))], [1,1]);
                t = [p(:,1),p(:,1)];
                p = p(:,2:end);
                p = sparse(p);

            case 'Real Asynchronous Data'                
                %                     priceReturns = zeroorderhold(priceReturns);
                [p] = zeros(size(pAsynch,1),3);
                [p(:,2:3), p(:,1)] = ret2tick([priceReturnsAsynch(:,stockPairs(i,1)),priceReturnsAsynch(:,stockPairs(i,2))], [1,1]);
                t = [p(:,1),p(:,1)];
                [idHoles] = [idHolesAll(:,1),idHolesAll(:,stockPairs(i,1)),idHolesAll(:,stockPairs(i,2))];
                p(idHoles == 1) = 0;
                p = p(:,2:end);
                p = sparse(p);
        end
        % ensure that missing data in p is NaN in t for rescaling
        Ns = min(sum(~isnan(t)));
        % fourier coefficient range [1,35] for testing here
        nR = [0,round(Ns/2)]; % [1,Ns/(2)];
        % timing
        tstart = tic;
        % --------------------------------
        if gpuOn
            tic
            [rho,Sigma,sigma] = ftcorrgpu(p,t,mp);
            toc,
        else
            [rho,Sigma,sigma] = ftcorr(p,t);
            [rho0,Sigma0,sigma0] = ftcor([t(:,1),log(full(p(:,1)))],[t(:,2),log(full(p(:,2)))],length(p),500,1);
        end
        % end timing
        telapsed(stockPairs(i,1),stockPairs(i,2)) = toc(tstart);
        % --------------------------------
        ftac(stockPairs(i,1),stockPairs(i,2)) = rho(1,2);
        ftac(stockPairs(i,2),stockPairs(i,1)) = rho(1,2);
        ftsg(stockPairs(i,1),1) = sigma(1);
        ftsg(stockPairs(i,2),1) = sigma(2);
        
        fourierMetrics(rt,1).ftac(stockPairs(i,1),stockPairs(i,2)) = rho(1,2);
        fourierMetrics(rt,1).ftac(stockPairs(i,2),stockPairs(i,1)) = rho(1,2);
        fourierMetrics(rt,1).ftsg(stockPairs(i,1),1) = sigma(1);
        fourierMetrics(rt,1).ftsg(stockPairs(i,2),1) = sigma(2);        
        % elapsedTime(i,1) = toc;
        % sort on combined times
        t0 = union(t(:,1),t(:,2)); % union of datetimes
        % join
        p0 = zeros(length(t0),2);
        [~,a1,b1] = intersect(t0,t(:,1));
        p0(a1,1) = p(b1,1);
        [~,a2,b2] = intersect(t0,t(:,2));
        p0(a2,2) = p(b2,2);
        % treat non-trades as missing data
        p0(p0==0)=NaN;
        % compute the continous returns from the price data
        r0 = diff(log(p0));
        % compute missing data covariance
        S0 = nancov(r0);
        [s0,S0] = cov2corr(S0);
        pc(stockPairs(i,1),stockPairs(i,2)) = S0(2,1);
        pc(stockPairs(i,2),stockPairs(i,1)) = S0(2,1);
        sg(stockPairs(i,1),1) = s0(1);
        sg(stockPairs(i,2),1) = s0(2);
        %calculate relative errors    
        errcorrel(stockPairs(i,1),stockPairs(i,2)) = (ftac(stockPairs(i,1),stockPairs(i,2)) - pc(stockPairs(i,1),stockPairs(i,2)))/pc(stockPairs(i,1),stockPairs(i,2));
        errcorrel(stockPairs(i,2),stockPairs(i,1)) = (ftac(stockPairs(i,1),stockPairs(i,2)) - pc(stockPairs(i,1),stockPairs(i,2)))/pc(stockPairs(i,1),stockPairs(i,2));
        errsigma(stockPairs(i,1),1) = (ftsg(stockPairs(i,1),1) - sg(stockPairs(i,1),1))/sg(stockPairs(i,1),1);
        errsigma(stockPairs(i,2),1) = (ftsg(stockPairs(i,2),1) - sg(stockPairs(i,2),1))/sg(stockPairs(i,2),1);
        fourierMetrics(rt,1).errsigma(stockPairs(i,1),1) = (ftsg(stockPairs(i,1),1) - sg(stockPairs(i,1),1))/sg(stockPairs(i,1),1);
        fourierMetrics(rt,1).errsigma(stockPairs(i,2),1) = (ftsg(stockPairs(i,2),1) - sg(stockPairs(i,2),1))/sg(stockPairs(i,2),1);
    end
    
    %% Determine positive semi definite correlation matrix    
    ftac = nearest_posdef(ftac);
        
    %% calculate evaluation statistics
%     i = 1;
%     %repeat for different values of k
% %     for k = ksim
%         %calculate statistics for fourier method
%         %calculate bias
%         meanftac(i) = mean(errcorrel(1:nrsim,i));
%         meanpc(i) = mean(errsigma(1:nrsim,i));
%         %calculate standard deviation
%         stdftac(i) = std(errcorrel(1:nrsim,i));
%         stdpc(i) = std(errsigma(1:nrsim,i));
%         %calculate root mean square error
%         rmseftac(i) = 0;
%         rmsepc(i) = 0;
% %         for j = 1:nrsim
%             rmseftac(i) = rmseftac(i) + (k - ftac(j,i))^2;
%             rmsepc(i) = rmsepc(i) + (k - pc(j,i))^2;
% %         end
%         rmseftac(i) = rmseftac(i)/nrsim;
%         rmsepc(i) = rmsepc(i)/nrsim;
% %         i = i+1;
% %     end
    
    %% Results: Average correlation
    %This table and graph shows the average correlation obtained from both methods.  The
    %first column shows the value of k, the second the correlation obtained
    %from the Fourier method and the second the correlation obtained from the
    %Pearson method
    subplot(3,2,2*rt-1);
%     plot((1:nrsim),ksim,'r',(1:nrsim),mean(ftac),'g',(1:nrsim),mean(pc),'b');    
    pcolor(ftac)
%     if (2*rt-1==1)
%         legend('Induced \rho','Fourier','Estimated','Location','SouthEast')
%     end
%     % [ksim',mean(ftac)',mean(pc)']
    ylabel('Fourier correlation');
%     xlabel('Simulation');
    title(resample_type{rt});
    subplot(3,2,2*rt);
%     plot((1:nrsim),ones(nrsim,1),'r',(1:nrsim),mean(ftsg),'g',(1:nrsim),mean(sg),'b');
    pcolor(pc);
%     if (2*rt==2)
%         legend('Induced \sigma','Fourier','Estimated','Location','SouthEast')
%     end
%     % [ksim',mean(ftac)',mean(pc)']
    ylabel('Pearson correlation');
%     xlabel('Simulation');
    title(resample_type{rt});
    if rt==2
        subplot(3,2,5);
%         bar(fourierMetrics(1,1).ftsg(:,1),'r');
%         hold on;
%         bar(fourierMetrics(2,1).ftsg(:,1),'g');   
        scatter(fourierMetrics(1,1).ftsg(:,1),fourierMetrics(2,1).ftsg(:,1));
        legend('Synchronous','Asynchronous','Location','SouthEast')    
        ylabel('Fourier standard deviation');    
        title('Synchronous and Asynchronous volatility');
        
        subplot(3,2,6);
        bar(fourierMetrics(1,1).ftsg(:,1) - fourierMetrics(2,1).ftsg(:,1),'r');        
        legend('Synchronous','Asynchronous','Location','SouthEast')    
        ylabel('Synchronous - Asynchronous volatility');    
        title('Synchronous - Asynchronous volatility');
    end
    %% Clear GPU devices
    gpuDevice(1);
    gpuDevice(2);
    gpuDevice(3);
end % resample type

%% Close pool of workers
delete(mp);

%% Test FTCOR using exponentially distributed data
% $ Author: C Malherbe, T Gebbie, D Hendricks $ $Date: 11/1/2006$

%% Detailed description
% This script file tests FTCOR by calculating the correlation of two
% synchronous series extracted from a simulated time series generated with
% different correlation coefficients.

%% Variable Declarations
clear                               % clear workspace
j = 1;                              % initialize variables
N0 = 500;                           % set sample size of series
P1 = 0.60;                          % set % of missing data in simulated time series  
nrsim = 20;                         % set number of monte carlo simulations
expmean = 0.1;                      % set exponential mean
gpuOn = true;

resample_type{1} = 'Synchronous';
resample_type{2} = 'Synchronous Missing Data';
resample_type{3} = 'Asynchronous';  

fourierMethod = 'HY';   % set Fourier method type ['TrigFejer','ComplexExpFejer','HY','ComplexExpDirect']
onlyOverlapping = true;             % force condition of overlapping intervals for correlation estimation (Hybrid Hayashi-Yoshida)

%% define workers
if gpuOn
    cp = gcp('nocreate');
    if ~isempty(cp), delete(gcp); end
    mp = parpool(3);
%     matlabpool('open', 3);
%     mp = parcluster;
end

%% Single iteration
% rho = ftcorrgpu(p,t,nR,mp);

%% Calculate correlation
% run simulation for different correlation values, k
% elapsedTime = zeros(nrsim,1);
ksim = -1:(2/(nrsim-1)):1;
% run simulations for different data types
for rt=1:length(resample_type)
    % open new waitbar
    total = waitbar(0,'Total Progess');
    % reset counter
    j = 1;
    %% Preallocation of arrays
    ftac = zeros(nrsim);
    pc = zeros(nrsim);
    sg = zeros(nrsim);
    errftac = zeros(nrsim);
    errpc = zeros(nrsim);
    meanftac = zeros(1,nrsim);
    meanpc = zeros(1,nrsim);
    stdftac = zeros(1,nrsim);
    stdpc = zeros(1,nrsim);
    rmseftac = zeros(1,nrsim);
    rmsepc = zeros(1,nrsim);
    for k = ksim
        % run simulation
        for i = 1:nrsim
            waitbar((i + (j-1)*nrsim)/(nrsim * nrsim),total);
            clear simdata;
            clear data;
            % generate 2 series with correlation k
            switch resample_type{rt}
                case 'Synchronous Missing Data'
                    % generate prices (not log-prices)
                    simdata = gencordata(N0,k); % correlated unit variance pair
                    extract = simdata;
                    simdata = simdata(:,2:end);    
                    % MISSING DATA (Synchronous)
                    zindx = rand(size(simdata))>P1;
                    simdata(zindx)=0;
                    extract(:,2:end) = simdata;
                    t = repmat(extract(:,1),1,size(extract,2)-1);
                    t(zindx) = NaN; 
                    p = extract(:,2:end);
                    p = sparse(p);

                case 'Asynchronous'
                    %N1 = round(N0*(1-P1)*100);
                    N1 = round(N0/P1);
                    % generate prices from log-prices
                    simdata = gencordata(N1,k);
                    extract = simdata;
                    % ASYNCHRONOUS (random times)
                    t    = simdata(:,1);   
                    simdata = simdata(:,2:end);
                    % random times in time domain
                    tind = [randsample(N1,N0),randsample(N1,N0)]; % without replacement!
                    tind = sort(tind);
                    % get the times
                    t0 = zeros(size(tind));
                    t0(:,1) = t(tind(:,1),1);
                    t0(:,2) = t(tind(:,2),1);
                    % get the prices
                    p = zeros(size(tind));
                    p(:,1) = extract(tind(:,1),2);
                    p(:,2) = extract(tind(:,2),3);
                    % combine the times
                    t = union(t0(:,1),t0(:,2)); % union of datetimes
                    % join
                    p0 = zeros(length(t),2);
                    [~,a1,b1] = intersect(t,t0(:,1));
                    p0(a1,1) = p(b1,1);
                    [~,a2,b2] = intersect(t,t0(:,2));
                    p0(a2,2) = p(b2,2);
                    t = nan(size(p0));
                    t(a1,1) = t0(b1,1);
                    t(a2,2) = t0(b2,2);
                    % treat non-trades as missing data
                    p = p0; clear p0;
                    p = sparse(p);
                    
                case 'Synchronous'
                    % generate the prices from the log-prices
                    simdata = gencordata(N0,k);
                    extract = simdata;
                    % Synchronous data with no missing data
                    t = repmat(extract(:,1),1,size(extract,2)-1);
                    p = extract(:,2:end);
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
                [rho,Sigma,sigma] = ftcorrgpu(p,t,mp,fourierMethod,onlyOverlapping);
                toc,
            else
                [rho,Sigma,sigma] = ftcorr(p,t);
                [rho0,Sigma0,sigma0] = ftcor([t(:,1),log(full(p(:,1)))],[t(:,2),log(full(p(:,2)))],length(p),500,1);
            end
            % end timing
            telapsed(i,j) = toc(tstart);
            % --------------------------------
            ftac(i,j) = rho(1,2);
            ftsg(i,j) = sigma(1);
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
            pc(i,j) = S0(2,1);
            sg(i,j) = s0(1);
            %calculate relative errors
            if (k > 0)
                errftac(i,j) = (ftac(i,j) - k)/k;
                errpc(i,j) = (pc(i,j) - k)/k;
            end
        end
        j = j+1;
    end
    % close waitbar
    close(total);
    
    %% calculate evaluation statistics
    i = 1;
    %repeat for different values of k
    for k = ksim
        %calculate statistics for fourier method
        %calculate bias
        meanftac(i) = mean(errftac(1:nrsim,i));
        meanpc(i) = mean(errpc(1:nrsim,i));
        %calculate standard deviation
        stdftac(i) = std(errftac(1:nrsim,i));
        stdpc(i) = std(errpc(1:nrsim,i));
        %calculate root mean square error
        rmseftac(i) = 0;
        rmsepc(i) = 0;
        for j = 1:nrsim
            rmseftac(i) = rmseftac(i) + (k - ftac(j,i))^2;
            rmsepc(i) = rmsepc(i) + (k - pc(j,i))^2;
        end
        rmseftac(i) = rmseftac(i)/nrsim;
        rmsepc(i) = rmsepc(i)/nrsim;
        i = i+1;
    end
    
    %% Results: Average correlation
    %This table and graph shows the average correlation obtained from both methods.  The
    %first column shows the value of k, the second the correlation obtained
    %from the Fourier method and the second the correlation obtained from the
    %Pearson method
    subplot(3,2,2*rt-1);
    plot((1:nrsim),ksim,'r',(1:nrsim),mean(ftac),'g',(1:nrsim),mean(pc),'b');
    if (2*rt-1==1)
        legend('Induced \rho','Fourier','Estimated','Location','SouthEast')
    end
    % [ksim',mean(ftac)',mean(pc)']
    ylabel('\rho');
    xlabel('Simulation');
    title(resample_type{rt});
    subplot(3,2,2*rt);
    plot((1:nrsim),ones(nrsim,1),'r',(1:nrsim),mean(ftsg),'g',(1:nrsim),mean(sg),'b');
    if (2*rt==2)
        legend('Induced \sigma','Fourier','Estimated','Location','SouthEast')
    end
    % [ksim',mean(ftac)',mean(pc)']
    ylabel('\sigma');
    xlabel('Simulation');
    title(resample_type{rt});
end % resample type

%% Close pool of workers
delete(mp);
% matlabpool close;

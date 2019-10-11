%% Test FTCOR using exponentially distributed data
% $ Author: C Malherbe, T Gebbie, D Hendricks $ $Date: 11/1/2006$

%% Detailed description
% This script file tests FTCOR by calculating the correlation of two
% synchronous series extracted from a simulated time series generated with
% different correlation coefficients.

%% Variable Declarations
clear                               %clear workspace
total = waitbar(0,'Total Progess'); %measure overall progress
j = 1;                              %initialize variables
N0 = 600;                      %set sample size of series
nrsim = 25;                        %set number of monte carlo simulations
%resample_type ='asynchronous';  % 'missing' (10% missing),'none' 
resample_type = 'none';
%resample_type = 'missing';
expmean = 1;                      %set exponential mean

%% Preallocation of arrays
ftac = zeros(nrsim,10);
pc = zeros(nrsim,10);
errftac = zeros(nrsim,10);
errpc = zeros(nrsim,10);
kurtftac = zeros(1,10);
kurtpc = zeros(1,10);
meanftac = zeros(1,10);
meanpc = zeros(1,10);
stdftac = zeros(1,10);
stdpc = zeros(1,10);
skewftac = zeros(1,10);
skewpc = zeros(1,10);
rmseftac = zeros(1,10);
rmsepc = zeros(1,10);

%% define workers
cp = gcp('nocreate');
if ~isempty(cp), delete(gcp); end
mp = parpool(3);

%% Single iteration data preparation
% N=100; % length of data
simdata = gencordata(N0,0.5);
extract = simdata;
eSize = length(extract);
% data
t = [extract(1:eSize,1), extract(1:eSize,1)];
p = [extract(1:eSize,2), extract(1:eSize,3)];
% data as sparse for nonhomegeously sampled data
t = t; % there is a time 0 as we will be mapping to  [0,2*pi]
p = sparse(p); % there are no zero prices so use sparse
% ensure that missing data in p is NaN in t for rescaling
[pii,pj,~]=find(p);
ti = true(size(t));
ti(pii,pj) = false;
t(ti)=NaN;
% fourier coefficient range [1,35] for testing here
N =  min(max(pii)); % N is the minimum length non-missing data count 
nR = [1,N/2]; % FIXME 3: Nyquist
% nR = [1,35];

%% Single iteration
% rho = ftcorrgpu(p,t,nR,mp);

%% Calculate correlation
%run simulation for different correlation values, k
elapsedTime = zeros(nrsim,1);
ksim = -1:(2/(nrsim-1)):1;
for k = ksim
    % run simulation 
  	for i = 1:nrsim
        waitbar((i + (j-1)*nrsim)/(nrsim * nrsim),total);
        clear simdata;
        clear data;
        % generate 2 series with correlation k
        simdata = gencordata(N,k);
        extract = simdata;
        switch resample_type
            case 'missing'
                simdata = simdata(:,2:end);
                % randomly create 0 prices
                P1 = 0.90; % 10% of the data is missing
                % MISSING DATA (Synchronous)
                simdata(rand(size(simdata))>P1)=0;
                extract(:,2:end) = simdata;
                t = repmat(extract(:,1),1,size(extract,2)-1);
                p = extract(:,2:end);
            case 'asynchronous'
                % ASYNCHRONOUS (random times)
                tmax = max(simdata(:,1));
                tmin = min(simdata(:,1));
                simdata = simdata(:,2:end);
                % random times in time domain
                t = sort(tmin+rand(size(simdata))*tmax);
                p = extract(:,2:end);
            otherwise
                % Synchronous data with no missing data
                t = repmat(extract(:,1),1,size(extract,2)-1);
                p = extract(:,2:end);
        end
        % data as sparse for nonhomegeously sampled data
        t = t; % there is a time 0 as we will be mapping to  [0,pi]
        p = sparse(p); % there are no zero prices so use sparse
        % ensure that missing data in p is NaN in t for rescaling
        [pii,pj,~]=find(p);
        ti = true(size(t));
        for pk=transpose(unique(pj))
            ti(pii(pj==pk),pk) = false;
        end
        % OLD ti = extract(1:eSize,2:3)==0;
        t(ti)=NaN;
        Ns = min(sum(~isnan(t)));
        % fourier coefficient range [1,35] for testing here
        nR = [1,Ns/2];
        tic
        % ---
        [rho,~,~] = ftcorrgpu(p,t,nR,mp);
        % ---
        ftac(i,j) = rho(2,1);
        elapsedTime(i,1) = toc;
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
        % compute missing data covariance
        temp = nancov(p0);
        [~,temp] = cov2corr(temp);
        pc(i,j) = temp(2,1);
        %calculate relative errors
        if (k > 0)
            errftac(i,j) = (ftac(i,j) - k)/k;
            errpc(i,j) = (pc(i,j) - k)/k;
        end
	 end
    j = j+1;
end
close(total);

%calculate evaluation statistics
i = 1;
%repeat for different values of k
for k = ksim
    %calculate statistics for fourier method
    %calculate kurtosis
    kurtftac(i) = kurtosis(errftac(1:nrsim,i));
    kurtpc(i) = kurtosis(errpc(1:nrsim,i));
    %calculate bias
    meanftac(i) = mean(errftac(1:nrsim,i));
    meanpc(i) = mean(errpc(1:nrsim,i));
    %calculate standard deviation
    stdftac(i) = std(errftac(1:nrsim,i));
    stdpc(i) = std(errpc(1:nrsim,i));
    %calculate skewness
    skewftac(i) = skewness(errftac(1:nrsim,i)); 
    skewpc(i) = skewness(errpc(1:nrsim,i)); 
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
plot((1:nrsim),ksim,'r',(1:nrsim),mean(ftac),'g',(1:nrsim),mean(pc),'b');
legend('Induced correlation','Fourier','Pearson','Location','SouthEast')
[ksim',mean(ftac)',mean(pc)']
ylabel('Correlations');
xlabel('Simulation');
%% Results: Statistics on Fourier estimator
%This table shows the statistics of the relative errors for the Fourier
%estimator
[ksim',kurtftac',skewftac',stdftac',meanftac']
%% Results: Statics on Pearson estimator
%This table shows the statistics of the relative errors for the Pearson
%estimator
[ksim',kurtpc',skewpc',stdpc',meanpc']
%% Close pool of workers
delete(mp);

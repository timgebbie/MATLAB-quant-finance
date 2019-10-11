%% Test FTCOR using evenly spaced data
% $ Author: Chanel Malherbe $ $Date: 11/1/2006$
%% Detailed description
% This script file tests FTCOR by calculating the correlation of two
% evenly-spaced synchronous series 

%% Variable Declarations
clear                               %clear workspace
total = waitbar(0,'Total Progess'); %measure overall progress
j = 1;                              %initialize variables
N = 255;                            %set sample size of series
nrsim = 100;                        %set number of monte carlo simulations

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

%% Calculate correlation
%run simulation for different correlation values, k
for k = 0.1:0.1:1
    %run simulation 
  	for i = 1:nrsim
        waitbar((i + (j-1)*nrsim)/(nrsim * 10),total);
        clear simdata;
        clear data;
        %generate 2 series with correlation k
        simdata = gencordata(N,k);        
        ftac(i,j) = ftcor([simdata(1:N,1),simdata(1:N,2)],[simdata(1:N,1),simdata(1:N,3)],1,N);        
        temp = corr([simdata(1:N,2),simdata(1:N,3)]);
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
for k = 0.1:0.1:1
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
%Pearson method.  The Fourier correlation is shown in green and the pearson
%correlation in blue.
plot((1:10),(0.1:0.1:1),'r',(1:10),mean(ftac),'g',(1:10),mean(pc),'b');
legend('Induced correlation','Fourier','Pearson','Location','SouthEast')
[(0.1:0.1:1)',mean(ftac)',mean(pc)']
%% Results: Statistics on Fourier estimator
%This table shows the statistics of the relative errors for the Fourier
%estimator
%% Results: Relative errors of Fourier estimator
for i = 1:9
    subplot(3,3,i);
    hist(errftac(1:nrsim,i));
    title(i/10);
   % axis([-2 2 0 65]);
end
[(0.1:0.1:1)',kurtftac',skewftac',stdftac',meanftac',rmseftac']
%% Results: Statics on Pearson estimator
%This table shows the statistics of the relative errors for the Pearson
%estimator
for i = 1:9
    subplot(3,3,i);
    hist(errpc(1:nrsim,i));
    title(i/10);
   % axis([min(errpc(1:nrsim,i) max(errpc(1:nrsim,i) 0 65]);
end
[(0.1:0.1:1)',kurtpc',skewpc',stdpc',meanpc',rmsepc']
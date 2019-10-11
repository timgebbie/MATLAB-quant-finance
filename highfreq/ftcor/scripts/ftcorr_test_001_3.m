%%Test FTCOR using evenly spaced data
%
%This script tests the fourer estimator with simulated data, where the data
%series is created by extracting exponentially distributed data points from
%evenly spaced time series with known correlation.
% $ Author: Chanel Malherbe $ $Date: 11/1/2006$

%% Variable Declarations
clear                               %clear workspace
total = waitbar(0,'Total Progess'); %measure overall progress
nrsim = 2;                        %set number of monte carlo simulations
maxSeconds = 240;                   %maximum time scale
minSeconds = 3;                     %minimum time scale
nrSeconds = 6.5*60*60;              %size of series
k = 0.2;                            %correlation
inc = 1;                            %increments

%% Preallocation of Arrays
%The preallocation of arrays increases the speed of the script
ftac = zeros(nrsim,maxSeconds - minSeconds + 1);

%% Calculate correlation
for i = 1:nrsim
   % waitbar((i-1)/nrsim,total);
    %get the full series
    simdata = gencordata(nrSeconds,k);
    j = 1;
    %repeat for different time scales
    for nrfc = minSeconds:inc:maxSeconds
        %calculate fourier estimator
        waitbar(((i-1) + nrfc/maxSeconds)/nrsim,total);
        ftac(i,j) = ftcor([simdata(1:nrSeconds,1),simdata(1:nrSeconds,2)],[simdata(1:nrSeconds,1),simdata(1:nrSeconds,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        %calculate relative errors
        if (k > 0); errftac(i,j) = (ftac(i,j) - k)/k; end
        j = j+1;
    end
end
close(total);

%% Results:Fourier method analysis of simulated bivariate process
%% with induced correlation of k
[S,N] = size(ftac);
plot((1:N),mean(ftac(1:S,1:N)),(1:N),k)
xlabel('Time Scale (Minutes)')
ylabel('Correlation')


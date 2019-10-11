%%Test FTCOR using exponentially distributed synchronous and asynchronous
%%data
%
%This script tests the fourer estimator with simulated data, where the data
%series is created by extracting exponentially distributed data points from
%evenly spaced time series with known correlation.
% $ Author: Chanel Malherbe $ $Date: 11/1/2006$

%% Variable Declarations
clear                               %clear workspace
total = waitbar(0,'Total Progess'); %measure overall progress
nrsim = 100;                        %set number of monte carlo simulations
maxSeconds = 240;                   %maximum time scale
minSeconds = 3;                     %minimum time scale
nrSeconds = 6.5*60*60;              %size of series
k = 0.2;                            %correlation
inc = 1;                            %increments

%% Preallocation of Arrays
%The preallocation of arrays increases the speed of the script
ftac50 = zeros(nrsim,maxSeconds - minSeconds + 1);
ftac100 = zeros(nrsim,maxSeconds - minSeconds + 1);
ftac200 = zeros(nrsim,maxSeconds - minSeconds + 1);
ftac300 = zeros(nrsim,maxSeconds - minSeconds + 1);
ftac500 = zeros(nrsim,maxSeconds - minSeconds + 1);
ftac800 = zeros(nrsim,maxSeconds - minSeconds + 1);
ftac100_300 = zeros(nrsim,maxSeconds - minSeconds + 1);
ftac500_300 = zeros(nrsim,maxSeconds - minSeconds + 1);
ftac800_100 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac50 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac100 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac200 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac300 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac500 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac800 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac100_300 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac500_300 = zeros(nrsim,maxSeconds - minSeconds + 1);
errftac800_100 = zeros(nrsim,maxSeconds - minSeconds + 1);

%% Calculate correlation
for i = 1:nrsim
   % waitbar((i-1)/nrsim,total);
    %get the full series
    simdata = gencordata(nrSeconds,k);
    %extract exponentially distributed series from the full series
    data50 =   extractData(simdata(1:nrSeconds,1:3),50);
    data100 =   extractData(simdata(1:nrSeconds,1:3),100);
    data200 =   extractData(simdata(1:nrSeconds,1:3),200);
    data300 =   extractData(simdata(1:nrSeconds,1:3),300);
    data500 =   extractData(simdata(1:nrSeconds,1:3),500);
    data800 =   extractData(simdata(1:nrSeconds,1:3),800);
    %get the lenghts of the extracted seres
    N50 = length(data50);
    N100= length(data100);
    N200= length(data200);
    N300= length(data300);
    N500= length(data500);
    N800= length(data800);   
    j = 1;
    %repeat for different time scales
    for nrfc = minSeconds:inc:maxSeconds
        %calculate fourier estimator
        waitbar(((i-1) + nrfc/maxSeconds)/nrsim,total);
        ftac50(i,j) = ftcor([data50(1:N50,1),data50(1:N50,2)],[data50(1:N50,1),data50(1:N50,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac100(i,j) = ftcor([data100(1:N100,1),data100(1:N100,2)],[data100(1:N100,1),data100(1:N100,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac300(i,j) = ftcor([data300(1:N300,1),data300(1:N300,2)],[data300(1:N300,1),data300(1:N300,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac500(i,j) = ftcor([data500(1:N500,1),data500(1:N500,2)],[data500(1:N500,1),data500(1:N500,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac800(i,j) = ftcor([data800(1:N800,1),data800(1:N800,2)],[data800(1:N800,1),data800(1:N800,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac200(i,j) = ftcor([data200(1:N200,1),data200(1:N200,2)],[data200(1:N200,1),data200(1:N200,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac100_300(i,j) = ftcor([data100(1:N100,1),data100(1:N100,2)],[data300(1:N300,1),data300(1:N300,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac500_300(i,j) = ftcor([data500(1:N500,1),data500(1:N500,2)],[data300(1:N300,1),data300(1:N300,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac800_100(i,j) = ftcor([data800(1:N800,1),data800(1:N800,2)],[data100(1:N100,1),data100(1:N100,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        ftac800_500(i,j) = ftcor([data800(1:N800,1),data800(1:N800,2)],[data500(1:N500,1),data500(1:N500,3)],nrSeconds,round(nrSeconds/(60*nrfc)),1);
        %calculate relative errors
        if (k > 0)
           errftac800(i,j) = (ftac800(i,j) - k)/k;
           errftac500(i,j) = (ftac500(i,j) - k)/k;
           errftac300(i,j) = (ftac300(i,j) - k)/k;
           errftac100(i,j) = (ftac100(i,j) - k)/k;
           errftac500_300(i,j) =  (ftac500_300(i,j) - k)/k;
           errftac100_300(i,j) =  (ftac100_300(i,j) - k)/k;
           errftac800_100(i,j) =  (ftac800_100(i,j) - k)/k;
           errftac800_500(i,j) =  (ftac800_500(i,j) - k)/k;
        end
        j = j+1;
    end
end
close(total);

%% Results:Fourier method analysis of simulated bivariate process
%% with induced correlation of k
[S,N] = size(ftac100);
plot((1:N),k,(1:N),mean(ftac100(1:S,1:N)),(1:N),mean(ftac200(1:S,1:N)),(1:N),mean(ftac300(1:S,1:N)),(1:N),mean(ftac500(1:S,1:N)),(1:N),mean(ftac800(1:S,1:N)),(1:N),mean(ftac100_300(1:S,1:N)),':',(1:N),mean(ftac500_300(1:S,1:N)),':',(1:N),mean(ftac800_100(1:S,1:N)),':',(1:N),mean(ftac800_500(1:S,1:N)),':')
legend('k','data-100','data-200','data-300','data-500','data-800','data-100-300','data-300-500','data-800-100','data-800-500','Location', 'SouthEast')
xlabel('Time Scale (Minutes)')
ylabel('Correlation')


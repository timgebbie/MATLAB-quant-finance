%% SCRIPT FILE TESTING FTVAR
%Test FTVAR on real evenly spaced data 
%% Detailed Description
%
%%This script file tests the Fourier method of calculating correlation 
% proposed by  Malliavin and Mancino by calculating the average intra-daily
% correlation between two JSE-listed stocks over a specified number of
%days using rolling windows of increasing size

% $ Author: Chanel Malherbe $ $Date: 11/1/2006$

%% Load data
clear
load data_covariance
    
%% Variable Declarations
%2:AGL,3:AMS,10:DSY,9:DDT,12:FSR,13:GFI,40:SOL,31:PPC,37:SBK
series1 = 5;                                      %specify series to evaluate
series2 = 6;                                      %specify series to evaluate
total = waitbar(0,'Total Progess');             %measure overall progress

%% Calculate volatility using fourier method
%repeat for all the stocks

%clear necessary variables
clear ftv;clear rv;clear adjrv ;clear ret; clear dataftv;clear p; clear dates; clear windowSize;

%determine size of current series
nrobs = length(data_covariance.P);

%repeat for the selected number of days
i = 1;
for N = 2:50:nrobs 
    N
    %update the waitbars
    waitbar(N/nrobs,total);
    %get the day of the first tick1
    ftac(i) = ftcor([data_covariance.dates(1:N);data_covariance.P(1:N,series1)]',[data_covariance.dates(1:N);data_covariance.P(1:N,series2)]');
    temp = corr([data_covariance.P(1:N,series1),data_covariance.P(1:N,series2)]);
    pc(i) = temp(2,1)
    i = i+1;
end
% %calculate the average volatility for each time window
  meanFtac(1:length(mean(ftac))) = mean(ftac);
 close(total);
[r,N] = size(ftac);
%if the auction period is included, show all windows between 9:00 and 17:00
%if not, show windows between 9:30 and 16:30
if (includeAuction)
    startP = 1; endP = N;
else
    startP = 3; endP = N-2;
end

%% Display the results: Estimated Volatility
%This figure shows the realised variance (dotted blue line) and fourier volatility 
%(solid green line) for each of the 9 stocks.
plot(window(startP:endP),meanFtac(startP:endP),'b:')

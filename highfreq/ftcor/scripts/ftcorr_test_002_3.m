%% SCRIPT FILE TESTING FTVAR
%Test FTVAR on real evenly spaced data 
%% Detailed Description
%
%%This script file tests the Fourier method of calculating correlation 
% proposed by  Malliavin and Mancino by calculating the average intra-daily
% correlation between two JSE-listed stocks over a specified number of
%days using rolling windows of size 30.

% $ Author: Chanel Malherbe $ $Date: 11/1/2006$

%% Load data
clear
load data_covariance
    
%% Variable Declarations
series1 = 5;                                      %specify series to evaluate
series2 = 6;                                      %specify series to evaluate
total = waitbar(0,'Total Progess');               %measure overall progress

%% Calculate volatility using fourier method
%repeat for all the stocks

%clear necessary variables
clear ftv;clear rv;clear adjrv ;clear ret; clear dataftv;clear p; clear dates; clear windowSize;

%determine size of current series
nrobs = length(data_covariance.P);
windowSize = 30;
%repeat for the selected number of days
i = 1;
startP = 1;
endP = startP + windowSize;
while (endP < nrobs)
    endP
    %update the waitbars
    waitbar(i/nrobs,total);
    ftac(i) = ftcor([data_covariance.dates(startP:endP),data_covariance.P(startP:endP,series1)],[data_covariance.dates(startP:endP),data_covariance.P(startP:endP,series2)],round((endP - startP)/2));
    temp = corr([data_covariance.P(startP:endP,series1),data_covariance.P(startP:endP,series2)]);
    pc(i) = temp(2,1);
    i = i+1;
    startP = startP + 1;
    endP = startP + windowSize;
end
% %calculate the average volatility for each time window
  meanFtac(1:length(mean(ftac))) = mean(ftac);
 close(total);
[r,N] = size(ftac);
%if the auction period is included, show all windows between 9:00 and 17:00
%if not, show windows between 9:30 and 16:30
startP = 1; endP = N;

%% Display the results: Estimated Volatility
%This figure shows the realised variance (dotted blue line) and fourier volatility 
%(solid green line) for each of the 9 stocks.
plot((startP:endP),meanFtac(startP:endP),'b:')

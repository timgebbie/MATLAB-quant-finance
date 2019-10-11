%% IN PROGRESS:SCRIPT FILE TESTING FTVAR
%Test FTVAR on real high-frequency data
%% Detailed Description
%
%This script file tests the Fourier method of calculating correlation 
% proposed by  Malliavin and Mancino by calculating the average intra-daily
% correlation between two JSE-listed stocks over a specified number of
%days using rolling windows of size 1 hour incremented in specified
%intervals

% $ Author: Chanel Malherbe $ $Date: 11/1/2006$

%% Load data
%clear
%load jsedata

%% Variable Declarations
%2:AGL,3:AMS,10:DSY,9:DDT,12:FSR,13:GFI,40:SOL,31:PPC,37:SBK
series1 = 12;                                    %specify series to evaluate
series2 = 37;                                    %specify series to evaluate
nrDays = 100;                                     %set number of days
includeAuction = false;                         %auction period included or not
total = waitbar(0,'Total Progess');             %measure overall progress
inc = 5;                                        %the nr of minutes the window is rolled forward
maxSeconds = 240;                               %maximum time scale
minSeconds = 3;                                 %minimum time scale
nrSeconds = 6.5*60*60;                          %size of series

%%Preallocate Arrays
ftac = zeros(nrDays,maxSeconds - minSeconds + 1);
windowSize1 = zeros(nrDays);
windowSize2 = zeros(nrDays);

%% Calculate volatility using fourier method
%repeat for all the stocks

%clear necessary variables
clear ftv;clear rv;clear adjrv ;clear ret; clear dataftv;clear p; clear dates; clear windowSize;

%determine size of current series
nrobs1 = length(jsedata(series1).dates); nrobs2 = length(jsedata(series2).dates);

%set variables to store the date and time series of the current stock
PRC1 = jsedata(series1).PRC(1: nrobs1);PRC2 = jsedata(series2).PRC(1:nrobs2);
dates1 = jsedata(series1).dates(1:nrobs1);dates2 = jsedata(series2).dates(1: nrobs2);

%start at the beginning of the time series
tick1 = 1;tick2 = 1;

%repeat for the selected number of days
for d = 1:nrDays 
    waitbar(d/nrDays,total);
    %get the day of the first tick1
    time1 = datevec(jsedata(series1).dates(tick1));
    time2 = datevec(jsedata(series2).dates(tick2));
    day1 = time1(3);
    day2 = time2(3);
    
    %set the time to start rolling the windows
    times1(3) = day1;    
    times2(3) = day2;    
    j1 = 1; j2 = 1;
    %repeat for all ticks in the current day
    while (times1(3) == day1) &&(times2(3) == day2) 
        clear windowDates1; clear windowPRC1;clear windowDates2; clear windowPRC2;
        j1 = 1; j2 = 1;
        %get the current day
        times1 = datevec(dates1(tick1));
        times2 = datevec(dates2(tick2));
        %obtain all the price records for the current day
        %[datestr(dates1(tick1)),datestr(startTime),datestr(endTime)]
        while ((times1(3) == day1)&&(tick1 <= nrobs1-1))
            %store the ticks for the current day
            windowDates1(j1) = dates1(tick1);
            windowPRC1(j1) = PRC1(tick1); 
            j1 = j1+1;
            tick1 = tick1 + 1;
            times1 = datevec(dates1(tick1));
        end
        while ((times2(3) == day2)&&(tick2 <= nrobs2-1))
            %store the ticks for the current day
            windowDates2(j2) = dates2(tick2);
            windowPRC2(j2) = PRC2(tick2);
            j2 = j2+1;
            tick2 = tick2 + 1;
            times2 = datevec(dates2(tick2));
        end
        %if there are more than 2 datapoints, calculate volatility
        i = 1;
        for nrfc = minSeconds:inc:maxSeconds
            [d,i]
            if ((j1 > 2)&&(j2>2))
                windowSize1(d) = length(windowDates1)
                windowSize2(d) = length(windowDates2)
                %calculate the fourier volatility using Nyquist frequency
                ftac(d,i) = ftcor([windowDates1;windowPRC1]',[windowDates2;windowPRC2]',6.5*60*60,round(nrSeconds/(60*nrfc)),1);
                %calculate the average returns
            end    
            i = i+1;
        end
     end
end
close(total);
[r,N] = size(ftac);

%% Display the results: Estimated Volatility 
plot(mean(ftac),'b:')
    
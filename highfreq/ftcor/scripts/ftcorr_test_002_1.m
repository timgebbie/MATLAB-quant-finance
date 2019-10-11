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
clear
load jsedata

%% Variable Declarations
%2:AGL,3:AMS,10:DSY,9:DDT,12:FSR,13:GFI,40:SOL,31:PPC,37:SBK
series1 = 2;                                      %specify series to evaluate
series2 = 3;                                      %specify series to evaluate
nrDays = 10;                                     %set number of days
includeAuction = false;                         %auction period included or not
total = waitbar(0,'Total Progess');             %measure overall progress
nrSeconds = 24*60*60;
inc = 5;                                        %the nr of minutes the window is rolled forward

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
    %d
    %update the waitbars
    waitbar(d/nrDays,total);
    %get the day of the first tick1
    time1 = datevec(jsedata(series1).dates(tick1));
    time2 = datevec(jsedata(series2).dates(tick2));
    day1 = time1(3);
    day2 = time2(3);
    %set the time to start rolling the windows
    startHour = 9;startMinute = 0;
    startTime = datenum(time1(1),time1(2),time1(3),startHour,startMinute,0);
    endTime = datenum(time1(1),time1(2),time1(3),startHour+1,startMinute-1,59);
    nrWindow = 1;
    window(nrWindow) = 9;
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
        while ((dates1(tick1) <= endTime)&&(dates1(tick1) >= startTime)&&(times1(3) == day1)&&(tick1 <= nrobs1-1))
            %store the ticks for the current day
            windowDates1(j1) = dates1(tick1);
            windowPRC1(j1) = PRC1(tick1); 
            j1 = j1+1;
            tick1 = tick1 + 1;
            %ts = datevec(dates(tick1) - dates(tick1 - 1));
            times1 = datevec(dates1(tick1));
        end
        while ((dates2(tick2) <= endTime)&&(dates2(tick2) >= startTime)&&(times2(3) == day2)&&(tick2 <= nrobs2-1))
            %store the ticks for the current day
            windowDates2(j2) = dates2(tick2);
            windowPRC2(j2) = PRC2(tick2);
            j2 = j2+1;
            tick2 = tick2 + 1;
            %ts = datevec(dates(tick1) - dates(tick1 - 1));
            tickSize2(tick2-1) = (dates2(tick2) - dates2(tick2-1))*nrSeconds;
            times2 = datevec(dates2(tick2));
        end
       %get the time of the next tick
        if (startTime == 60-inc)
            startHour = startHour + 1;startMinute = 0;
        else
            startMinute = startMinute + inc;
        end
        startTime = datenum(time1(1),time1(2),time1(3),startHour,startMinute,0);
        endTime = datenum(time1(1),time1(2),time1(3),startHour+1,startMinute-1,59);
        %if there are more than 2 datapoints, calculate volatility
        if ((j1 > 2)&&(j2>2))
            windowSize1(d,nrWindow) = length(windowDates1);
            windowSize2(d,nrWindow) = length(windowDates2);
            %calculate the fourier volatility using Nyquist frequency
            %datestr(windowDates1)
            ftac(d,nrWindow) = ftcor([windowDates1;windowPRC1]',[windowDates2;windowPRC2]',60,6.5*60*60);
            %calculate the average returns
        end           
        nrWindow = nrWindow + 1;
        window(nrWindow) = window(nrWindow-1) + 1/60;
    end
end
% %calculate the average volatility for each time window
  meanFtac(1:length(mean(ftac))) = mean(ftac);
% meanRv(s,1:length(mean(rv))) = mean(rv);
% meanRet(s,1:length(mean(ret))) = mean(ret);
% meanNrTicks(s,1:length(mean(windowSize))) = mean(windowSize);
% nrTicks(s) = tick1;
% 
% 
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
    %title(jsedata(series(s)).code);
    %axis([window(startP),window(endP),0,max(meanFtv(s,startP:endP))]);
    %set(gca,'XTickLabel',datestr(jsedata(series(s)).dates(1:N)))

% 
% %% Display the results: Mean Returns
% %This figure shows the mean return per window per series
% for s = 1:nrSeries
%     subplot(3,3,s);
%     plot(window(startP:endP),meanRet(s,startP:endP));
%     title(jsedata(series(s)).code);
%     axis([window(startP),window(endP),0,max(meanRet(s,startP:endP))]);
%     %set(gca,'XTickLabel',datestr(jsedata(series(s)).dates(1:N)))
% end
% 
% %% Display the results: Number of ticks per window
% for s = 1:nrSeries
%     subplot(3,3,s);
%     plot(window(startP:endP),meanNrTicks(s,startP:endP)); 
%     title(jsedata(series(s)).code);
%     %axis([window(startP),window(endP),0,max(meanNrTicks(s,startP:endP))]);
%     axis([window(startP) window(endP) 0 40]);
% end
% 
% %% Display the time between ticks
% %This graph shows the log of the time between ticks.  The fact that the
% %distribution of the log times appears normal shows that the distribution
% %of the times are exponential.
% for s = 1:nrSeries
%     subplot(3,3,s);
%     hist(log(tickSize(s,1:nrTicks(s)-1)),100);
%     title(jsedata(series(s)).code);
% end
% 
% %% Display the mean time between ticks
% %This graph shows the mean time between ticks.  
% %Clear series 3:DSY and 8:PPC are much less liquid than the rest of the
% %stocks
% for s = 1:nrSeries
%     meanPerSeries(s) = mean(tickSize(s,1:nrTicks(s)-1));
% end
% subplot(1,1,1);
% bar(meanPerSeries);
% 
% 
% 
% 
% 
% 

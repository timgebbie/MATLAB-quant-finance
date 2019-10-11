%%  Test code for ICHIMOKU
%
% Authors: Tim Gebbie

% $Revision: 1.3 $ $Date: 2009/03/03 07:19:56 $ $Author: Tim Gebbie $

%% Generate test data
p = cumsum(randn(100,3)* 0.10);

%% Help files
help ichimoku

%% Run plot
ichimoku(p);

%% Run without plots
[f,i,t]=ichimoku(p);

%% Indicators
i

%% trend
t

%% Example loading from Bloomberg
blp = bloomberg;
data = fetch(blp,'AGL SJ Equity','HISTORY',{'Open','High','Low','Last_Price'},'1/01/08','9/30/08','d');
fts = fints(data(:,1),data(:,2:5),{'Open','High','Low','Close'});
ichimoku(fts);

%% Example not using FINTS
op = fts2mat(fts.Open);
hi = fts2mat(fts.High);
lo = fts2mat(fts.Low);
cl = fts2mat(fts.Close);
ichimoku(op,hi,lo,cl);

%% Example indicators and trend
[f,i,t]=ichimoku(fts);
plot(fints(fts.dates,i,'ICHIMOKU_IND'));
xlabel('Date-Time');
ylabel('Buy-Sell');
title('Buy-Sell (+3 to -3) based on Ichimoku Studies');

%% Indicators via online method
figure; clear ind;
for j=1:10
    [f,i,t]=ichimoku(fts(1:end-j));
    ind(j)= i(end)
    plot(i(end-100:end));
    hold on;
end
hold off;



%% Equity Indices 
%
% 3 Equity sectors RESI, FINI, INDI and 1 bond ALBI
%
% J200, J200T - ALSI 40 (TOP 40)
% J203, J203T - ALSI (All Share Index)
% J210, J210T - Resource 20
% J211, J211T - Financial 15
% J212, J212T - Industrial 25
% JAPI05      - Fixed Income Price Index (ALBI)
%
% J213 - Finanical and Industrial
%
% Using scenario analysis

%% Initialize workspace
clear all; clc;

%% set the epoch range for the simulation
%StartDate = '31-Dec-2009';
StartDate = '01-Oct-2008';
EndDate = today;
epoch_range = daterange(StartDate,EndDate); 
dates = daterange(epoch_range);

%% required test data items (Test Factors)
% the raw factor data
ds_eq  = {'TOP40 Index'};

%% required input data items

%% load the required datastream data
c =blp;
% use the FDS to get the datastream data
% I= timeseries(c,ds_eq,{StartDate,EndDate},[],'Trade');
I = history(c,ds_eq,'LAST_PRICE',StartDate,EndDate,'daily');
I = fints(I);

%% Convert the data to a time-series objects
% convert the datastream data into time-series objects
prc = fts2mat(I);
datetimes = I.dates;

%% Save the data
save top40_test_data prc datetimes;

%% Prepare the data
figure;
si = 1;
rawdata = [datetimes(si:end), prc(si:end)];
plot(rawdata(2:end,2));
hold on;
a= [1];
b= [0.90:-0.01:0.1].^4;
b = b./sum(b);
% rawdata(:,2) = filter(b,a,rawdata(:,2));
plot(rawdata(2:end,2));
ytilde  = log(rawdata(2:end,2));  % column data of ln(ZAR/USD) exchange rate (including NAN missing data)
t       = rawdata(2:end,1)./ 365.25;   % dates for the data (days since AD began) convert days to years

%% Set the initial parameters
%    (A,B,C,BETA,TC,OMEGA,PHI)
para_str ={'A','B','C','\beta','t_c','\omega','\phi'};
p0 = [3.5, -3,2.27,0.35,2003,7,-14]; % initial parameters
lb = [ 0, -10,  0, -10, max(t),  0,  0];
ub = [10,  10, 10,  10, 2011, 20, 20];

%% Estimate the parameters
% get the option set
options = optimset('lsqnonlin');
% modify options
options.MaxFunEvals = 1000*length(p0);
options.MaxIter     = 30000;
options.Display     = 'iter';
options.TolFun      = 1e-3;
options.TolX        = 1e-3;
% carry out the model calibration
% [p1,resn,res,eflag] = lsqerr(@logp,t,p0,ytilde,[],[],options);
[p1,resn,res,eflag] = lsqerr(@logp,t(end-30:end),p0,ytilde(end-30:end),lb,ub,options);
[p2,resn,res,eflag] = lsqerr(@logp,t(end-60:end),p0,ytilde(end-60:end),lb,ub,options);
[p3,resn,res,eflag] = lsqerr(@logp,t,p0,ytilde,lb,ub,options);

%% Find the best theory
% simulation range
t1 = [t(1):mean(diff(t)):p2(5)];
% define theoretical prediction
best_theory(:,1) = logp(t1(:),p1);
best_theory(:,2) = logp(t1(:),p2);
best_theory(:,3) = logp(t1(:),p3);

%% Plot the best LSQERR theory
figure;
plot(t, ytilde);
xlabel('Time');
ylabel('Price');
line(t1(end-90:end)',best_theory(end-90:end,1),'Color','r');
line(t1(end-150:end)',best_theory(end-150:end,2),'Color','g');
line(t1',best_theory(:,3),'Color','k');
% plot crash times
line([p1(5),p1(5)],[min(ytilde),max(ytilde)],'Color','r');
line([p2(5),p2(5)],[min(ytilde),max(ytilde)],'Color','g');
line([p3(5),p3(5)],[min(ytilde),max(ytilde)],'Color','k');
legend('data','scenario1','scenario2','scenario3');
set(gca,'YLim',[min(ytilde),1.05*max(ytilde)]);
title(sprintf('%s,%s and %s',datestr(365.25*p1(5)),datestr(365.25*p2(5)),datestr(365.25*p3(5))));
% Check mixing/convergence using R-statistic (Verde et al)

%% Fit using MCMC

%% Fit using LSQERR

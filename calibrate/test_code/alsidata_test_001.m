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
epoch_range = daterange('31-Dec-1993',today); 
dates = daterange(epoch_range);

%% required test data items (Test Factors)
% the raw factor data
ds_eq  = {'J200,J203,J210,J211,J212,J200T,J203T,J210T,J211T,J212T'};
ds_lb  = {'JAPI04'}; % Long Bonds
ds_fi  = {'JAPI05'}; % ALBI
ds_cs  = {'NC3MM'};  % GMC1
all_assets = [commalist2cell(ds_eq{:}); ds_fi; ds_cs];

%% required input data items

%% load the required datastream data
% use the FDS to get the datastream data
I = inet('hist',all_assets,'CLOSE',datestr(dates(1),'dd-mm-yy'),datestr(dates(2),'dd-mm-yy'),'W');
% d2  = fds(all_codes,in_fg1,'FG_QED',epoch_range);

%% Convert the data to a time-series objects
% convert the datastream data into time-series objects
prc = fints(I,'W');

%% Save the data
save alsidata_test prc;

%% Set epoch range
epoch = '31-Jan-2000::31-Jun-2006';

%% Prepare the data
plot(prc.J200);
rawdata = fts2mat(prc(epoch).J200,1);
ytilde  = log(rawdata(:,2));  % column data of ln(ZAR/USD) exchange rate (including NAN missing data)
t       = rawdata(:,1)./ 365.25;   % dates for the data (days since AD began) convert days to years

%% Set the initial parameters
%    (A,B,C,BETA,TC,OMEGA,PHI)
para_str ={'A','B','C','\beta','t_c','\omega','\phi'};
p0 = [3.5, -3,2.27,0.35,2003,7,-14]; % initial parameters
lb = [ 0, -10,  0, -10, max(t),  0,  0];
ub = [10,  10, 10,  10, 2010, 20, 20];

%% Estimate the parameters
% get the option set
options = optimset('lsqnonlin');
% modify options
options.MaxFunEvals = 1000*length(p0);
options.MaxIter     = 10000;
options.Display     = 'iter';
options.TolFun      = 1e-5;
options.TolX        = 1e-5;
% carry out the model calibration
[p1,resn,res,eflag] = lsqerr(@logp,t,p0,ytilde,[],[],options);
[p2,resn,res,eflag] = lsqerr(@logp,t,p0,ytilde,lb,ub,options);

%% Find the best theory
% simulation range
t1 = [t(1):mean(diff(t)):min(p1(5),p2(5))];
% define theoretical prediction
best_theory(:,1) = logp(t1(:),p1);
best_theory(:,2) = logp(t1(:),p2);

%% Plot the best LSQERR theory
figure;
plot(t, ytilde);
xlabel('Time');
ylabel('Price');
line(t1,best_theory(:,1),'Color','r');
line(t1,best_theory(:,2),'Color','g');
% plot crash times
line([p1(5),p1(5)],[0,max(ytilde)],'Color','r');
line([p2(5),p2(5)],[0,max(ytilde)],'Color','g');
legend('data','unbounded','bounded');
% Check mixing/convergence using R-statistic (Verde et al)

%% Fit using MCMC

%% Fit using LSQERR

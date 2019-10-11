%% Script File to estimate log-periodic fit to USDZAR rand crash using MCMC
%
% Data is USD/ZAR over 15000 days starting in 1960
%
% Function is: 
%
% $$ ln(t) = A + B(t_c-t)^\beta + C (t_c-t)^\beta cos( \omega ln(t_c-t) - \phi)$$
%
% From Sornette and Johansen, Quantitative Finance, 1, 452, 2001
%
% Fitting Parameters are: (A, B, C, beta, t_c, w, phi)
%
% dates are given in days since AD began but converted to approximate years using 365.25 d/yr
%
% Author: Tim Gebbie

%% Clear the workspace
clear all;
clc;

%% Set initial conditions for parameter chain vector p
%    (A,B,C,BETA,TC,OMEGA,PHI)
para_str ={'A','B','C','\beta','t_c','\omega','\phi'};
epoch = '28-Jan-1998::31-Oct-2001';
p0 = [3.5, -3,2.27,0.35,2003,7,-14]; % initial parameters
lb = [ 0, -10,  0, -10, 2000,  0,  0];
ub = [10,  10, 10,  10, 2005, 20, 20];

%% Load the data
ZAR=fints(inet('hist','usdzar','CLOSE','16-04-95','25-12-01','W'));
% load data/workspace_zar.mat;  % load file

%% Prepare the data
plot(ZAR);
rawdata = fts2mat(ZAR(epoch).CLOSE,1);
ytilde  = log(rawdata(:,2));  % column data of ln(ZAR/USD) exchange rate (including NAN missing data)
t       = rawdata(:,1)./ 365.25;   % dates for the data (days since AD began) convert days to years

%% Estimate the parameters
[p1,resn,res,eflag] = lsqerr(@logp,t,p0,ytilde);
[p2,resn,res,eflag] = lsqerr(@logp,t,p0,ytilde,lb,ub);

%% Find the best theory
% simulation range
t1 = [t(1):mean(diff(t)):min(p1(5),p2(5))];
% define theoretical prediction
best_theory(:,1) = logp(t1(:),p1);
best_theory(:,2) = logp(t1(:),p2);

%% Plot the best theory
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


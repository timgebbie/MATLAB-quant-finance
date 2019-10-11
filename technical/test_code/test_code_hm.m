% Developer Notes:
%
% Author        - Daniel Polakow and Anthony Seymour
%                 Quantitative and Derivative Analyst
%                 Peregrine Securities
% Email address - danielp@peregrine.co.za 
% Website       - http://www.peregrine.co.za/
% Created       - 03 November 2006  
% Last revision - 09 November 2006
%
% Parameter descriptions
% 
% Threshold     Percentage (%) of observations that are required in the
%               tails separately (both positive and negative)
%
% Required functions
%
% PeaksToTroughIntervals.m - Interval.m

% $Revision: 1.1 $ $Date: 2008/07/23 05:26:07 $ $Author: Tim Gebbie $

%% 1 Load Hazarddata.csv and summarize - dates and closing prices of index of interest
hdata = importdata('C:\MATLAB\R2006a\toolbox\hazard\test_code\Hazarddata.csv',','); % Data for primary variable estimation 
hdata(:,1) = x2mdate(hdata(:,1)); % get the excel dates into matlab format

%% 2. Estimate the probabilities
threshold = 0.1;
out = hm(hdata,threshold)

%% 3 Report to Screen if there is no functional output
plot(out.t,out.hazard,'Color','r');
title(sprintf('Weibull Hazard Parameterization at a threshold (%%) of: %2.3f',out.threshold));
xlabel('Time from extreme event');
ylabel('Instananeous probability of next event');
labelx = sprintf('Hazard Rate = %2.3f with time since last extreme event being: %2.3f %s \n Current p(event)= %2.3f \n mean = %2.3f \n mode = %2.3f \n Upper/Lower Thresholds of return = %2.3f \n', ...
         out.parmhat(2),out.censored_interval,out.units,out.hazard_current,out.mean_Weibull,out.mode_Weibull,out.cutoffs(1));
text((max(out.t)/6),(max(out.hazard)/2),labelx);

%% Using Inet J200 data weekly sampled
I = inet('hist','J200','CLOSE','-240','','M');
fts = fints(I,'M');
rfts = tick2ret(fts,'Continuous');

%% Plot the hazard rates
hm(fts2mat(rfts,1),0.05);

%% Using Inet J200 data weekly sampled
I = inet('hist','J200T','CLOSE','-700','','W');
fts = fints(I,'W');
rfts = tick2ret(fts,'Continuous');

%% Plot the hazard rates
hm(fts2mat(rfts,1),0.05);

%% Plot the hazard rate surfaces
rfts = rfts('07-Jul-1995::24-Nov-2006');
for i=1:52,
    rftsi = rfts(1:end-i);
    lh{i}=hm(fts2mat(rftsi,1),0.05);
    h(lh{i}.t,i) = lh{i}.hazard;
end;

%% Create the surface
for i=1:52.
    yi(:,i) = interp1(lh{i}.t,lh{i}.hazard,lh{1}.t);
    ch(i) = lh{i}.hazard_current;
end;
surf (yi);
shading interp;
zlabel('Instantaneous Probability');
xlabel('Delay in Weeks');
ylabel('Weeks since last event');

%% Create the temporal behaviour of the probability
plot(ch);
xlabel('Delay in Weeks');
ylabel('Instantaneous Probability');
title(sprintf('The instaneous probability of a %2.2f draw down peak-to-trough',lh{1}.threshold));
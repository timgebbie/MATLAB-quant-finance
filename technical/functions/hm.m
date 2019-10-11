function [out] = hm(Hdata,Threshold),
% HM Hazard rate from Threshold using Weibull distribution
%
% OUT = HM(DATA,THRESHOLD) Percentage (%) of observations that 
%       are required in the tails separately (both positive and 
%       negative) using the DATA in DATA.
%
% See Also: PTINTERVALS

% $Revision: 1.1 $ $Date: 2008/07/23 05:24:39 $ $Author: Tim Gebbie $

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

%% 1 Load Hazarddata.csv and summarize - dates and closing prices of index of interest
if isempty(Hdata),
    Hdata = importdata('Hazarddata.csv',','); % Data for primary variable estimation  
end;   
size_Hdata = size(Hdata);
    
%% 2 Compute time unit between subsequent dates and record
%  Designate 'Unit'
%           1 = days (1, 252 per year)
%           2 = weeks (5-7, 52 per year)
%           3 = months (28-32, 12 per year)
%           4 = other (<1 || >33 || other, error)
Daysbetween = Hdata(2,1)-Hdata(1,1);

if Daysbetween == 1
    Unit = 1;
    units_of_anal = 'D';
elseif Daysbetween >=5 && Daysbetween <=8
    Unit = 2;
    units_of_anal = 'W';
elseif Daysbetween >=28 && Daysbetween <= 32
    Unit = 3;
    units_of_anal = 'M';
elseif Daysbetween < 366 || Daysbetween > 251
    Unit = 5;
    units_of_anal = 'A';
elseif Daysbetween < 1 || Daysbetween > 366
    units_of_anal = 'U';
else Unit = 5;
end

%% 3 Convert price data to return data, adjust lengths of dates
Prices = Hdata(:,2);
Rets = Prices(2:end)./Prices(1:end-1)-1;
len_Rets = size(Rets);

%% 4 Sweep tails for quanitile information
sweep = 0:0.01:90; % zero to ninety percent returns
len_sweep = length(sweep);
for i = 1:len_sweep
    areaabove(i) = sum(Rets>=sweep(i))/len_Rets(1);
    areabelow(i) =sum(Rets<=-sweep(i))/len_Rets(1);
end
% plot(sweep,areaabove)
% plot(-sweep,areabelow)
Return_pos = sweep(sum(areaabove>=Threshold));
Return_neg = -sweep(sum(areabelow>=Threshold));
% Identify return that isolates threshold % of tail(s)
Cutoffs = [Return_pos Return_neg];

% Identify as logical Return cases where extremities are breached
id_breach_pos = Rets>=Return_pos;
id_breach_neg = Rets<=Return_neg;

%% 5 compute intervals with censoring (right hand side only)
[interval_out] = ptintervals(id_breach_pos, id_breach_neg); % complete intervals
len_interval_out = length(interval_out);
% find the positive and negative breaches
dummy1 = max(find(id_breach_pos==1));
dummy2 = max(find(id_breach_neg==1));
len_id_breach_pos = length(id_breach_pos);
% find the censored interval breaches
dummy3 = len_id_breach_pos - dummy1;
dummy4 = len_id_breach_pos - dummy2;
censored_interval = max(1,min(dummy3,dummy4));
% set up the intervals and censoring segment
Intervals = [interval_out ; censored_interval];
Censoring = [zeros(len_interval_out,1);1];

max_int = max(Intervals);

%% 6 Fit Weibull model to intervals with censoring
[parmhat, parmci] = wblfit(Intervals, 0.05, Censoring);

%% 7 Compute relevant measures
t = 0:0.1:max_int(1);
out.hazard = min(1,wblpdf(t,parmhat(1),parmhat(2)) ./ (1-wblcdf(t,parmhat(1),parmhat(2))));
% out.ci(:,1) = min(1,wblpdf(t,parmhat(1),parmci(1,2)) ./ (1-wblcdf(t,parmhat(1),parmci(2,1))));
% out.ci(:,2) = min(1,wblpdf(t,parmhat(1),parmci(2,2)) ./ (1-wblcdf(t,parmhat(2),parmci(2,2))));
% hazard = (parmhat(2).*t.^(parmhat(2)-1))/(parmhat(1)^(parmhat(2))); % check to ensure one gets the selfsame answer
out.hazard_current = (parmhat(2).*(censored_interval)^(parmhat(2)-1))/(parmhat(1)^(parmhat(2)));
out.mode_Weibull = min(0,parmhat(1)*((parmhat(2)-1)/parmhat(2))^(1/parmhat(2)));
out.mean_Weibull = parmhat(1)*gamma((1/parmhat(2))+1);
out.intervals = Intervals;
out.censoring = Censoring;
out.parmhat = parmhat;
out.parmci = parmci;
out.units = units_of_anal;
out.censored_interval = censored_interval;
out.cutoffs = Cutoffs;
out.t = t;
out.threshold = Threshold;

%% 8 Report to Screen if there is no functional output
if nargout<1,
    plot(out.t,out.hazard,'Color','r');
    title(sprintf('Weibull Hazard Parameterization at a threshold (%%) of: %2.3f',out.threshold));
    xlabel('Time from extreme event');
    ylabel('Instananeous probability of next event');
    labelx = sprintf('Hazard Rate = %2.3f with time since last extreme event being: %2.3f %s \n Current p(event)= %2.3f \n mean = %2.3f \n mode = %2.3f \n Upper/Lower Thresholds of return = %2.3f \n', ...
         parmhat(2),out.censored_interval,out.units,out.hazard_current,out.mean_Weibull,out.mode_Weibull,out.cutoffs(1));
    text((max_int/6),(max(out.hazard)/2),labelx);
 %   line(out.t,out.ci(:,1),'Color','r','LineStyle',':');
 %   line(out.t,out.ci(:,2),'Color','r','LineStyle',':');
end;    
%

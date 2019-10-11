function [dpdf,d] = broadening(d,w),
% BROADENING Guassian broadening of distribution
%
% [PDF,X] = BROADENING(D,W) Here D is the vector of 
% input data and W is the window size for the gaussian 
% broadening scheme about each point is D.
% 
% Given single timeseries this function pads each data point with 
% a gaussian density function and obtains the normalised pdf 
% of the timeseries using NANMEAN
%
% References: 

%  $Authors: Tim Gebbie, Diane Wilcox
%  $Revision: 1.1 $  $Date: 2008/07/01 14:51:18 $

% REVISION TO BROADENING2: delete the following line
% remove very small negative numbers
% d = epsclean(real(d(:)),1e3);

% find the number of data points in the time-series
n = length(d);
% sort into ascending order
d = sort(d);
% set the window size
a = round(w)/2;
% find the family of standard deviations
s = 0.5 * (d(2*a+1:end)-d(1:end-2*a)); 
% pad the set of timeseries to account for
% edge effects
dindex(1:a)     = 1; %  first a data points in timeseries
dindex(a+1:n-a) = 1:n-2*a;
dindex(n-a+1:n) = n-2*a; % last a data points in timeseries
% recalculate the required standard deviations
s = s(dindex);
% initialize pdf and
dpdf=0;
% initialize norm factor
normfactor=0;
% use gaussian broadening to create the family 
% of gaussians centered at each data point
for i=1:n
   b = normpdf(d(:)',d(i),s(i));
   if ~isnan(b),
       dpdf = dpdf + b;
       normfactor = normfactor+1;
   end;
end; 
% create a pdf that is normalized
if ~normfactor==0, dpdf = dpdf./normfactor; end;
% condition the output
dpdf = dpdf(:);


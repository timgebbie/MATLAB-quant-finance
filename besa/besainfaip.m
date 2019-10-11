function [aip,rp,bi] = besainfaip(settle_date,rytm,ratio,details,ytm0)
%BESAINFAIP All-in-price for Inflation linked BESA Gilts
%   [AIP] = BESAINFAIP(SETTLE,RYTM,RATIO,DETAILS) Find the allinprice 
%   for an inflation linked bond given the CPI ratio, RATIO, The valuation
%   and settlement dates, VALUE and SETTLE, the real yield to maturity RYTM.
%
%   [AIP] = BESAINFAIP(SETTLE,RYTM,RATIO,DETAILS,ECPI,CPI_ISSUE) Find 
%   the allinprice for an inflation linked bond given the CPI at issue, the 
%   CPI at valuation and the real yield to maturity. ECPI is the expected 
%   y/y CPI rate as an annualized percentage this is not necessary as an 
%   input unless one does not want to use the current CPI at valuation.
%
%   [AIP,RP,BI] = BESAINFAIP(SETTLE,RYTM,RATIO,CPI_ISSUE,DETAILS,YTM0) 
%   If the nearest current YTM0 at the current tenor of the relevent instrument
%   is provided. Then the break-even inflation rate is given as BI and 
%   the risk premium RP can be computed.
% 
%   AIP(t) = BESAAIP(RY(t)) * (CPI(t)/CPI(0))
%
%   1. I     : Expected Inflation 
%   2. Y     : Nominal yield at tenor (conventional yield off yield curve)
%   3. RYTM  : Real Yield (for inflation linked bond)
%   4. BI    : Break Even inflation rate
%                      (1+Y)
%               BI =  -------- - 1
%                     (1+RYTM)
%   5. RP   : Risk Premium
%                        (1+Y)     
%               RP =  ---------------  - 1
%                     (1+RYTM)*(1+I)) 
%
%   Example 1.:
%
%   See Also: BESAAIP

% Author: Tim Gebbie
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.5 $ $Date: 2006-03-28 15:43:13+02 $

% Get the all-in-price
aip_conv = besaaip(settle_date,rytm,details);
% correct the price for inflation
aip = aip_conv * ratio;

% compute the break-even inflation and risk premium if possible
if nargin==5,
    % find the difference between the issue and settle dates
    d = daysdif(details.issuedate,settle_date);
    % get the break even inflation rate 
    bi = ((1 + ytm0)/(1 + rytm))-1;
    % get the change in inflation index
    ir = ratio;
    % annualize the change in inflation index
    ir = (ir)^(360/d);
    % calculate the risk-premium
    rp = ((1+ytm0)/((1+rytm)*(ir)))-1;
else
    bi = NaN;
    rp = NaN;
end;


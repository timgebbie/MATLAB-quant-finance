function [price]=besaoption(spot,strike,expiry_date,vol,rate,value_date,t,details)
%BESAOPTION Use Black's model to price BESA option 
%   [PR] = BESAOPTION(SPOT,STRIKE,EXPIRY,VOL,RATE,VALUE,T,DETAILS) BESA Valuation of 
%   options on bonds. Uses Black's model in conjunction with the forward 
%   clean price for the bond; this compensate for pull-to-par. Assumes that 
%   the clean price of a bond is lognormally distributed. All PV's use 
%   compound interest.  The American options are dealt with using the 
%   "American Intrinsic Correction", i.e. the option is valued as if it were
%   european and the result adjusted if necessary so that it is not less than 
%   the option intrinsic value -- this tends to undervalue
%   at-or-near-the-money. 
%
%   Input:
%       CODE  : bond code
%       SPOT  : spot ytm of bond
%       STRIKE: strike ytm of option
%       EXPIRY: expiry date of option
%       VOL   : the clean price volatility
%       RATE  : current risk free rate (NOT CONTINUOUS)
%       VALUE : Valuation date
%       T : Difference between settlement and valuation
%       DETAIL: The bond details as a structure
%
%   Output:
%       PR = [EC EP IVC IVP AC AP]
%           EC    = European Call
%           EP    =  European Put 
%           IVC   = Intrinsic Value Call
%           IVP   = IntrinsicValue Put
%           AC    = American Call
%           AP    = American Put
%
%   Canonical examples:
%   [1] Value of option on its last day R153
%   besaoption(0.135,0.135,datenum('17-Feb-1998 16:00:00'),0.10,0.145, ...
%       datenum('17-Feb-1998 10:00:00'),3,details)
%
%   [2] Long option at the foward money R150
%   detail.code     = 'R150';
%   detail.coupon   = 0.12;
%   detail.maturity = datenum('28-Feb-2005');
%   detail.ldr1     = datenum('31-Jan-1991');
%   detail.ldr2     = datenum('31-Jul-1991');
%   detail.pay1     = datenum('28-Feb-1991');
%   detail.pay2     = datenum('31-Aug-1991');
%   detail.onebeforelast = datenum('31-Aug-2004');
%   besaoption(0.135,0.1371566,datenum('17-Feb-2000 16:00:00'),0.10,0.145, ...
%       datenum('17-Feb-1998 16:00:00'),3,detail)
%
%   [3] The Call hits intrinsic R157
%   besaoption(0.135,0.1500,datenum('5-Nov-1998 16:00:00'),0.09,0.145, ...
%        datenum('17-Feb-1998 16:00:00'),3,details)
%
%   Multiply by 10 000 for per R1M value.
%
%   See Also: BESAFWDPRC, EQVALUE, BESAAIP, SETTLEDATE

% Authors: Tim Gebbie, Grant Grobbelaar
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 14:57:43+02 $

% set the timing using SETTLEDATE
settle_strike = settledate(floor(expiry_date),t);
settle_date = settledate(floor(value_date),t); 
VP = abs(value_date - expiry_date) / 365;

% get the allin price at spot at settle
[AIP_S0,a1]=besaaip(settle_date,spot,details);
AIP_S0=round(1e5 * AIP_S0) * 1e-5; % rounded
% clean price at spot       
% CP_S0 = round(1e5 * a1(:,1)) * 1e-5; % rounded  
% get the allin price at strike at settle
[AIP_K,a2]=besaaip(settle_date,strike,details);
AIP_K = round(1e5 * AIP_K) * 1e-5; % rounded
% get the allin price at strike at expiry
[AIP_KS,a3]=besaaip(settle_strike,strike,details);
acc_intr=round(a3(:,2) * 1e5) * 1e-5; % rounded
% clean price at expiry settle
CP_KS = round(1e5 * a3(:,1)) * 1e-5;  % rounded
% find the equivalent continuously compounded rate
per  = (settle_strike-(settle_date))/365;
% find the zero percents
idxper = (per==0);
% if zero percentage use risk free rate
frate(idxper,1)=rate(idxper);    
% else compute the compounding    
frate(~idxper,1)=log(1+rate(~idxper).*per(~idxper))./per(~idxper);
% find the eqivalent discount values
EV1 = eqvalue(floor(value_date),settle_strike,frate);
EV2 = eqvalue(floor(value_date),settle_date,frate);
% find the forward clean price
FCP_S = besafwdprc(AIP_S0,settle_date,settle_strike,frate,details)-acc_intr;
% get the volatility 
sigma = vol .* sqrt(VP);     
% calculate the call price using blacks model  
d1 = (log(FCP_S ./ CP_KS) ./ sigma) + sigma./2;
d2 = d1 - sigma;
cp = FCP_S .* N(d1)- CP_KS .* N(d2);
% european future value call
ec_fvprc=cp;
ec_intr = max(AIP_S0-AIP_K,0) .* EV2;
% european future value put
ep_fvprc=cp+ CP_KS - FCP_S; % put-call parity
ep_intr = max(AIP_K-AIP_S0,0) .* EV2;      
% european call     
ec_pvprc= ec_fvprc .* EV1; % correct for interest rate
% european put     
ep_pvprc= ep_fvprc .* EV1;
% american call 
ac_pvprc = max(ec_pvprc,ec_intr);
% american put     
ap_pvprc = max(ep_pvprc,ep_intr);

% format option pricing output
price = [ec_pvprc(:), ep_pvprc(:), ec_intr(:), ep_intr(:), ac_pvprc(:), ap_pvprc(:)];   
 
% premium = price ./ 100;
 
%% HELPER FUNCTIONS
function nd=N(d)
% approximate the normal cdf could use normcdf(d) but the 
% BESA specification is used here!
z=abs(d);
% constants
a  = 0.2316419;
b_1= 0.31938153;
b_2=-0.356563782;
b_3= 1.781477937;
b_4=-1.821255978;
b_5= 1.330274429;
% culmulative normal
k = 1 ./ (1 + a * z);
correct = (b_1 * k + b_2*k.^2 + b_3 * k.^3 + b_4 * k.^4 + b_5 * k.^5);
NZ = 1 - (1/sqrt(2 * pi)) .* exp(-z(:).^2 ./ 2) .* correct(:);
% Preallocate
nd = zeros(size(NZ));
% loop over vector elements
for j=1:length(NZ),
    if d(j) > 0,
        nd(j) = NZ(j);
    elseif d(j)==0,
        nd(j) = 0.5;
    elseif d(j) < 0,
        nd(j) = 1 - NZ(j);
    else
        nd(j) = NaN;
    end;
end;
% condition the output
nd = nd(:);
   
  
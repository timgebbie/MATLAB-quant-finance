%% BESA OPTION PRICING FOR RISK MANAGEMENT TEST FILE
%
%    The test cases are taken from the following documenentation:
% 
%    1. Bond Pricing Formulae, BESA, Quant Financial Research 1997
%    2. Option Pricing for Risk Management, BESA Quant Financial Research 1998 
%    3. Buy/Sell Back(carries) and Forward Pricing, BESA, Quant Financial Research 1997 
%    4. Risk Management Methodology, BESA, Quant Financial Research 1997
% 

%% Set up the format
format long

%% [1] Value of option on its last day R153
%
% * R153
%
detail1.code     = 'R153';
detail1.coupon   =  0.13;
detail1.maturity = datenum('31-Aug-2010');
detail1.ldr1 = datenum('31-Jan-1991');
detail1.ldr2 = datenum('31-Jul-1991');
detail1.pay1 = datenum('28-Feb-1991');
detail1.pay2 = datenum('31-Aug-1991');
detail1.onebeforelast = datenum('28-Feb-2010');
% Output:
%  European Call        = 0.10118191629472
%  European Put         = 0.10118191629471  
%  Intrinsic Value Call = 0
%  Intrinsic Value Put  = 0
%  American Call        = 0.10118191629472
%  American Put         = 0.10118191629471
%
%  premium = price ./ 100
%
premium = besaoption(0.135,0.135,datenum('17-Feb-1998 16:00:00'), ...
    0.10,0.145,datenum('17-Feb-1998 10:00:00'),3,detail1)


%% [2] Long option at the foward money R150
%
% * R150 
%
detail2.code     = 'R150';
detail2.coupon   = 0.12;
detail2.maturity = datenum('28-Feb-2005');
detail2.ldr1     = datenum('31-Jan-1991');
detail2.ldr2     = datenum('31-Jul-1991');
detail2.pay1     = datenum('28-Feb-1991');
detail2.pay2     = datenum('31-Aug-1991');
detail2.onebeforelast = datenum('31-Aug-2004');
% Output:
%
%  European Call        = 4.09769694262107
%  European Put         = 4.09768645909906   
%  Intrinsic Value Call = 0.90846911765971
%  Intrinsic Value Put  = 0
%  American Call        = 4.09769694262107
%  American Put         = 4.09768645909906
%
%  premium = price ./ 100
%
premium = besaoption(0.135,0.1371566,datenum('17-Feb-2000 16:00:00'), ...
    0.10,0.145,datenum('17-Feb-1998 16:00:00'),3,detail2)  

%% [3] The Call hits intrinsic R157
%
% * R157
%
detail3.code     = 'R157';
detail3.coupon   = 0.135;
detail3.maturity = datenum('15-Sep-2015');
detail3.ldr1     = datenum('15-Feb-1991');
detail3.ldr2     = datenum('15-Aug-1991');
detail3.pay1     = datenum('15-Mar-1991');
detail3.pay2    = datenum('15-Sep-1991');
detail3.onebeforelast = datenum('15-Mar-2015'); 
% Output:
%
%  European Call        = 9.07575948404277
%  European Put         = 0.27659855572086   
%  Intrinsic Value Call = 9.19794779773544
%  Intrinsic Value Put  = 0 
%  American Call        = 9.19794779773544
%  American Put         = 0.27659855572086
%
%  premium = price ./ 100
%
premium = besaoption(0.135,0.1500,datenum('5-Nov-1998 16:00:00'), ...
    0.09,0.145,datenum('17-Feb-1998 16:00:00'),3,detail3)

%% Vectorized Bond Details for pricing examples
%
% * R150 
% * R157
% * R153
%
detail.code     = {'R153', 'R150','R157'};
detail.coupon   = [0.13; 0.12; 0.135];
detail.maturity = datenum({'31-Aug-2010';'28-Feb-2005';'15-Sep-2015'});
detail.ldr1     = datenum({'31-Jan-1991';'31-Jan-1991';'15-Feb-1991'});
detail.ldr2     = datenum({'31-Jul-1991';'31-Jul-1991';'15-Aug-1991'});
detail.pay1     = datenum({'28-Feb-1991';'28-Feb-1991';'15-Mar-1991'});
detail.pay2     = datenum({'31-Aug-1991';'31-Aug-1991';'15-Sep-1991'});
detail.onebeforelast = datenum({'28-Feb-2010';'31-Aug-2004';'15-Mar-2015'});
% Option Details
spots       = [0.135; 0.135; 0.135];
strikes     = [0.135; 0.1371566; 0.150];
expiries    = {'17-Feb-1998 16:00:00';'17-Feb-2000 16:00:00';'5-Nov-1998 16:00:00'};
vols        = [0.10;0.10;0.09];
rates       = [0.145;0.145;0.145];
value_dates = {'17-Feb-1998 10:00:00';'17-Feb-1998 16:00:00';'17-Feb-1998 16:00:00'};
ts          = [3;3;3];
% Compute 
premium = besaoption(spots,strikes,datenum(expiries), ...
    vols,rates,datenum(value_dates),ts,detail)
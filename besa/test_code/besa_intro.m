%% BESA CONVENTION FIXED INCOME PRICING FOR RISK MANAGEMENT 
%
% Authors: Tim Gebbie, Grant Grobbelaar
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
clear detail;
help besa

%% Bond Pricing Functionality
%
% See besa_gilts_test_001
help besaaip

%% R150 government bond
detail.code{1}     = 'R150';
detail.coupon(1)   = 0.12;
detail.maturity(1) = datenum('28-Feb-2005');
detail.ldr1(1)     = datenum('31-Jan-1991');
detail.ldr2(1)     = datenum('31-Jul-1991');
detail.pay1(1)     = datenum('28-Feb-1991');
detail.pay2(1)     = datenum('31-Aug-1991');
detail.onebeforelast(1) = datenum('31-Aug-2004');
% price at YTM of 0.1455 on '30-Jun-1999'
settle_date = datenum('30-Jun-1999');
value_date = datenum(valuedate(settle_date,3));
[aip, cp, cum] = besaaip(settle_date,0.1455,detail)
%      all-in price = R94.31%,         
%      cleanprice   = R90.30%,  
%      cum-interest = R4.01%
%
% Modifed Durations
md = besamoddur(settle_date,0.1455,detail)
% Convexity
conv = besaconv(settle_date,0.1455,detail)
% Tenor
tenor = besatenor(value_date,detail)

%% Bond Option Pricing Functionality
%
% See besa_options_test_002
help besaoption

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
premium = besaoption(0.135,0.135,datenum('17-Feb-1998 16:00:00'),0.10,0.145, ...
    datenum('17-Feb-1998 10:00:00'),3,detail1)

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
premium = besaoption(0.135,0.1371566,datenum('17-Feb-2000 16:00:00'),0.10,0.145, ...
    datenum('17-Feb-1998 16:00:00'),3,detail2)  

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
premium = besaoption(0.135,0.1500,datenum('5-Nov-1998 16:00:00'),0.09,0.145,...
    datenum('17-Feb-1998 16:00:00'),3,detail3)

%% Inflation Linked Bond Instrument Pricing
help besainfaip

%% R189 Inflation Linked Bond
% Price R189 for settlement on the 10-October-2005 with 
% a real yield of 2.7%
%
% AIP R124.04813% (at 2.7%)
% INF AIP R165.58012%
% Clean Price R165.35156% Acc Inte = R0.22856%
% Delta = -10.1930
% Modified Duration = 6.156
% Duration = 6.239
% Convexity = 45.347
%
% Reference CPI on Issue date    95.6838709677419
% Reference CPI on Settle date  127.71935483871
% ratio                           1.33480547501854
%
cpidetail.code      = 'R189';
cpidetail.maturity  = datenum('31-March-2013');
cpidetail.ldr1      = datenum('21-March-1999');
cpidetail.ldr2      = datenum('20-Sep-1999');
cpidetail.pay1      = datenum('31-Mar-1999');
cpidetail.pay2      = datenum('30-Sep-1999');
cpidetail.issuedate = datenum('20-Mar-2000'); 
cpidetail.onebeforelast = datenum('30-Sep-2012');
cpidetail.coupon    = 0.0625;
% CPI data  
cpi = [95.5; 95.8; 127.6; 127.4; 128.5];
cpi_dates = datenum({'30-Nov-1999';'31-Dec-1999';'31-May-2005';'30-Jun-2005';'31-Jul-2005'});
rytm = 0.027;
ytm0 = 0.08;
settle_date = datenum('10-Oct-2005');
value_date = datenum(valuedate(settle_date,3));
% Compute the ECPI ratio
[cpi_ratio,cpi_issue,cpi_settle]=cpiratio(settle_date,cpidetail.issuedate,cpi,cpi_dates)
% pricing example
aip = besaaip(settle_date,rytm,cpidetail)
infaip = besainfaip(settle_date,rytm,cpi_ratio,cpidetail)


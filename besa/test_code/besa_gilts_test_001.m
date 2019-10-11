%% BESA GILTS PRICING TEST FILE
%
%    The test cases are taken from the following documenentation:
% 
%    1. Bond Pricing Formulae, BESA, Quant Financial Research 1997
%    2. Option Pricing for Risk Management, BESA Quant Financial Research 1998 
%    3. Buy/Sell Back(carries) and Forward Pricing, BESA, Quant Financial Research 1997 
%    4. Risk Management Methodology, BESA, Quant Financial Research 1997
% 

clear detail

%% R150 
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

%% R157
detail.code{2,1}    = 'R157';
detail.coupon(2,1)   = 0.135;
detail.maturity(2,1) = datenum('15-Sep-2015');
detail.ldr1(2,1)     = datenum('15-Feb-1991');
detail.ldr2(2,1)     = datenum('15-Aug-1991');
detail.pay1(2,1)     = datenum('15-Mar-1991');
detail.pay2(2,1)    = datenum('15-Sep-1991');
detail.onebeforelast(2,1) = datenum('15-Mar-2015');
    
%% R153
detail.code{3}     = 'R153';
detail.coupon(3)   =  0.13;
detail.maturity(3) = datenum('31-Aug-2010');
detail.ldr1(3) = datenum('31-Jan-1991');
detail.ldr2(3) = datenum('31-Jul-1991');
detail.pay1(3) = datenum('28-Feb-1991');
detail.pay2(3) = datenum('31-Aug-1991');
detail.onebeforelast(3) = datenum('28-Feb-2010');

%% Vectorized All-in-price
%
% YTM's on 30-Jun-1999 for R150, R157 and R153
%    desc:  TOMONTHLY: Close_Price
%    freq:  Monthly (3)
%
%    'dates:  (1)'    'R150:  (1)'    'R153:  (1)'    'R157:  (1)'
%    '30-Jun-1999'    [   14.5500]    [   15.2000]    [   15.1800]
%
format long
ytm = [0.1455; 0.152; 0.1518];
settle_date = datenum('30-Jun-1999')*ones(size(ytm));
value_date = datenum(valuedate(settle_date,3));
% The allinprice
[aip, cp, cum] = besaaip(settle_date,ytm,detail)

%% Inflation Linked Bond
%
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
format short
[infaip, riskpremium, breakeven_inflation] = besainfaip(settle_date,rytm,cpi_ratio,cpidetail,ytm0)

%% Inflation Linked Bond with ECPI y/y forecast
% User supplies new ECPI (forecast) - use the input annualize inflation rate 
% to find cpi index where ECPI is the y/y CPI rate as an annualized percentage.
d = daysdif(cpidetail.issuedate,settle_date);
% 6% expected inflation
ecpi = 0.06;
cpi_value= ((1+ecpi)^(d/360))*cpi_issue;
cpi_ratio = cpi_value / cpi_issue;
infaip = besainfaip(settle_date,rytm,cpi_ratio,cpidetail)

function [aip, cp, cum] = besaaip(settle_date,ytm,details)
%BESAAIP(DATE,YTM,DETAILS) BESA All-in-price for Gilts
%   [AIP,CP,CUM] = BESAAIP(SETTLE,YTM,DETAILS) South African bond price for
%   six-month or longer maturities. The settlement date SETTLE is typically 
%   used. The current yield-to-maturity YTM are required with the structure 
%   specifying the bond details DETAILS. The valuation date is typically 
%   T-1 with respect to the settlement date. Cum interest if the settlement 
%   is more than a month before next interest payment, ex interest if it is 
%   a month or less before the next interest payment. Trade ex-interest for 
%   one month, with interest not accruing up to the coupon date. The return 
%   given is that to par.
%
%   AIP = All-in-price
%   CP  = [cleanprice interest flatyield returns]
%   CUM = [cum_flag Coupon Last_Payment_Date]
%   
%   Example 1: R150
%      Maturity  = '28-Feb-2005';
%      Valuation = '30-Jun-1999';
%      Lastpay   = '28-Feb-1999';
%      Nextpay   = '31-Aug-1999';
%      Coupon    = 0.12; 
%
%   detail.code     = 'R150';
%   detail.coupon   = 0.12;
%   detail.maturity = datenum('28-Feb-2005');
%   detail.ldr1     = datenum('31-Jan-1991');
%   detail.ldr2     = datenum('31-Jul-1991');
%   detail.pay1     = datenum('28-Feb-1991');
%   detail.pay2     = datenum('31-Aug-1991');
%   detail.onebeforelast = datenum('31-Aug-2004');
%   [aip,cp,cum] =  besaaip(datenum('30-Jun-1999'),0.1455,detail)
%
%   This is an all-in-price = R94.31%, a Clean price of R90.30% with  
%   cum interest as R4.01%. 
%
%   Note: Requires HOLIDAYS to provide the correct holidays for South Africa.
%
%   See Also: HOLIDAYS, BUSDATE, SETTLEDATE, VALUEDATE, BESAMODDUR, BESACONV

% (See: pg 101 The Interest Bearing Securities Market, Faure, Falkena, Kok & Raine)

% Author: Tim Gebbie
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.4 $ $Date: 2006-03-28 15:43:15+02 $

for j=1:length(ytm),
    % preset the data
    maturity = datestr(details.maturity(j));
    date1 = datestr(datenum(year(settle_date(j)),month(details.pay1(j)),day(details.pay1(j))));
    date2 = datestr(datenum(year(settle_date(j)),month(details.pay2(j)),day(details.pay2(j))));
    onebeforelast = datestr(datenum(details.onebeforelast(j)));
    close1 = datestr(datenum(year(settle_date(j)),month(details.ldr1(j)),day(details.ldr1(j))));
    close2 = datestr(datenum(year(settle_date(j)),month(details.ldr2(j)),day(details.ldr2(j))));
    settledatej = settle_date(j);
    % The details.coupon should be 0.12 as 12%
    C = 100 * details.coupon(j);
    % correct the scaling
    i = 100 * ytm(j);

    % ENSURE THE DATES ARE ORDERED : date1 < date2 , closes1 < date1
    if datenum(date2) < datenum(date1),
        %swap payment dates
        bufferdate = date1;
        date1 = date2;
        date2 = bufferdate;
        % swap closes dates
        bufferdate = close1;
        close1 = close2;
        close2 = bufferdate;
    end;

    % check that closes1 is in the correct year
    theyearchanged =1;
    if datenum(close1) > datenum(date1)
        close1 = datestr(datenum(year(date1) -1,month(close1),day(close1)));
        theyearchanged =0;
    end;

    % FIND THE NEXT INT DUE DATE
    % if valuation date is after redemption
    if datenum(settledatej) > datenum(maturity),
        error('valuation date after redemption.')
    end;

    % if valuation date is after the last coupon but before redemption
    if datenum(settledatej) > datenum(onebeforelast),
        nextpay = maturity;
    end;

    % otherwise
    if datenum(settledatej) < datenum(date1),
        nextpay = date1;
    elseif datenum(settledatej) == datenum(date1),
        nextpay = date2;
    elseif datenum(settledatej) < datenum(date2),
        nextpay = date2;
    elseif datenum(settledatej) >= datenum(date2),
        nextpay = datestr(datenum(year(settledatej)+1,month(date1),day(date1)));
    end;

    % FIND THE LAST INT DUE DATE
    % if valuation date is after redemption
    if datenum(settledatej) > datenum(maturity),
        error('valuation date after redemption.')
    end;
    % otherwise
    if datenum(settledatej) < datenum(date1),
        lastpay = datestr(datenum(year(settledatej)-1,month(date2),day(date2)));
    elseif datenum(settledatej) == datenum(date1),
        lastpay = date1;
    elseif datenum(settledatej) < datenum(date2),
        lastpay = date1;
    elseif datenum(settledatej) >= datenum(date2),
        lastpay = date2;
    end;
    % ensure that the format is correct
    lastpay = datestr(lastpay);
    nextpay = datestr(nextpay);
    % initialize cuminterest
    cuminterest = 2;
    % DETERMINE WHETHER OR NOT THE INTEREST IS CUM OR EX
    if datenum(settledatej)  >= datenum(onebeforelast),
        cuminterest = 1;
    end;
    % otherwise
    if datenum(settledatej) < datenum(close1),
        cuminterest = 1;
    elseif datenum(settledatej) < datenum(date1),
        cuminterest = 0;
    elseif datenum(settledatej) < datenum(close2),
        cuminterest = 1;
    elseif datenum(settledatej) < datenum(date2),
        cuminterest = 0;
    elseif datenum(settledatej) >= datenum(date2),
        if theyearchanged == 1
            if datenum(settledatej) < datenum(year(settledatej)+1,month(close1),day(close1)),
                cuminterest =1;
            end;
        else
            if datenum(settledatej) < datenum(year(settledatej),month(close1),day(close1)),
            else
                % exclude this to capture errors
                cuminterest =0;
            end;
        end;
    end;

    % ------------------------------------------------------------------------
    % FIND THE ALLIN PRICE
    % ------------------------------------------------------------------------
    J = daysdif(lastpay,nextpay);
    F = months(nextpay,maturity)/6;
    E = daysdif(settledatej,nextpay);
    G = F+(E./J);

    if cuminterest == 1,
        % cum-interest price : the buyer gets the next coupon, the seller is 
        % compensated for lost interest. (sold with interest)
        % ALLINPRICE ------------------------------------------------------
        aip(j,1) = 100*(1 + (i/200))^(-G) + 100*(C/i).*(1+(i/200))^(-G)*((1+(i/200))^(F+1) -1 );
        % -----------------------------------------------------------------
        % cum interest
        interest(j,1) = ((J-E)/365)*C;
        % cleanprice is the cum-interest price less the cum-interest
        cleanprc(j,1) = aip(j) -(interest(j));
    elseif cuminterest == 0
        % ex-interest price : within a month before close, the seller keeps 
        % the next coupon, the buyer is compensated for the lost interest. 
        % (sold without interest)
        % ALLINPRICE ------------------------------------------------------
        aip(j,1) = 100*(1 + (i/200))^(-G) + 100*(C/i)*(1+(i/200))^(-G)*((1+(i/200))^(F) -1 );
        % -----------------------------------------------------------------
        % ex interest
        interest(j,1) = -(E/365)*C;
        % cleanprice is the ex-interest price plus the lost ex-interest
        cleanprc(j,1) = aip(j) - (interest(j));
    end
    % flat-yield or running yield
    flatyield(j,1) = 100*C./cleanprc(j);
    % return to par
    returns(j,1) = aip(j) - 100;
    cp(j,:) = [cleanprc(j) interest(j) flatyield(j) returns(j)];
    cum(j,:) = [cuminterest details.coupon(j) datenum(lastpay)];
end; % loop over j
%
% LCD -------- S ---- BCD ------ NCD => cum price - (S-LCD)
%
% LCD ------ BCD ---- S -------- NCD => ex price  + (S-NCD)
%

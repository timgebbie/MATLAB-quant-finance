function [fp,t]=besafwdprc(aip,settle,expiry,r,details)
%BESAFWDPRC Forward price on South African BESA Bonds 
%   [FP,T] = BESAFWDPRC(AIP,D1,D2,R,DETAILS) Find the forward price of a 
%   bond. The first date is, SETTLE, the settlement date, and the second 
%   date, EXPIRY, is the contract expiry date. R is assumed to be the 
%   continuously compounded equivalent rate. C is the coupon rate. The 
%   details of the bond is DETAILS.
%
%   See Also: EQVALUE, 

% Authors: Tim Gebbie, Grant Grobbelaar
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management
%                and OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.2 $ $Date: 2006-03-28 12:51:08+02 $

for k=1:length(aip),
    % bond details
    pay1 = details.pay1(k);
    pay2 = details.pay2(k);
    ldr1 = details.ldr1(k);
    ldr2 = details.ldr2(k);
    c = details.coupon(k);
    % dates
    d1=settle(k);
    d2=expiry(k);
    % find the forward price for a bond
    d=daysdif(d1,d2);
%     a=round(d/182);
%     AIntr=0;
    % get the payment dates
    pay_coupon = true;   
    I=0; 
    j=0;
    while pay_coupon,
        dt1=datenum(year(d1)+j,month(pay1),day(pay1));
        cl1=datenum(year(d1)+j,month(ldr1),day(ldr1));
        dt2=datenum(year(d1)+j,month(pay2),day(pay2));
        cl2=datenum(year(d1)+j,month(ldr2),day(ldr2));
%         pvc1=0;
%         pvc2=0;
        if cl1>=d1 && cl1<d2, 
            I = I + 100 * (c / 2) * eqvalue(d2,dt1,r(k));
        end;
        if cl2>=d1 && cl2<d2,
            I = I + 100 * (c / 2) * eqvalue(d2,dt2,r(k));
        end;         
        if year(dt2) <= year(d2),
            j=j+1;
        else
            pay_coupon=false;
        end;
    end; % end while coupon
        % FORWARD PRICE
        % -------------------------------------------
        fp(k,1) = aip(k) * eqvalue(d2,d1,r(k)) - I;
        t(k,1)  = d/365;
        % -------------------------------------------
end; % loop k
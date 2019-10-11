function  [cv] = besaconv(settle_date,ytm,details)
%BESACONV Convexity of BESA listed Gilt
%   CV = BESACONV(SETTLE,YTM,DETAILS) The bond convexity C is 
%   computed given the valuation date, VALUE, the settelement date, SETTLE,
%   the yield-to-maturity YTM and the instrument details DETAILS.
%
%   Convexity if approximated from the All-in-price P as:
%
%              P(i+0.0001) - P(i-0.0001) - 2 * P(i) 
%   CV =  ----------------------------------------------
%                      P(i) * (0.0001)^2
%
%   See Also: BESAMODDUR, BESATENOR

% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.4 $ $Date: 2006-03-28 15:43:14+02 $

% Compute the prices 
MinusPrice = besaaip(settle_date,ytm-0.0001,details);
PlusPrice  = besaaip(settle_date,ytm + 0.0001,details);
Price = besaaip(settle_date,ytm,details);

% compute the approximate convexity
cv = (PlusPrice + MinusPrice - 2 * Price) ./ ( Price * 0.0001 * 0.0001);

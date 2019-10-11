function [md] = besamoddur(settle_date,ytm,details)
%BESACONV Modified duration of BESA listed Gilt
%   MD = BESAMODDUR(SETTLE,YTM,DETAILS) The bond modified duration MD
%   is computed given the valuation date, VALUE, the settlement date,
%   SETTLE, the yield-to-maturity YTM and the instrument details DETAILS.
%
%   Modified duration if approximated from the All-in-price P as:
%
%           P(i-0.0001) - P(i+0.0001)
%   MD =  ------------------------------
%                 P(i) * 2 * (0.0001) 
%
%   See Also: BESACONV, BESATENOR, BESAAIP

% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.4 $ $Date: 2006-03-28 15:43:13+02 $

MinusPrice = besaaip(settle_date, ytm - 0.0001, details);
PlusPrice = besaaip(settle_date, ytm + 0.0001, details);
Price =  besaaip(settle_date, ytm, details);

md =  ((MinusPrice - PlusPrice) ./ (Price * 2 * 0.0001));
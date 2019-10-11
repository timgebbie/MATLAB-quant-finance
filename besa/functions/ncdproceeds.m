function pv=ncdproceeds(daysdiff,ytm,mv)
%NCDPROCEEDS Proceeds of NCD (Negotiable Cash Deposit)
%   PV = NCDPROCEEDS(DAYSDIFF,YTM,MV) Given a Maturity Value MV and the 
%   difference in days between the valuation date and the maturity date
%   given the market quote yield-to-maturity YTM the proceeds are given 
%   as PV.
%
%   See Also: NCDMVALUE, BESAAIP

% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 15:43:10+02 $

pv = mv / (1 + (daysdiff/365) * ( ytm /100 ));
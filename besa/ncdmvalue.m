function mv = ncdmvalue(days1,ytm,nominal)
%NCDMVALUE Maturity value of NCD (Negotiable Cash Deposit) 
%   MV = NCDMVALUE(DAYS,YTM) Given the number days DAYS and the
%   yield-to-maturity YTM the Maturity Value of the NCD is given as MV.
%
%   See Also: EQVALUE, BESAAIP

% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 15:43:11+02 $

mv = nominal * ( 1 + (days1/365) * (ytm / 100) );
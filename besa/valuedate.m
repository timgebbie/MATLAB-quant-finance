function vd = valuedate(sd,t)
%VALUEDATE Find the valuation date from the settlement date
%   VD = VALUEDATE(SD,T) Find the settlement date as 
%   T working days after the tradedate. 
%
%   Example 1:
%   valuedate(today,3)
%
%   See Also: SETTLEDATE, BESAAIP, HOLIDAYS, WEEKDAYS

% Author: Tim Gebbie
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 15:43:10+02 $

% initialize the valuation date
vd = sd;
% initialize the delay
if isempty(t), t=3; end;
% find the valuation date
for i=1:t, vd = busdate(vd,-1); end;
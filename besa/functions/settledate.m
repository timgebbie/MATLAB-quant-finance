function sd = settledate(td,t)
%SETTLEDATE Find the settlement date from the valuation date
%   SD = SETTLEDATE(TD,T) Find the settlement date as T working days after
%   the tradedate. 
%
%   Example 1:
%   settledate(today,3)
%
%   See Also: VALUEDATE, BESAAIP, HOLIDAYS, WEEKDAYS

% Authors: Tim Gebbie, Grant Grobbelaar
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 13:20:50+02 $

% The default is T+3
if isempty(t)
    t = 3*ones(size(td));
end
% Expand t if there are many trade dates and only one t
if length(t) == 1
    t = t * ones(size(td));
end
for k=1:length(td),
    % Initialize the date vectors (just for safety sake, get 17 more days
    % than the maximum T)
    bdvec = busdays(td(k),td(k) + 17+max(t(:)));
    % Ensure that the input date is a trade date and find the settlement date
    if (bdvec(1)==td(k)) && ~isempty(find(bdvec==round(td(k)))),
        sd(k,1) = bdvec(1+t(k)); % t working days after the trade
    else
        error('Input date is not a Trade date')
    end;
end;
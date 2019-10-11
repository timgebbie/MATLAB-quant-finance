function [refd1,refd2,t,D] = cpirefdates(date)
%CPIREFDATES Get reference dates for the computation of the CPI ratio
%   [REF1,REF2,T,D] = CPIREFDATES(DATE)
%
%   See Also: CPIRATIO, BESAINFAIP

% Author: Tim Gebbie
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 15:43:12+02 $

% get the issuedate data date
if month(date)<=3, 
    dyr = -1; 
    dm = 12; 
else
    dyr=0; 
    dm=0; 
end;
refd2  = datenum(year(date)+dyr,month(date)-3+dm,1); % 3 month prior
if month(date)<=4, 
    dyr = -1; 
    dm = 12; 
else
    dyr=0; 
    dm=0; 
end;
refd1  = datenum(year(date)+dyr,month(date)-4+dm,1); % 4 month prior
refd2  = datenum(year(refd2),month(refd2),eomday(year(refd2),month(refd2))); % get the end of month
refd1  = datenum(year(refd1),month(refd1),eomday(year(refd1),month(refd1))); % get the end of month
t = day(date); % day of date
D = eomday(year(date),month(date)); % length of days in month of date
function [ratio,cpi_issue,cpi_settle,d] = cpiratio(settle_date,issue_date,cpi,cpi_dates)
%CPIRATIO Get the CPI ratio for price re-scaling
%   [RATIO,CPI_ISSUE,CPI_SETTLE,D] = CPIRATIO(SETTLE,ISSUE,CPI) The 
%   settlement date, SETTLE, and issuedate ISSUE are used to compute the 
%   CPI ratio. The CPI data as a FINTS object.
%
%   [RATIO,CPI_ISSUE,CPI_SETTLE,D] = CPIRATIO(SETTLE,ISSUE,CPI,CPI_DATES)
%   The settlement date, SETTLE, and issuedate ISSUE are used to compute
%   the CPI ratio. The CPI data vector and the associated CPI dates.
%
%   See Also: CPIREFDATES, BESAINFAIP

% Author: Tim Gebbie
% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 15:43:12+02 $

% get the issue date data
[issued1,issued2,ti,Di]=cpirefdates(issue_date);
% get the value date data
[settled1,settled2,ts,Ds]=cpirefdates(settle_date);
% get the cpi values on the relevant dates
cpi_issue_d1 = cpi(find(cpi_dates==issued1));
cpi_issue_d2 = cpi(find(cpi_dates==issued2));
cpi_settle_d1 = cpi(find(cpi_dates==settled1));
cpi_settle_d2 = cpi(find(cpi_dates==settled2));
% Get the day and month length for value date
cpi_issue = cpi_issue_d1 + ((ti-1)/Di) * (cpi_issue_d2 - cpi_issue_d1);
% Get the day and month length for the issue date
cpi_settle = cpi_settle_d1 + ((ts-1)/Ds) * (cpi_settle_d2 - cpi_settle_d1);
% find the cpi ratio
ratio = cpi_settle / cpi_issue;
% days between the issue and valuedates
d = daysdif(issue_date,settle_date);
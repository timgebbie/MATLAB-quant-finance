function [tenor] = besatenor(thedate,details)
%BESATENOR Tenor of a given SA bond on the date given
%
%   T = BESATENOR(DATE,DETAILS)


% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 15:43:13+02 $

tenor = yearfrac(thedate,details.maturity);
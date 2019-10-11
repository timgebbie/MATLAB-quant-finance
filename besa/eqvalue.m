function ev=eqvalue(d1,d2,c)
%EQVALUE Equivalent Value of Cash Flow
%   EV = EQVALUE(DATE1,DATE2,R) Find the eqivalent values using the 
%   continously compound rate R between DATE1 and DATE2.
%
% See Also: 

% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 15:43:12+02 $

d=daysdif(d2,d1);
ev = exp(c.*(d./365));
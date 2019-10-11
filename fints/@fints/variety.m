function ftsa = variety(ftsa)
%@FINTS/VARIETY returns the cross-sectional standard deviation.
% 
%   TSVAR = VARIETY(FTS) will return the variety of all the data of 
%   all of the series in the object FTS and return it in TSVAR.  
%
%   See also PERAVG, TSMOVAVG.

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

ftsa.data{4}(isnan(ftsa.data{4})) = 0;
ftsa.data{4} = transpose(std(transpose(ftsa.data{4})));
ftsa.data{1} = {'VARIETY'};
ftsa.names   = [ftsa.names(1:3) {'VARIETY'} ftsa.names(end)];
% [EOF]

function fts = zero2nan(fts)
% @FINTS/ZERO2NAN Zero's to NaN's
%
% See Also: FINTS, DATA, INF2NAN

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

% find the data that is + or - Inf
index=(abs(fts.data{4})==0);
% set this data to NaN
fts.data{4}(index) = NaN;
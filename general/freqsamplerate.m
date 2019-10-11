function freq = freqsamplerate(freq),
% FREQ Convert a frequency index number or string to sampling rate in days
%
%  +--------+--------+----------------+----------------+
%  | STRING | NUMBER | DESCRIPTION    | RESAMPLE RATE  |
%  +--------+--------+----------------+----------------+
%  | Null   |  0     | Unknown        |     NaN        |
%  | 'X'    |  1     | Working Daily  |     260        |
%  | 'D'    |  1     | Calendar Daily |     365        | 
%  | 'W'    |  2     | Weekly         |     52         |
%  | 'M'    |  3     | Monthly        |     12         |
%  | 'Q'    |  4     | Quarterly      |     4          |
%  | 'S'    |  5     | Semiannual     |     2          |
%  | 'A'    |  6     | Annual         |     1          |
%  +--------+--------+----------------+----------------+
%
% See Also: FREQNUM, FREQSTR

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

% convert to a string if it is not a string
if ~isstr(freq); freq = freqstr(freq); end;

switch freq
    case {'','Unknown'},
        freq = NaN,
    case {'X','Working Days'},
        freq = 260;
    case {'D','Daily','Calendar Days'},
        freq = 365.25;
    case {'W','Weekly'},
        freq = 52;
    case {'M','Monthly'},
        freq = 12;
    case {'Q','Quarterly'},
        freq = 4;
    case {'S','Semiannual'},
        freq = 2;
    case {'A','Annual'},
        freq = 1;
    otherwise
        error('Unrecognized Frequency');
end;
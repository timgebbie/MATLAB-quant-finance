function fts = filtfilt(b, a, ftsa)
%@FINTS/FILTFILT filters FINTS object components.
% 
% Y = FILTFILT(B, A, X) filters the data in vector X with the filter described
% by vectors A and B to create the filtered data Y.  The filter is described
% by the difference equation A y = B x.
%
% After filtering in the forward direction, the filtered sequence is then
% reversed and run back through the filter; Y is the time reverse of the
% output of the second filtering operation.  The result has precisely zero
% phase distortion and magnitude modified by the square of the filter's
% magnitude response.  Care is taken to minimize startup and ending
% transients by matching initial conditions.
%
% The length of the input x must be more than three times
% the filter order, defined as max(length(b)-1,length(a)-1).
% 
% Example: MA(12) lag-less filter
%    a = 12; b = ones(1,12);
%    ma12 = filtfilt(b,a,X);
%
% Note : that FILTFILT should not be used with differentiator and Hilbert FIR
% filters, since the operation of these filters depends heavily on their
% phase response.
% 
% Also See : FINTS/FILTER, FILTFILT

% Author: Tim Gebbie 31-09-2004 : Overload the FILTFILT function onto FINTS
% objects see the SIGNAL toolbox for futher extensions. 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

% If the object is of an older version, convert it.
if fintsver(ftsa) == 1
    ftsa = ftsold2new(ftsa); % This sorts the fts too.
elseif ~issorted(ftsa)
    ftsa = sortfts(ftsa);
end

fts = ftsa;

fts.data{1} = ['FILTFILTed ', ftsa.data{1}];

fts.data{4} = filtfilt(b, a, ftsa.data{4});

% [EOF]

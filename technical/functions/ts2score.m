function [s] = ts2score(varargin)
% TS2SCORE Comute a score for a price path using a given indicator
%
% [S] = TS2SCORE(P,I) Computes the score S based on technical indicators
%   relative to price. P is the price matrix of M stocks and N increments.
%   I is the indicator time-series of the same size as P. When the
%   indicator I crosses the price path P from belwo this is a "Bull" 
%   indicator. When the indicator I crosses the price path P from above 
%   this is a "Bear" indicator. The score ranges from -2 to +2. Buy is 2,
%   Hold is 1, Unchanged is -1 and Sell is -2. "Bear" signal is -2 and the
%   "Bull" signal is +2. 
%
% Example 1: 
%
% Example 2:

% Authors: Tim Gebbie

% $Revision: 1.3 $ $Date: 2008/10/03 09:00:19 $ $Author: Tim Gebbie $

switch nargin
    case
    otherwise
end

end


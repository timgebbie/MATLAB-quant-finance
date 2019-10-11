function [fts,RetInt] = oldtick2ret(varargin)
%TICK2RET Convert a price series to a return series.
%
% FTS = TICK2RET(FTS,METHOD)
%
%   Method - Character string indicating the method to compute asset returns. 
%     If Method is 'Simple', then simple periodic returns are computed. If 
%     Method is 'Continuous', then continuously compounded returns are 
%     computed. A case insensitive check is made of Method. The default is 
%     'Simple'.
%
% Outputs:
%   RetSeries - NUMOBS-1 by NASSETS time series array of asset returns 
%     associated with the prices in TickSeries. The i'th return is quoted for 
%     the period TickTimes(i) to TickTimes(i+1) and is not normalized by the
%     time increment between successive price observations. If Method is 
%     unspecified or 'Simple', then returns are as follows:
%
%     RetSeries(i) = TickSeries(i+1)/TickSeries(i) - 1
%
%     If Method is 'Continuous', then continuous returns are as follows:
%
%     RetSeries(i) = log[TickSeries(i+1)/TickSeries(i)]
%
%   RetIntervals - NUMOBS-1 element column vector of interval times between
%     price observations: RetIntervals(i) = TickTimes(i+1) - TickTimes(i). If 
%     TickTimes is empty or unspecified, all intervals are assumed to be 1.
%
% Requires Financial Toolbox Version 2.4.2
%
% See also RET2TICK.

% Author: Tim Gebbie : Overload the RET2TICK function from Financial 
% Toolbox version  2.4.2

% $Revision: 1.2 $ $Date: 2009/04/06 10:38:27 $ $Author: Tim Gebbie $

switch nargin
    case 1
        fts = varargin{1};
        Method = 'Continuous';
    case 2
        fts = varargin{1};
        Method = varargin{2};
    otherwise
        error('Incorrect Input Arguments');
end

% compute the returns
[fts.data{4}(2:end,:),RetInt] = tick2ret(fts.data{4},fts.data{3},Method);
% re-set the initial data point
fts.data{4}(1,:) = NaN;
% re-set the description
fts.data{1} = sprintf('%s RETURNS:%s',Method,char(fts.data{1}));


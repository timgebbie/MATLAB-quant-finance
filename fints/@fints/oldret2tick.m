function [fts,RetInt] = oldret2tick(varargin)
%TICK2RET Convert a price series to a return series.
%
%RET2TICK Convert a return series to a price series.
%   Compute price values from the starting prices of NASSET assets and NUMOBS
%   return observations.
%
%   [TickSeries, TickTimes] = ret2tick(RetSeries)
%   [TickSeries, TickTimes] = ret2tick(RetSeries, StartPrice, Method)
%
%   Optional Inputs: StartPrice, RetIntervals, StartTime, Method
%
% Inputs: 
%   RetSeries - NUMOBS by NASSETS time series array of asset returns 
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
% Optional Inputs:
%   StartPrice - NASSETS element row vector of initial prices for each asset, 
%     or a single scalar initial price applied to all assets. If StartPrice
%     is unspecified or empty, the initial price of all assets is 1.
%
%   Method - Character string indicating the method to convert asset returns 
%     to prices. If Method is 'Simple', then simple periodic returns are 
%     used. If Method is 'Continuous', then continuously compounded returns
%     are used. A case insensitive check is made of Method. The default is 
%     'Simple'.
%
% Outputs:
%   TickSeries - NUMOBS+1 by NASSETS time series array of asset prices. The 
%     first row contains the oldest observations and the last row the most
%     recent. Observations across a given row are assumed to occur at the 
%     same time for all columns, and each column is a price series of an 
%     individual asset. If Method is unspecified or 'Simple', then prices are
%     as follows:
%
%     TickSeries(i+1) = TickSeries(i)*[1 + RetSeries(i)]
%
%     If Method is 'Continuous', then prices are as follows:
%
%     TickSeries(i+1) = TickSeries(i)*exp[RetSeries(i)]
%
%   TickTimes - NUMOBS+1 element column vector of monotonically increasing
%     observation times associated with the prices in TickSeries. The initial
%     time is zero unless specified in StartTime, and sequential observation
%     times occur at unit increments unless specified in RetIntervals.
%
% Requires Financial Toolbox Version 2.4.2
%
% See also TICK2RET

% Author: Tim Gebbie : Overload the RET2TICK function from Financial 
% Toolbox version  2.4.2

% $Revision: 1.2 $ $Date: 2009/04/06 10:38:27 $ $Author: Tim Gebbie $

switch nargin
    case 1
        fts = varargin{1};
        Method = 'Continuous';
        StartPrice = 1;
    case 2
        fts = varargin{1};
        StartPrice = varargin{2};
        Method = 'Continuous';
    case 3
        fts = varargin{1};
        StartPrice = varargin{2};
        Method = varargin{3};
    otherwise
        error('Incorrect Input Arguments');
end

% compute the returns
[fts.data{4},fts.data{3}] = ret2tick(fts.data{4}(2:end,:),StartPrice,diff(fts.data{3}),fts.data{3}(1),Method);
% re-set the description
fts.data{1} = sprintf('%s TICK:%s',Method,fts.data{1});


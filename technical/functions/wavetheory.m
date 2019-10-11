function [hatf]=wavetheory(varargin)
% TECHNICAL/WAVETHEORY Apply wave theory to forecast mean-reversion
%
% [HATF] = WAVETHEORY(F,T,NT) Provides a 1-step ahead forecast based on
%   fitting data to plane-wave of period T with data window size NT. F is a
%   matrix of price data with the rows the date-time and the columns the
%   tickers. The PDE for a propagating wave is discretized and turned into
%   difference equations which is implemented using and ARMA model. The
%   initial conditions are the average price over the first half of the data
%   in the rolling window nT.
%
% [HATF] = WAVETHEORY(F,T,NT,FLAG) FLAG is by default TRUE to use P0 as the
%   average across the data window of size NT. FLAT equals FALSE set P0 to
%   the first data point in the window of size NT.
%
% The Model:
%
%   1. P(N+1) = (2 - \omega)^2 P(N) - P(N-1) + \omega^2 P(0)   
%      for \omega = 2 PI/T
%
% The initial conditions: 
%
%   2. P(0) = 1/N Sum_t=0^N P(t) 
% 
% Example 1:
%
% See Also: KALMANF1, FILTER

% Author : Tim Gebbie, Raphael Nkomo

% required input
f0 = varargin{1};
T = varargin{2};
nT = varargin{3};
switch nargin
    case 3
        flag = true;
    case 4
        flag = varargin{4};
    otherwise
        error('Incorrect Input Arguments');
end

% damping frequency
omega = (2 * pi/T);
% ARMA coefficients
a = 1;
% Manage P0
if flag,
    % P0 is the average over the window
    b(1:nT) = (1/nT)*(omega)^2;
else
    % P0 is the first data point in the window
    b = zeros(1,nT);
    b(nT) = (omega)^2;
end
% add on the average value contribution if required
b(1) = (2-omega)^2 + b(1);
% add on the average value contribution if required
b(2) = -1 + b(2);
% run the filter
hatf = filter(b,a,f0);


function [f,b,a] = gaussfilt(varargin)
%GAUSSFILT Gaussian Filter
%
% [G] = GAUSSFILT(PRICE,PERIOD,N) PRICE is a MxN price matrix (High + Low)/2 
%   of M ticks and N stocks. This is a multiple exponential moving average.
%   PERIOD is the even number of longest period required. This runs from 1 
%   to 40. The algorithm uses a lookup table. N is the order of the
%   Gaussian filter (the even number of poles).
%
% Example:
%      >> p = cumsum(randn(50,5)* 0.10);
%      >> [m,f] = gaussfilt(p);
%
% See Also: 

% Author: Tim Gebbie 2008 QT Capital Management 

% $Revision: 1.2 $ $Date: 2008/09/30 15:08:40 $ $Author: Tim Gebbie $

%% Input data
switch nargin
    case 1
        price = varargin{1};
        period = 4;
        n =  3;
        
    case 3
        price = varargin{1};
        period = varargin{2}
        n = varargin{3};
        
    otherwise
        error('Incorrect Input Arguments');
end

%% Compute the EWM co-efficients
omega = 2 * pi / period;
beta  = (1-cos(omega)) / (sqrt(2)^(2/n) - 1);
alpha = - beta+ sqrt(beta^2 + 2* beta);
b(1) = alpha^n;
a(1) = 1; 
% n-th order co-efficient for the k-th delay
for k=1:n,
    a(k+1)=nchoosek(n,k) * (1-alpha)^(k) * (-1)^k;
end

%% Apply the filter
f = filter(b,a,price);

%% Plot filtered data
if nargout==0
    for i=1:size(price,2)
        figure;
        plot([price(:,i) f(:,i)]);
        title('Guassian Filter');
        legend('Price','Guassian');
    end
end



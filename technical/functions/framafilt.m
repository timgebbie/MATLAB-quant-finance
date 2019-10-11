function [frama ] = framafilt(varargin)
%FRAMAFILT FRactal Adaptive Moving Average
%
% [FRAMA] = FRAMAFILT(PRICE,N) The fractal dimension D is computed using 
%   the price range. ALPHA the forgetting factor in the exponential weight 
%   moving average (EWMA) is then computed from the fractal dimension as 
%   ALPHA = EXP(-4.6 * (D-1)). N is the length of the window size to be
%   used, by default this is 16.
%
% Example:
%      >> p = cumsum(randn(50,5)* 0.10);
%      >> [f] = framafilt(p);
%
% See Also: 

% Author: Tim Gebbie 2008 QT Capital Management 

% $Revision: 1.1 $ $Date: 2008/09/26 14:13:30 $ $Author: Tim Gebbie $

%% input arguments
switch nargin
    case 1
        price = varargin{1};
        n = 16;
    case 2
        price = varargin{1};
        n = varargin{2};
    otherwise
        error('Incorrect Input Arguments');
end

%% initialise
frama = price;

%% Compute filter
for t=n:size(price,1)
    % compute the rescaled ranges
    n3 = range(price) ./ n;
    n1 = range(price(1:round(n/2),:)) ./ round(n/2);
    n2 = range(price(round(n/2):end,:)) ./ round(n/2);
    % compute the fractal dimension
    D(t,:) = (log(n1+n2)-log(n3))./log(2);
    % update alpha using the estimated fractal dimension
    alpha(t,:) = exp(-4.6 * (D(t,:)-1));
    % upper and lower bounds on alpha
    alpha(t,alpha(t,:)<0.01)=0.01;
    alpha(t,alpha(t,:)>1)=1;
    % increment the filter
    frama(t,:) = alpha(t,:) .* price(t,:) + (1-alpha(t-1,:)) .* frama(t-1,:);
end

%% Plot the filter
if nargout==0
    for i=1:size(price,2)
        figure;
        plot([price(:,i) frama(:,i)]);
        title('FRAMA Filter');
        legend('Price','FRAMA');
    end
end

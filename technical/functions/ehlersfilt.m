function [f,b,a] = ehlersfilt(varargin)
%EHLERSFILT Gaussian Filter
%
% [G] = EHLERSFILT(PRICE,STATISTIC,N) PRICE is a MxN price matrix (High + Low)/2 
%   of M ticks and N stocks. This is a FIR filter based on the use of 
%   order statistics (OS) developed by J. Ehlers.
%
% Example:
%      >> p = cumsum(randn(50,5)* 0.10);
%      >> s = filter(1,[1 0 0 0 -1],price); % lag 5 momentum
%      >> [f] = ehlersfilt(p,s,5);
%
% See Also: 

% Author: Tim Gebbie 2008 QT Capital Management 

% $Revision: 1.2 $ $Date: 2008/10/03 08:59:32 $ $Author: Tim Gebbie $

%% Input data
switch nargin
    case 1
        price = varargin{1};
        s = [zeros(5,size(price,2)); abs(diff(price,5))]; % lag 5 momentum
        n = 15;
        
    case 3
        price = varargin{1};
        s = varargin{2};
        n = varargin{3};
        
    otherwise
        error('Incorrect Input Arguments');
end

%% Initialise
f = price;

%% Apply the filter
b = sum(s(1:n,:));
for i=n:size(price,1)
    f(i,:) = (1./ b) .* transpose(diag(s(i-n+1:i,:)' * price(i-n+1:i,:))); 
    b = sum(s(i-n+1:n,:));
end

%% Plot filtered data
if nargout==0
    for i=1:size(price,2)
        figure;
        plot([price(:,i) f(:,i)]);
        title('Ehlers Filter');
        legend('Price','Ehlers');
    end
end



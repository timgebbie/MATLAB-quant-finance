function [mama fama] = mamafilt(varargin)
%MAMAFILT MESA Adaptive Moving Averages
%
% [MAMA FAMA] = MAMAFILT(PRICE,FAST,SLOW) PRICE is a MxN price matrix 
%   (High + Low)/2 of M ticks and N stocks. FAST is the fast limit and 
%   SLOW the slow limit. The filter value is allowed to vary between these 
%   limits. The default values are FAST = 0.5 and SLOW = 0.05. The MESA 
%   adaptive moving average adapts price movement based on the rate of 
%   change of phase as measured by the Hilbert transformation. This is a 
%   non-linear filter. The output is the MAMA filtered data and the FAMA 
%   (Following Adaptive Moving Average) filtered data.
%
% Example:
%      >> p = cumsum(randn(50,5)* 0.10);
%      >> [m,f] = mamafilt(p);
%
% See Also: 

% Author: Tim Gebbie 2008 QT Capital Management 

% $Revision: 1.2 $ $Date: 2008/09/26 11:34:26 $ $Author: Tim Gebbie $

%% Input data
switch nargin
    case 1
        price = varargin{1};
        fastlimit = 0.5;
        slowlimit = 0.05;
        
    case 3
        price = varargin{1};
        fastlimit = varargin{2};
        slowlimit = varargin{3};
        
    otherwise
        error('Incorrect Input Arguments');
end

%% Initialise variables
smooth = zeros(size(price));
detrender = zeros(size(price));
period = zeros(size(price));
Q1 = zeros(size(price));
I1 = zeros(size(price));
Q2 = zeros(size(price));
I2 = zeros(size(price));
phase = zeros(size(price));
smoothperiod = zeros(size(price));
deltaphase = zeros(size(price));
mama = zeros(size(price));
fama = zeros(size(price));

%% Filter co-efficients
sB = 1/10 * [0 0 0 1 2 3 4];
tB = [-0.0962 0 -0.5769 0 0.5769 0 0.0962];
aB = [0.8 0.2];

%% Nonlinear filter
for t=7:size(price,1)
    % period correction
    pB = (0.075 * period(t-1) + 0.54);
    % smooth the data
    smooth(t,:) = sB * price(t-6:t,:);
    % de-trend the data
    detrender(t,:) =  pB * (tB * smooth(t-6:t,:));
    % compute in-phase and qaudrature components
    Q1(t,:) = pB * (tB * detrender(t-6:t,:));
    I1(t,:) = Q1(t-3,:);
    % advance the phase of I1 and Q1 by 90 degrees
    jQ(t,:) = pB * (tB * Q1(t-6:t,:));
    jI(t,:) = pB * (tB * I1(t-6:t,:));
    % phasor addition for 3 bar averaging
    I2(t,:) = I1(t,:) - jQ(t,:);
    Q2(t,:) = Q1(t,:) + jI(t,:);
    % Smooth I and Q components before applying the discriminator
    I2(t,:) = aB * I2(t-1:t,:);
    Q2(t,:) = aB * Q2(t-1:t,:);
    % Homodyne discriminator
    Re(t,:) = I2(t,:) .* I2(t-1,:) + Q2(t,:) .* Q2(t-1,:);
    Im(t,:) = I2(t,:) .* Q2(t-1,:) + Q2(t,:) .* I2(t-1,:);
    % Smooth homodyned signals
    Re(t,:) = aB * Re(t-1:t,:);
    Im(t,:) = aB * Im(t-1:t,:);
    % construct and update the period
    ReImIndex = (Re(t,:)~=0 & Im(t,:)~=0);
    period(t,ReImIndex) = 360/atan(Im(t,ReImIndex)/Re(t,ReImIndex)); 
    % Upper and lower bounds
    gtIndex1 = (period(t,:)> 1.5 * period(t-1,:));
    period(t,gtIndex1) = 1.5 * period(gtIndex1);
    ltIndex1 = (period(t,:)< 0.67 * period(t-1,:));
    period(t,ltIndex1) = 0.67 * period(ltIndex1);
    gtIndex2 = (period(t,:) > 50);
    period(t,gtIndex2) = 50;
    ltIndex2 = (period(t,:) < 6);
    period(t,ltIndex2) = 6;
    % Smooth period
    period(t,:) = aB * period(t-1:t,:);
    % No linear smoothing of period
    smoothperiod(t,:) = 0.33 * period(t,:) + 0.67 * smoothperiod(t-1,:);
    % compute the alpha parameter for the EWMA filters
    zIndex = ~(I1(t,:)==0);
    phase(t,:) = atan(Q1(t,zIndex)/I1(t,zIndex));
    deltaphase(t,:) = phase(t-1,:) - phase(t,:);
    deltaphase(t,deltaphase(t,:)<1) = 1;
    % compute alpha
    alpha(t,:) = fastlimit ./ deltaphase(t,:);
    alpha(t,alpha(t,:)<slowlimit) = slowlimit;
    % compute MAMA and FAMA filters
    mama(t,:) = alpha(t,:) .* price(t,:) + (1-alpha(t,:)) .* mama(t-1,:);
    fama(t,:) = 0.5 * (alpha(t,:) .* mama(t,:)) + (1-0.5* alpha(t,:)) .* fama(t-1,:);
end

if nargout==0
    for i=1:size(price,2)
        figure;
        plot([price(:,i) mama(:,i) fama(:,i)]);
        title('MAMA Filter');
        legend('Price','MAMA','FAMA');
    end
end



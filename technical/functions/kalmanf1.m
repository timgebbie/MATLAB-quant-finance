function [xhat K]=kalmanf1(varargin)
% KALMANF1 Discrete order-1 Kalman Filter for Smoothing
%
% XHAT = KALMANF(X)Updates a system state vector estimate based upon an
%           observation, using a discrete Kalman filter. By default Q=1 and
%           R = 0.9. The parameter R = 0.9 is recommend for trending data
%           while R=10 for noisy data.
%
% XHAT = KALMANF(X,Q,R) For Q and R provided by user. 
% 
% XHAT = KALMANF(X,Q,R,XHAT0,K0) Initial value for online use is XHAT0 the 
%           online filter parameter is K0.
%
% XHAT = KALMANF(X,Q,R,[],[],ONLINE) ONLINE is by default 'false'. Set to 
%           'true' to ensure that only the last line of the filter is outputed.
%
% See Also: HPFILTER, KALMANF

% Author : Version 1.0, May 13, 2008, Raphael Nkomo
%          Version 1.1, May 15, 2008, Modified Tim Gebbie

% Developer notes:
%
% Many people have heard of Kalman filtering, but regard the topic
% as mysterious. While it's true that deriving the Kalman filter and
% proving mathematically that it is "optimal" under a variety of
% circumstances can be rather intense, applying the filter to
% a basic linear system is actually very easy. This Matlab file is
% intended to demonstrate that.

% 1.2 2009/05/28 11:40:51 Tim Gebbie

onlineFlag = false;
switch nargin
    case 1
        x = varargin{1};
        Q = 1;
        R = 10; %Adjust R for Degree of Damping
        K = [];
        
    case 3
        x = varargin{1};
        Q = varargin{2};
        R = varargin{3}; %Adjust R for Degree of Damping
        K = [];
        
    case 5
        x = varargin{1};
        Q = varargin{2};
        R = varargin{3}; % Adjust R for Degree of Damping
        xhat0 = varargin{4}; % initial value for online use
        K0 = varargin{5}; % coefficients for online use
        
    case 6
        x = varargin{1};
        Q = varargin{2};
        R = varargin{3}; % Adjust R for Degree of Damping
        xhat0 = []; % initial value for online use
        K0 = []; % coefficients for online use
        onlineFlag = varargin{6};
        
    otherwise
        error('Incorrect number of input arguments');
end

% The length of the data matrix x
m = size(x,1);

% initialise
z = zeros(size(x));
i = zeros(size(x));
xhat = zeros(size(x));
xhat0 = zeros(size(x));

% initialise 
for n = 1:m;
   z(n,:) = x(n,:);
   i(n,:) = n * ones(size(x(n,:)));
end;

% initialise variables 
Pmin1 = zeros(size(i(n,:)));
K = Pmin1 ./ (Pmin1+R);
xhat(1,:) = x(1,:) + K .* (z(1,:) - x(1,:));
P = (1-K) .* Pmin1;
Pmin = P + Q;
xhat0(1,:) = xhat(1,:);

% Run filter over data
for n = 2:1:m;
   K = Pmin ./(Pmin+R);
   xhat(n,:) = xhat0(n-1,:) + K .* (z(n,:) - xhat0(n-1,:));
   P = (1-K) .* Pmin;
   Pmin = P + Q;
   xhat0(n,:) = xhat(n,:);
end;

% output
if onlineFlag
    xhat = xhat(end,:);
end
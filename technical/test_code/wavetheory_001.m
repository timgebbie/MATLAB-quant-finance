%% Test Code : WAVETHEORY
%
% The Wave Equation is implemented as a difference equation:
%
% $$P_{n+1}=(2-\omega)^2 P_n - P_{n-1} + \omega^2 P_0$$
%
% for frequency
%
% $$\omega = {2\pi \over T}$$
%
% The difference equation is implemented as an ARMA filter.

%% Load data
load wavetheory_test_data

%% Run algo on data 
% period 
T = 6.3;
% window size
nT = 12;
% estimate the wave form
hatp = wavetheory(wave_price,T,nT,true);

%% Plot outcome
figure
plot([hatp(nT+1:end) wave_price(nT+1:end)]);
legend('\hat P_{n+1}','\tilde P_n');
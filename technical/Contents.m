% Technical Analysis Toolbox 
% Version 1.0 (R2008a) 01-Sep-2008
%
% General information.
%  The toolbox comprises a components for implementing various technical
%  analysis algorithms. The toolbox integrates with the Financial
%  Time-series objects (FINTS) from the Finance toolbox.
%
% Recommended Toolboxes
%   DATAFEED - Datafeed Toolbox
%   FINANCE  - Finance Toolbox
%
% General Functions.
%   KALMANF1   - 1-st order Kalman Filter (smoothing)
%   WAVETHEORY - Implement a wave-equation time-series prediction
%   FRAMAFILT  - Fractal adaptive moving average filter
%   MAMAFILT   - MESA adaptive moving average filter
%   GAUSSFILT  - Gaussian Filter
%   EHLERSFILT - Ehlers Filter
%   ICHIMOKU   - Ichimoky Kinko Hyo technical analysis
%   TSALLISENTROPY - Tsallis entropy indicator
%
% Functions from the Finance Toolbox
%   BOLLINGER  - Bollinger bands
%   MOVAVG     - Moving Average
%   RENKO      - Renko chart
%   KAGI       - Kagi chart
%   RSINDEX    - Relative Strength Index (RSI)
%   PVTREND    - Price and Volume Trend (PVT)
%   HHIGH      - Highest High
%   LLOW       - Lowest Low
%
% Scripts
%   JSE_DIR_ANTICOR_D - Execute Daily ANTICOR on JSE data list
%
% Objects
%   None at this time.
%
% Test Code
%   demo_technical  - help and demo files for technical
%   test_kalmanf1   - test code for kalman filter
%   test_mamafilt   - test code for MAMA filter
%   test_framafilt  - test code for FRAMA filter
%   test_gaussfilt  - test code for the Gaussian Filter
%   test_ehlersfilt - test code for the Ehlers Filter
%   test_ichimoku   - test code for the Ichimoku study
%   wavetheory_001  - test code for the wave-equation predictor
%
% Obsolete functions.
%   None at this time.
%
% Others
%   None at this time
%
% GUI Utilities.
%   None at this time.

%   Copyright 2008 Tim Gebbie, Raphael Nkomo, QT Capital Management

% 1.2 2008/09/29 13:01:14 Tim Gebbie

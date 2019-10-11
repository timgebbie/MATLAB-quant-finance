function data = gencordata(m,k)
% GENCORDATA calculates price time series with correlation k
%
% DATA = GENCORDATA(M,K) M is the length of time series, and K the 
%   required range of correlations where 0 <= k <= 1.
% 
% GENCORDATA(m,k) create 2 time series with correlation k,
%
% Example: 
% >> gencordata(10,1)
% ans =
%         0    1.0000    1.0000
%    0.1000    2.2773    2.2773
%    0.2000    5.6771    5.6771
%    0.3000    4.4696    4.4696
%    0.4000    7.1704    7.1704
%    0.5000    3.8586    3.8586
%    0.6000    9.5254    9.5254
%    0.7000    4.1503    4.1503
%    0.8000    1.4780    1.4780
%    0.9000   11.5743   11.5743
%    1.0000    8.5650    8.5650
%
% See also ftcorr.m, ftcovar.m
%
% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: user $
%
% $Author Chanel Malherbe, TG

%create two random return time series with stdev = 1 (unit variance)
A(1:m+1) = sqrt(1)*randn(m+1,1); % [%]/time unit
B(1:m+1) = sqrt(1)*randn(m+1,1);
%create a third series correlated with A by k
C(1:m+1) = k*A + sqrt(1-k^2)*B;  
%set initial values
PA = ones(m+1,1);
PB = ones(m+1,1);
PC = ones(m+1,1);
% get day normalisations
% A: Fix volatility per sample period
dt = 1; % 1=1 time unit e.g. 1 day, 1 year, ....
% B: Fix volatility per unit time
% dt = 1/m;
%create log-normal price series from returns
for i = 2:(m+1)
    PA(i) = PA(i-1) * exp(A(i-1))*sqrt(dt); 
    PB(i) = PB(i-1) * exp(B(i-1))*sqrt(dt);
    PC(i) = PC(i-1) * exp(C(i-1))*sqrt(dt);
end
% A:  fixed unit of time changes
T = 0:m; % M time units
% B:  fixed total unit of time
% T = 0:1/m:1;
%return series
data = [T(:),PC,PA];
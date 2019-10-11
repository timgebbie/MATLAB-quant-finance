%% Calibration Testcode for FFT methods

%% Error measures
% root mean square error
rmse  = inline('sqrt(mean((m-m0).^2))','m','m0');
% mean square error
rme   = inline('mean((m-m0).^2)','m','m0');
% weight root mean square error
wrmse = inline('sqrt(mean(w.*(m-m0).^2))','m','m0','w');

%% Initial parameters
type = 'rmse';

%% Nelder-Mead search
p=fminsearch(@(p)errfns(p,m0,type),p0,options);

%% Variance Reduction
% lsqnonlin (f(x)^2 for vector valued f)

%% Alternative using Simplex algorithm
% fminunc 
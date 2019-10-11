function [rho,Sigma,sigma] = ftcorr(varargin)
% FTCORR calculates the correlation of inhomogeneous sampled data
%
% [CORR,COVAR,STD] = FTCORR(P,T) P is a SPARSE matrix representing the
%   prices process (zero prices non-trades) at time in double 
%   matrix T conforming to data entry times in P. Non-trading times are 
%   represented as NAN to ensure easy transformation to domain [0,PI]. For N
%   the number of Fourier coefficients to be included, the first element is
%   that coefficients to be excluded from the range. The algorithm 
%   calculates the correlation between inhomogeneously
%   sampled processes using the method proposed by Malliavin and Mancino 
%   in their paper 'Harmonic analysis methods for nonparametric estimation 
%   of volatility'. The number N of times to be included are the N times for 
%   every trade in the M time series. The algorithm uses FT on GPU's before
%   the computation of the correlations from the Fourier-Frejet inversion 
%   formulae.
%
% TODO: OFFLINE/ONLINE output [rho,f0] ==... where f0 is a structure with
% the online parameters (f0.var, f0.pp, f0.rho, f0.CA, f0.CB..) in
% offline mode
% 
% NOTE: (n,N) are the number of data point n and the number of coefficient
% N. The scaling factor is a function of n and N.
%
% See also ftvar.m, ftcovar.m, fftcorrgpu
%
% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: user $
%
% $Author Chanel Malherbe, Dieter H, Tim G

%% TODO
% 2. Check the rescaling function used to map P to [0,PI]

%% assign the input arguments
% initial defaults
optargs = {[] [] Inf};
% now put these defaults into the valuesToUse cell array,
optargs(1:nargin) = varargin;
% Place optional args in memorable variable names
[p, t, N] = optargs{:};

%% preallocate arrays and check data
[np,mp]=size(p);
[nt,~] = size(t);
if ~(nt==np), error('Incorrect Data'); end

%% rescale domain to [0,PI]
tau = scale(t); % matrix with NaN for non-trades
% compute the average minimum time change
dtau = diff(tau);
dtau(dtau==0) = nan;
% taumin = nanmin(nanmin(diff(tau))); % can use minimum step size to avoid smoothing
taumin = nanmin(nanmin(dtau));
taumax = 2*pi;
% compute the number of Fourier coefficients
N = (taumax/taumin);
% use Nyquist and compute the wavenumber range
k = 1:round(2*N);

%% parfoor loop of 2 CPU workers, each assigned to separate GPU.
fa = zeros(mp,size(k,2));
fb = zeros(mp,size(k,2));
for i=1:mp % for debugging [CHECK matrix logic]
    % nonuniformly sampled data from sparse matrix
    [psii,~,psi] = find(p(:,i));
    % convert to log-prices after zeros are removed
    psi = log(psi);
    % slice the data first
    tsi = tau(:,i);
    % sampling times from the rescaled domain
    tsi = tsi(psii);
    % drift
    d = (psi(end,:) - psi(1,:))./pi; % drift
    % ------- Fourier Transform on inhomogeneously sampled data -------
    fa(i,:) = d + (1/pi)*(psi(1:end-1)'*(cos(tsi(1:end-1)*k) - cos(tsi(2:end)*k))); 
    fb(i,:) = (1/pi)*(psi(1:end-1)'*(sin(tsi(1:end-1)*k) - sin(tsi(2:end)*k)));    
end

%% calculate the integrated volatility and covolatility over the entire time window
% Fourier-Fejer formulae [2*pi*(pi * (tau/T))]
Sigma = 2*pi^2*(taumin/taumax)*(fa*fa' + fb*fb'); % CHECK SCALING HERE
% variances
var = diag(Sigma);
% standard deviations
sigma = sqrt(var);

%% calculate the correlation
rho = Sigma./(sigma*sigma');

%% helper functions
function tau = scale(t)
% SCALE(X) rescales time series t from [t1,t2] to [0,2*pi]
%
% TAU = SCALE(t) Rescales a M dimension sparse time series 
%   from [t1,t2] to [0,2*pi] using the formula [3.11]:
%
%                           (t(j) - t(1))
%       TAU(j,:) = 2 * PI * ------------
%                           (t(n) - t(1))
%
% NB: should set 24 hours = 1

% FIXME 2: All the data is rescaled onto [0,2Pi] for overall MAX in T and MIN in T 

% $Author Chanel Malherbe, Tim G, Dieter H

% find the maximum times t(N) for each stock
maxt = nanmax(nanmax(t)); 
% find the minimum times t(1) for each stock
mint = nanmin(nanmin(t)); 
% rescale the dates
tau = 2 * pi * (t - mint)./(maxt - mint);
% EOF
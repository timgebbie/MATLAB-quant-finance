function [rho,Sigma,var] = fftcorrgpu(varargin)
% FFTCORRGPU calculates the correlation of inhomogeneous sampled data
%
% [CORR,COVAR,VAR] = FFTCORRGPU(P,T,N) For time-series sparse matrix 
%   M assets and range N = [N0,NRFC] times of inhomogeneously sampled data 
%   at time in spares matrix T conforming to data entry times in P. For N
%   the number of Fourier coefficients to be included, the first element is
%   that coefficients to be excluded from the range. The algorithm 
%   calculates the correlation between inhomogeneously
%   sampled processes using the method proposed by Malliavin and Mancino 
%   in their paper 'Harmonic analysis methods for nonparametric estimation 
%   of volatility'. The number N of times to be included are the N times for 
%   every trade in the M time series. The algorithm uses FFT on GPU's before
%   the computation of the correlations from the Fourier-Frejet inversion 
%   formulae.
%
% FFTCORRGPU(P,T,N,M) uses the PARPOOL object M for the computations. 
% 
% See also ftvar.m, ftcovar.m
%
% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: user $
%
% $Author Chanel Malherbe, Dieter H, Tim G

%% TODO
% 1. Implement NUFFT to use FFT with unevenly sampled data
% 2. Check the domain and scaling in the Fourier-Fejer step
% 3. Check the dimensions of vectorized computation of RHO

%% assign the input arguments
cp = gcp('nocreate');
% initial defaults
optargs = {[] [] [] []};
% now put these defaults into the valuesToUse cell array,
optargs(1:nargin) = varargin;
% Place optional args in memorable variable names
[p, t, n, pp] = optargs{:};
% manage parallel pool
if isempty(pp)
    if ~isempty(cp),
        % assign current pool to par pool for use with 3 GPU's
        pp = cp; 
    end
end
% check the current pool has 3 workers (and hence uses 3 GPU's).
if isempty(pp) || ~(pp.NumWorkers==3)
    % delete the incorrectly configured pool
    delete(gcp);
    % reinitialize the correct pool
    pp = parpool(3);
end

%% preallocate arrays and check data
[np,mp]=size(p);
[nt,~] = size(t);
if ~(nt==np), error('Incorrect Data'); end

%% data slicing and log-returns calculation
dp = diff(log(p)); %% spares

%% rescale the time series from [t1,t2] to [0,2pi]
tau = scale(t);

%% parfoor loop of 2 CPU workers, each assigned to separate GPU.
parfor i=1:m
    gd = gpuDevice;
    d(i) = gd.Index;
    psi = nonzero(dp(:,i));
    P = gpuArray(psi); 
    % ----------- NUFFT like algo -------------
    % 1. initialise guassian point spreads
    % 2. time scaling and convolution with guassian point spreads
    % 3. uniformly sampled FFT
    C = fft(P,nrfc);
    % 4. deconvolve 
    % -----------------------------------------
    fca(i,:) = gather(2*real(C));
    fcb(i,:) = gather(-2*imag(C));    
end
%% condition the data on correct domain
fca = fca(n(1):n(2),:);
fcb = fcb(n(1):n(2),:);

%% calculate the integrated volatility and covolatility over the entire time window
Sigma = (pi^2/(nrfc + 1 - n0))*(fca'*fca + fcb'*fcb);
var = diag(Sigma);
sigma = sqrt(var);

%% calculate the correlation
rho = covar./(sigma'*sigma);
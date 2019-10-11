function [rho,Sigma,var] = ftcorrgpucuda(varargin)
% FTCORGPU2 calculates the correlation of inhomogeneous sampled data
%
% [CORR,COVAR,VAR] = FTCORRGPU(P,T,NFC) For time-series sparse matrix 
%   M assets and fourier coefficient range NFC = [N0,NRFC] times of 
%   inhomogeneously sampled data, P is a SPARSE matrix representing the
%   prices (zero prices are non-trades) at time in double matrix T 
%   conforming to data entry times in P. Non-trading times are represented
%   as NAN to ensure easy transformation to domain [0,PI]. For N
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
% FTCORRGPU(P,T,NFC,PP) uses the PARPOOL object PP for the computations.
%
% TODO: OFFLINE/ONLINE output [rho,f0] ==... where f0 is a structure with
% the online parameters (f0.var, f0.pp, f0.rho, f0.CSA, f0.CSB..) in
% offline mode the parallization is across 3 GPU and the CSA and CSB are
% computed in online mode a single CPU-GPU pair is used and the last
% data point is concatenated onto CSA and CSB for all the stock in a single
% vectorised step and new FCA and FCB's are computed and the algrithm
% continues as before
% 
%
% See also ftvar.m, ftcovar.m, fftcorrgpu
%
% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: user $
%
% $Author Chanel Malherbe, Dieter H, Tim G

%% TODO
% 1. Check matrix dimensions inside vectorized GPU actions 
% 2. Check the rescaling function used to map P to [0,PI]

%% assign the input arguments
cp = gcp('nocreate');
% initial defaults
optargs = {[] [] [] []};
% now put these defaults into the valuesToUse cell array,
optargs(1:nargin) = varargin;
% Place optional args in memorable variable names
[p, t, nfc, pp] = optargs{:};
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

%% rescale domain to [0,PI]
tau = scale(t); % matrix with NaN for non-trades

%% load CUDA kernels into MATLAB
% drift_kernel = parallel.gpu.CUDAKernel( 'calculateDrift.ptx', 'calculateDrift.cu' );
% csa_kernel = parallel.gpu.CUDAKernel( 'calculateCSA.ptx', 'calculateCSA.cu' );

%% set up CUDA threads
% blockSize = 256;
% drift_kernel.ThreadBlockSize = [blockSize, 1, 1];
% drift_kernel.GridSize = [ceil(np/blockSize),1];
% csa_kernel.ThreadBlockSize = [blockSize, 1, 2];
% csa_kernel.GridSize = [ceil(np/blockSize),size(nfc(1):nfc(end),2)];

%% parfoor loop of 2 CPU workers, each assigned to separate GPU.
krange = nfc(1):nfc(end);
for i=1:mp % for debugging [CHECK matrix logic]
% parfor i=1:mp
    gd = gpuDevice;    
    
    % load CUDA kernels into MATLAB
%     drift_kernel = parallel.gpu.CUDAKernel( 'calculateDrift.ptx', 'calculateDrift.cu' );
    csa_kernel = parallel.gpu.CUDAKernel( 'calculateCSA.ptx', 'calculateCSA.cu' );
    csb_kernel = parallel.gpu.CUDAKernel( 'calculateCSB.ptx', 'calculateCSB.cu' );
    fc_kernel = parallel.gpu.CUDAKernel( 'calculateFC.ptx', 'calculateFC.cu' );
    fca_kernel = parallel.gpu.CUDAKernel( 'calculateFCA.ptx', 'calculateFCA.cu' );
    
    % set up CUDA threads
    blockSize = 32;
%     drift_kernel.ThreadBlockSize = [blockSize, 1, 1];
%     drift_kernel.GridSize = [ceil(np/blockSize),1];
    csa_kernel.ThreadBlockSize = [blockSize, blockSize, 1];
    csa_kernel.GridSize = [ceil(np/blockSize),ceil(size(nfc(1):nfc(end),2)/blockSize)];
    csb_kernel.ThreadBlockSize = [blockSize, blockSize, 1];
    csb_kernel.GridSize = [ceil(np/blockSize),ceil(size(nfc(1):nfc(end),2)/blockSize)];
    fc_kernel.ThreadBlockSize = [blockSize, blockSize, 1];
    fc_kernel.GridSize = [ceil(np/blockSize),ceil(size(nfc(1):nfc(end),2)/blockSize)];
    fca_kernel.ThreadBlockSize = [blockSize, blockSize, 1];
    fca_kernel.GridSize = [ceil(np/blockSize),ceil(size(nfc(1):nfc(end),2)/blockSize)];

    % for debugging : d(i) = gd.Index;
    % nonuniformly sampled data from sparse matrix
    % [psii,~,psi] = find(p(:,i));
    pii = p(:,i);
    psii = isnan(pii);
    psi = pii(~psii);
    % slice the data first
    tsi = tau(:,i);
    % sampling times from the rescaled domain
    tsi = tsi(~psii,:);
    % |-- on GPU --->
    % data to GPU
    P = gpuArray(psi); % unevenly sampled prices on [0,pi]
    T = gpuArray(tsi); % unevenly sampled times
    K = gpuArray(krange); % wave numbers
%     D = gpuArray(zeros(1,1));
    CSA = gpuArray(zeros((size(T,1)-1)*size(K,2),1));
    CSB = gpuArray(zeros((size(T,1)-1)*size(K,2),1));
    FCA = gpuArray(zeros(size(K,2),1));
    FCB = gpuArray(zeros(size(K,2),1));
    D = (P(end,:) - P(1,:))./pi; % drift
%     D = feval(drift_kernel, D, P(1,:), P(end,:), mp, pi);
    
    % ------- Fourier Transform on inhomogeneously sampled data -------
    % convolution kernel
%     CSA = cos(T(2:end)*K) - cos(T(1:end-1)*K);
%     CSB = sin(T(2:end)*K) - sin(T(1:end-1)*K);
    CSA = feval(csa_kernel, CSA, T(1:end-1), T(2:end), K, size(T,1)-1, size(K,2));
    CSB = feval(csa_kernel, CSB, T(1:end-1), T(2:end), K, size(T,1)-1, size(K,2));
    
    % convolution weights
%     FCA = D -(1/pi)*(P(1:end-1)'*CSA); 
%     FCB = (1/pi)*(P(1:end-1)'*CSB);    
    FCA = feval(fc_kernel, FCA, P(1:end-1), CSA, size(P,1)-1, size(P,1)-1, size(K,2), pi);    
    FCA = feval(fca_kernel, FCA, FCA, D, size(FCA,1));    
    FCB = feval(fc_kernel, FCB, P(1:end-1), CSB, size(P,1)-1, size(P,1)-1, size(K,2), pi);
    
    % --------------------------------------------------
    % <-- off GPU ---|
    % data from GPU
    fca(i,:) = gather(FCA');
    fcb(i,:) = gather(FCB');    
end

%% calculate the integrated volatility and covolatility over the entire time window
% Fourier-Fejer formulae
Sigma = (pi^2/(1 + diff(nfc)))*(fca*fca' + fcb*fcb'); % CHECK SCALING HERE
var = diag(Sigma);
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

% $Author Chanel Malherbe, Tim G, Dieter H

% find the maximum times t(N) for each stock
maxt = max(t); 
% find the minimum times t(1) for each stock
mint = min(t);
% unit vector operator
e = ones(size(t,1),1);
% rescale the dates
tau = 2 * pi * (t - e*mint)./(e*(maxt - mint));
% EOF
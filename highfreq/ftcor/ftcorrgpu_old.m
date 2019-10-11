function [rho,Sigma,sigma] = ftcorrgpu(varargin)
% FTCORRGPU calculates the correlation of inhomogeneous sampled data
%
% [CORR,COVAR,STD] = FTCORRGPU(P,T) P is a SPARSE matrix representing the
%   price process (zero prices are non-trades) at times in double 
%   matrix T conforming to data entry times in P. Non-trading times are 
%   represented as NAN to ensure easy transformation to domain [0,PI]. 
%   For N the number of Fourier coefficients to be included, the first 
%   element is that coefficients to be excluded from the range. The 
%   algorithm calculates the correlation between inhomogeneously
%   sampled processes using the method proposed by Malliavin and Mancino 
%   in their paper 'Harmonic analysis methods for nonparametric estimation 
%   of volatility'. The number N of times to be included are the N times for 
%   every trade in the M time series. The algorithm uses FT on GPU's before
%   the computation of the correlations from the Fourier-Frejet inversion 
%   formulae.
%
% Note: The MM algorithm works for log-prices. This conversion takes place
% inside the algorithm on the GPU.
%
% FTCORRGPU(P,T,PP) uses the PARPOOL object PP for the computations.
%
% TODO: OFFLINE/ONLINE output [rho,f0] ==... where f0 is a structure with
% the online parameters (f0.var, f0.pp, f0.rho, f0.CSA, f0.CSB..) in
% offline mode the parallization is across 3 GPU and the CSA and CSB are
% computed in online mode a single CPU-GPU pair is used and the last
% data point is concatenated onto CSA and CSB for all the stock in a single
% vectorised step and new FCA and FCB's are computed and the algrithm
% continues as before
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
% 1. Check matrix dimensions inside vectorized GPU actions 
% 2. Check the rescaling function used to map P to [0,PI]

%% assign the input arguments
% cp = gcp('nocreate');
% initial defaults
optargs = {[] [] [] [] []};
% now put these defaults into the valuesToUse cell array,
optargs(1:nargin) = varargin;
% Place optional args in memorable variable names
[p, t, pp, fourierMethod, onlyOverlapping] = optargs{:};
% manage parallel pool
% if isempty(pp)
%     if ~isempty(cp),
%         % assign current pool to par pool for use with 3 GPU's
%         pp = cp; 
%     end
% end
% check the current pool has 3 workers (and hence uses 3 GPU's).
% if isempty(pp) || ~(pp.NumWorkers==3)
%     % delete the incorrectly configured pool
%     delete(pp);
%     % reinitialize the correct pool
%     matlabpool('open',3');
%     pp = parcluster;
% end

%% preallocate arrays and check data
[np,mp]=size(p);
[nt,~] = size(t);
if ~(nt==np), error('Incorrect Data'); end

%% rescale domain to [0,PI]
tau = scale(t); % rescale matrix with NaN for non-trades

%% compute the normalisations

% Eliminate non-overlapping times
if onlyOverlapping
    [idNanTau] = zeros(size(tau,1),2);
    % identify missing times (indicated as nan)
    idNanTau = isnan(tau);
    % eliminate times and prices associated with non-overlapping times
    tau = repmat(tau(idNanTau(:,1)==0 & idNanTau(:,2)==0),1,2);
    price1 = p(:,1);
    price2 = p(:,2);
    price1 =  price1(idNanTau(:,1)==0 & idNanTau(:,2)==0);
    price2 =  price2(idNanTau(:,1)==0 & idNanTau(:,2)==0);
    p = [price1,price2];
end

% compute the average minimum time change
dtau = diff(tau);
dtau(dtau==0) = nan;
% taumin = nanmin(nanmin(diff(tau))); % can use minimum step size to avoid smoothing
taumin = nanmin(nanmin(dtau));
taumax = 2*pi;
% compute the number of Fourier coefficients
N0 = max(taumax./taumin); % (T/tau)
% use Nyquist and compute the wavenumber range for each stock
k = 1:round(2*N0); % minimum k range

%% parfoor loop of 2 CPU workers, each assigned to separate GPU.
<<<<<<< .mine
fca = zeros(mp,size(k,2));
fcb = zeros(mp,size(k,2));
% gd = gpuDevice(1);
% for i=1:mp % for debugging [CHECK matrix logic]
parfor i=1:mp
    gd = gpuDevice;
%     for debugging : 
%     d(i) = gd.Index;
%     disp(d(i));
    % split up data to avoid GPU out-of-memory errors
%     for j=1:1000:size(p,1)
=======
switch fourierMethod
    case 'TrigFejer'
        fca = zeros(mp,size(k,2));
        fcb = zeros(mp,size(k,2));
        % gd = gpuDevice(1);    
        for i=1:mp % for debugging [CHECK matrix logic]
        % parfor i=1:mp
            gd = gpuDevice;
        %     for debugging : 
            d(i) = gd.Index;
            disp(d(i));
            % split up data to avoid GPU out-of-memory errors
        %     for j=1:1000:size(p,1)


            % nonuniformly sampled data from sparse matrix
            [psii,~,psi] = find(p(:,i));
            % slice the data first
            tsi = tau(:,i);
            % sampling times from the rescaled domain
            tsi = tsi(psii);
            % |-- on GPU --->
            % data to GPU
            P = gpuArray(psi); % unevenly sampled prices on [0,pi]
            T = gpuArray(tsi); % unevenly sampled times
            K = gpuArray(k); % wave numbers
            % compute on GPU
            P = log(P); % conversion to log-prices
            D = (P(end,:) - P(1,:))./pi; % drift
            % ------- Fourier Transform on inhomogeneously sampled data -------
            % convolution kernel
            CSA = cos(T(2:end)*K) - cos(T(1:end-1)*K);
            CSB = sin(T(2:end)*K) - sin(T(1:end-1)*K);
            % convolution weights
            FCA = D -(1/pi)*(P(1:end-1)'*CSA);
            % FCA = (1/pi)*(P(1:end-1)'*CSA);
            FCB = (1/pi)*(P(1:end-1)'*CSB);
            % --------------------------------------------------
            % <-- off GPU ---|
            % data from GPU
            fca(i,:) = gather(FCA);
            fcb(i,:) = gather(FCB); 
        end

        % calculate the integrated volatility and covolatility over the entire time window
        % Fourier-Fejer formulae [2*pi*(pi*tau/T)] [units?]
        % Sigma = (2*pi^2/N0)*((fca*fca' + fcb*fcb')); % CHECK SCALING HERE
        Sigma = (pi^2/(2*N0^2))*((fca*fca' + fcb*fcb')); % FIXED, BUT NOT SURE WHY
>>>>>>> .r67
        
    case 'ComplexExpFejer'
        for i=1:mp % for debugging [CHECK matrix logic]
%         parfor i=1:mp
            gd = gpuDevice;
        %     for debugging : 
            d(i) = gd.Index;
            disp(d(i));
            % nonuniformly sampled data from sparse matrix
            [psii,~,psi] = find(p(:,i));
            % slice the data first
            tsi = tau(:,i);
            % sampling times from the rescaled domain
            tsi = tsi(psii);
            % |-- on GPU --->
            % data to GPU
            P = gpuArray(psi); % unevenly sampled prices on [0,pi]
            T = gpuArray(tsi); % unevenly sampled times
            K = gpuArray(k); % wave numbers
            
            % initialise gpuArrays for calculations
            E_t_dP(i,1).NegComplexExpDiffPrice = gpuArray(zeros(1,size(K,2)));
            E_t_dP(i,1).PosComplexExpDiffPrice = gpuArray(zeros(1,size(K,2)));
            % compute on GPU
            % conversion to log-prices and calculation of log-price differences
            P = log(P); 
            DiffP = diff(P); 
            
            % ------- Fourier Transform on inhomogeneously sampled data -------
            
            % create complex exponential coefficients, multuply with
            % log-price differences
            E_t_dP(i,1).NegComplexExpDiffPrice = DiffP' * exp((complex(0,-T(2:end,1)*K(1,:))));
            E_t_dP(i,1).PosComplexExpDiffPrice = DiffP' * exp((complex(0,T(2:end,1)*K(1,:))));
            % --------------------------------------------------
            % <-- off GPU ---|
            % data from GPU
            e_t_dp(i,1).PosComplexExpDiffPrice = gather(E_t_dP(i,1).PosComplexExpDiffPrice);
            e_t_dp(i,1).NegComplexExpDiffPrice = gather(E_t_dP(i,1).NegComplexExpDiffPrice);
        end

        % calculate the integrated volatility and covolatility over the entire time window
        % Fourier-Fejer formulae [2*pi*(pi*tau/T)] [units?]

        % Complex exponential Fejer - unparallelised for testing (works for synchronous)
%         n1 = n(1,1);
%         n2 = n(2,1);
%         tempSigma_1_2 = 0;
%         tempSigma_1_1 = 0;
%         tempSigma_2_2 = 0;
%         for s=1:N0
%             for i=1:n1-1
%                 for j=1:n2-1
%                     tempSigma_1_2 = tempSigma_1_2 + ...
%                                exp(complex(0,s*(times(1,1).times(i,1) - times(2,1).times(j,1)))) * ...
%                                 diffP(1,1).diffPrices(i,1) * diffP(2,1).diffPrices(j,1);
%                             
%                     tempSigma_1_1 = tempSigma_1_1 + ...
%                                 exp(complex(0,s*(times(1,1).times(i,1) - times(1,1).times(j,1)))) * ...
%                                 diffP(1,1).diffPrices(i,1) * diffP(1,1).diffPrices(j,1);
%                     
%                     tempSigma_2_2 = tempSigma_2_2 + ...
%                                 exp(complex(0,s*(times(2,1).times(i,1) - times(2,1).times(j,1)))) * ...
%                                 diffP(2,1).diffPrices(i,1) * diffP(2,1).diffPrices(j,1);
%                 end
%             end
%         end
%         Sigma(1,1) = 1/(N0^2+1) * tempSigma_1_1;
%         Sigma(1,2) = 1/(N0^2+1) * tempSigma_1_2;
%         Sigma(2,1) = Sigma(1,2);
%         Sigma(2,2) = 1/(N0^2+1) * tempSigma_2_2;

        % Complex exponential Fejer - vectorised
        Sigma(1,1) = 1/(2*N0^2+1) * sum(e_t_dp(1,1).PosComplexExpDiffPrice .* e_t_dp(1,1).NegComplexExpDiffPrice);
        Sigma(1,2) = 1/(2*N0^2+1) * sum(e_t_dp(1,1).PosComplexExpDiffPrice .* e_t_dp(2,1).NegComplexExpDiffPrice);
        Sigma(2,1) = Sigma(1,2);
        Sigma(2,2) = 1/(2*N0^2+1) * sum(e_t_dp(2,1).PosComplexExpDiffPrice .* e_t_dp(2,1).NegComplexExpDiffPrice);
        
    case 'HY'
        if ~onlyOverlapping
            [idNanTau] = zeros(size(tau,1),2);
            % identify missing times (indicated as nan)
            idNanTau = isnan(tau);
            % eliminate times and prices associated with non-overlapping times
            tau = repmat(tau(idNanTau(:,1)==0 & idNanTau(:,2)==0),1,2);
            price1 = p(:,1);
            price2 = p(:,2);
            price1 =  price1(idNanTau(:,1)==0 & idNanTau(:,2)==0);
            price2 =  price2(idNanTau(:,1)==0 & idNanTau(:,2)==0);
            p = [price1,price2];
        end
        [~,~,prices(:,1)] = find(p(:,1));
        [~,~,prices(:,2)] = find(p(:,2));
        prices = log(prices);
        diffP = diff(prices);
        
        Sigma(1,1) = 1/N0 * diffP(:,1)'*diffP(:,1);
        Sigma(1,2) = 1/N0 * diffP(:,1)'*diffP(:,2);
        Sigma(2,1) = Sigma(1,2);
        Sigma(2,2) = 1/N0 * diffP(:,2)'*diffP(:,2);
end

%% calculate the individual volatility, correlation
var = diag(Sigma);
sigma = sqrt(var);
rho = real(Sigma./(sigma*sigma'));

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

% FIXME 2: All the data is rescaled onto [0,2Pi] for overall MAX in T and MIN in T 

% $Author Chanel Malherbe, Tim G, Dieter H

% find the maximum times t(N) for each stock
maxt = nanmax(nanmax(t));  
% find the minimum times t(1) for each stock
mint = nanmin(nanmin(t)); 
% rescale the dates
tau = 2 * pi * (t - mint)./(maxt - mint);
% EOF
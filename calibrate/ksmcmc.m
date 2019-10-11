function [p, KSstatistic] = ksmcmc(varargin)
% KSMCMC Generate the parameter chain for a given function and parameter
%
% [C,KS] = KSMCMC(FN,T,YTILDE,P0,PU) Where FN is a function handle and P0 is 
% the initial conditions for the function and YTILDE is the measured data 
% matrix at times in T. PU is the random update rule for P1 = P0 + PU' * PE 
% for PE a random process. Column 1 of the matrix D is assumed to be time. 
% The first input parameter in FN is taken to be time. C is the parameter
% chain and KS the Kolmogorov-Smirnov statistic at each iteration in the 
% chain. A power law cooling schedule is used.
%
% Algorithm:
%     
%     1. Choose initial point (p0) in parameter space
%     2. Generate parameter Jump from Jump-PDF: p1 = p0 + dp(e)
%     3. Accept/reject jump - always accept better likelihoods
%        and reject with uniform probability 
%     4. Check burn-in, convergence and mixing of parameter chains
%
% Example 1.
%   p0 = [3.5,-3,2.27,0.35,2003,7,-14];
%   pu = [1,1,1,1,0,10,1];
%   [p,c] = MCMC(@FN,t,x,p0,pu);
%
% See Also: KSTEST2

% Tim Gebbie

% 1.0 2015/09/01 Tim Gebbie

% Initial defaults
% initialise old value of chi^2
chi2(1) = 1e12; 
% number of elements in chain
nchain = 4000;
% initial variance
pvar = 0.10;  

switch nargin,
    case 5,
        fn = varargin{1};
        t = varargin{2};
        ytilde = varargin{3};
        p = varargin{4};
        pu = varargin{5};
    case 6,
        fn = varargin{1};
        t = varargin{2};
        ytilde = varargin{3};
        p = varargin{4};
        pu = varargin{5};
        nchain = varargin{6};
    case 7,
        fn = varargin{1};
        t = varargin{2};
        ytilde = varargin{3};
        p = varargin{4};
        pu = varargin{5};
        nchain = varargin{6};
        pvar = varargin{7};
    otherwise
        error('Incorrect number of input arguments');
end;

% the number of parameters
np = length(p); 

% cooling schedule
% cooling = inline('t .^(3) ./ a.^3 + 0.1','t','a');

% Do loop over chains
% initialise K-S statistics
KSstatistic = zeros(nchain);
%-------------------------------------------------------------------------
for j = 2:nchain,
    % Choose delta p from exponential pdf with variance = 1 (cf Tegmark)
    % normally distributed jumps with mean zero and sigma=var(t) for the n variables
    pe = (pvar).*randn(1,np);
    % the parameter update rules
    pe = pu .* pe;
    % randomly update the initial conditions and add to parameter chain
    p(j,:) = p(j-1,:) + pe;
    % better to remove the NAN data first (but not done here!)
    %-----------------------------------------------
    % Calculate likelihood of current parameter set 
    %-----------------------------------------------
    % initialise KS-statistic
    KSstatistic(j) = 0;   
    % ----------------------------------------------
    % calculate model estimated data
    % ----------------------------------------------
    yhat = fn(t,p(j,:));
    % sigma = 1 assumed
    % ----------------------------------------------
    % 2-sided K-S Test
    % ----------------------------------------------
    % Calculate F1(x) and F2(x), the empirical (i.e., sample) CDFs.
    % compute the bins
    binEdges    =  [-inf ; sort([yhat;ytilde]) ; inf];
    % count the bins in the estimated timeseries
    binCounts1  =  histc (yhat , binEdges, 1);
    % count the bins in the measure timeseries
    binCounts2  =  histc (ytilde , binEdges, 1);
    % compute the accumulated normalised bin sums
    sumCounts1  =  cumsum(binCounts1)./sum(binCounts1);
    sumCounts2  =  cumsum(binCounts2)./sum(binCounts2);
    % compute the CDF's
    sampleCDF1  =  sumCounts1(1:end-1);
    sampleCDF2  =  sumCounts2(1:end-1);
    % difference between CDFS
    deltaCDF  =  abs(sampleCDF1 - sampleCDF2);
    % Kolmogorov-Smirnof Statistic
    % ----------------------------------------------
    KSstatistic(j)   =  max(deltaCDF);
    % ----------------------------------------------
    % may not be necessary
    % n1     =  length(yhat);
    % n2     =  length(ytilde);
    % n      =  n1 * n2 /(n1 + n2);
    % lambda =  max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * KSstatistic , 0);
    % j       =  (1:101)';
    % pValue  =  2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
    % pValue  =  min(max(pValue, 0), 1);
    % ----------------------------------------------
    % Accept last jump or not
    % ----------------------------------------------
    % choose the better KS statistic given that the difference is
    % meaningful - should compare p-values given a random threshold
    if (KSstatistic(j) < KSstatistic(j-1)) || (rand < exp(-KSstatistic(j) + KSstatistic(j-1)))
        % Keep the current parameters values and update the KS-statistic  
    else
        % reject and keep the old value
        p(j,:) = p(j-1,:);
        % keep the old Chi2 parameter
        KSstatistic(j) = KSstatistic(j-1);
    end;
end;  % end of loop over chain using nchain



  







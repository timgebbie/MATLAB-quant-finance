function [p, chi2] = mcmc(varargin),
% MCMC Generate the parameter chain for a given function and parameter
%
% [C,CHI2] = MCMC(FN,T,YTILDE,P0,PU) Where FN is a function handle and P0 is 
% the initial conditions for the function and YTILDE is the measured data 
% matrix at times in T. PU is the random update rule for P1 = P0 + PU' * PE 
% for PE a random process. Column 1 of the matrix D is assumed to be time. 
% The first input parameter in FN is taken to be time. C is the parameter
% chain and CHI2 the chi-squared at each iteration in the chain. A power
% law cooling schedule is used.
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
%   [p,c] = MCMC(@logp,t,usdzar,p0,pu);
%
% See Also: LOGP

% Based loosely on code patterns of Bruce Bassett re-coded by Tim Gebbie

% 1.1 2008/07/01 14:45:33 Tim Gebbie

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
    % initialise chi^2
    chi2(j) = 0;   
    % calculate chi^2 for measured data
    yhat = fn(t,p(j,:)); 
    % sigma = 1 assumed
    chi2(j) = sum((ytilde - yhat).^2);   
    % ----------------------------------------------
    % Accept last jump or not
    % ----------------------------------------------
    % accept the new parameters if Chi2 decreases or random choice 
    % using Hastings-Metropolis (ratio of new likelihood to old likelihood)
    % choice otherwise reject choice and
    if (chi2(j) < chi2(j-1)) || (rand < exp(-chi2(j) + chi2(j-1))),  
        % Keep the current parameters values and update 
        % the Chi2 parameter 
    else,
        % reject and keep the old value
        p(j,:) = p(j-1,:);
        % keep the old Chi2 parameter
        chi2(j) = chi2(j-1);
    end;
end;  % end of loop over chain using nchain



  







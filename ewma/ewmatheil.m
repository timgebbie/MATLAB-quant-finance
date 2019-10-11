function [theil]=ewmatheil(varargin)
% EWMATHEIL Theil indicators of forecast predictability
%
% [U] = EWMATHEIL(YHAT,YTILDE) Construct the Theil indicators for model 
% simulation and estimation evaluation. The required inputs are the 
% estimated time-series YHAT (ex-ante) and the measured time-seres YTILDE. 
% The output are the Theil indicator, U, the Theil bias, UM, the 
% Theil varance US and UC the theil covariance : U  = [U,UM,US,UC]. 
%
% [EWMAU] = EWMATHEIL(YHAT,YTILDE,LAMBDA) LAMBDA is the forgetting 
% factor, LAMBDA=0.9999 recovers usual defintion. The output are the 
% EWMA estimators of the Theil indicator, U, the Theil bias, UM, the 
% Theil varance US and UC the theil covariance, and the conventional 
% estimators: EWMAU = [U,UM,US,UC] using EWMA estimators.
%
% Notes: 
%
% U - THEIL indicator 0 < U < 1; here 1 implies that the predictive
%     performance of the model is bad. U=0 implies that the predictive
%     performance is perfect.
% 
%   sigma_h = sqrt(E[(yhat-E[yhat])^2])  (forecasted standard deviation)
%   sigma_t = sqrt(E[(ytilde-E[ytilde])^2]) (measured standard deviation)
%   rho     = (1/(sigma_h sigma_t)) E[(yhat-E[yhat])(ytilde-E[ytilde])]
%   MSE    = E[(yhat-ytilde)^2] (root-mean square error)
%
%   U = sqrt(MSE)/( E[yhat^2] + E[ytilde^2] )
%   
%   (bias)       UM = ( E[yhat] - E[ytilde] )^2 / MSE
%   (variance)   US = ( sigma_h - sigma_t )^2 / MSE
%   (covariance) UC = ( 2 (1-rho) sigma_h sigma_t ) / MSE
%
% UM - BIAS : indication of systematic errors it measures the 
%   extent to which the average values of forecasted deviate 
%   from measured. UM close to 0 indicates a good model and
%   close to 1 and very poor model.
%
% US - VARIANCE : indication of the ability of the model to 
%   replicate the degree of variability in the variable of 
%   interest. Large US indicates the measured fluctuates
%   more than the forecasted. High US is troubling.
%
% UC - COVARIANCE : indication of the non-systematic errors as 
%   it represents the remaining error after deviations from 
%   the average have been accounted for.
%
%   Good models UM=US=0 and UC=1; Bad models UM=US=1 and UC=0 
% 
% UM + US + UC = 1
%
% See Also: EWMACOV

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $

% page 384-389 Pindyck, R., S., Rubinfeld, D.,L., Econometric Models
% and Econometric Forecasts 4-th edition 1998
%

switch nargin
    case 2
        yhat = varargin{1};
        ytilde = varargin{2};
        if (isempty(yhat) | isempty(ytilde)), theil=[]; return; end;
        
        % CONVENTIONAL INDICATORS
        % mean square error
        x = (yhat-ytilde).^2;
        % theil indicator
        u = sqrt(mean(x)) / (sqrt(mean(yhat.^2)) + sqrt(mean(ytilde.^2)));
        % bias
        um = (mean(yhat) - mean(ytilde))^2 / mean(x); 
        % variance
        sh = std(yhat);
        st = std(ytilde);
        us = (sh - st)^2 / mean(x);
        % covariance
        [v,r] = cov2corr(cov(yhat,ytilde));
        if sum(size(r))==2
            warning('Cannot compute theil covariance');
            theil = [u,um,us,NaN];
        else
            uc = (2*(1-r(1,2)) * sh * st) / mean(x);
            theil = [u,um,us,uc];
        end
        return;
        
    case 3
        yhat = varargin{1};
        ytilde = varargin{2}; 
        if (isempty(yhat) | isempty(ytilde)), theil=[]; return; end;
        lambda = varargin{3};
        % remove nan data
        i=isnan(ytilde) + isnan(yhat);
        pi=find(i==0);
        % keep non NaN data
        yhat = yhat(pi); 
        ytilde = ytilde(pi);
        % get the root-mean square error 
        [rmse,mse] = ewmarmse(yhat,ytilde,lambda);
        % get the root mean squares 
        rmsh    = sqrt(ewmamean(yhat.^2));
        rmst    = sqrt(ewmamean(ytilde.^2));
        % the correlation, variance and mean
        [r,v,m] = ewmacorr([yhat ytilde],lambda);
        % find the standard deviations
        sh = sqrt(v(1));
        st = sqrt(v(2));
        % find the means
        mh = m(1);
        mt = m(2);
        % EWMA INDICATORS
        % find theil indicator
        eu = rmse / (rmsh + rmst);
        % find the bias measure
        eum = (mh - mt)^2 / mse;
        % find the variance measure
        eus = (sh - st)^2 / mse;
        % find the correlation measure
        euc = (2 * (1-r(1,2)) * sh * st) / mse;
        ewmatheil=[eu,eum,eus,euc];
        % remap the output
        theil = ewmatheil;
        
    otherwise
        error('Incorrect Input Arguments');
end




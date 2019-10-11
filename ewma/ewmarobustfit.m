function [b, Q, stats] = ewmarobustfit(varargin)
% EWMAROBUSTFIT Adaptive (EWMA) recursive robust regression
%
% [B, Q, STATS] = EWMAROBUSTFIT(X,Y) Given the Input matrix X and the 
% output vector Y, the coefficients B are identified coefficients. The 
% first coefficient is constant bias.  Q is the weighted inner product 
% of the inputs (w(LAMBDA)*X)'(w(LAMBDA)*X). STATS is the output 
% statistics from the robust regression algorithm. See ROBUSTFIT for 
% help. The weighting function used it the  'bisquare' function, the 
% tuning constant used is 4.685. 
%
% The algorithm carries out a weighted regression of the form:
%
%  w(LAMBDA) * Y = w(LAMBDA) * X * B 
%
% to find the co-efficients B, and the fitting statistics STATS. The
% weight inner product Q is provided as it is required for the recursive
% implementation.
%
% [B, Q, STATS] = EWMAROBUSTFIT(X,Y,LAMBDA) Use user forgetting factor 
% LAMBDA as a number between 0 and 1.
%
% [B1, Q1, STATS] = EWMAROBUSTFIT(X,Y,B0,Q0) Uses default LAMBDA to
% recursively update the model without down-weighting outliers. 
% 
% The algorithm iteratively updates the model:
%
%  Q1 = LAMBDA^2*Q0  + (1-LAMBDA)^2*(X'*X)
%  B1 = inv(Q1)*(LAMBDA^2*Q0*B0 + (1-LAMBDA)^2*(X'*Y))
%
% [B1, Q1, STATS] = EWMAROBUSTFIT(X,Y,LAMBDA,B0,Q0) Recursively update the 
% model without down-weighting outliers with user defined LAMBDA.
%
% [B1, Q1, STATS1] = EWMAROBUSTFIT(X,Y,LAMBDA,B0,Q0,STATS0) Recursively 
% update the model down-weighting of outliers as per the robust fitting
% M-estimation implemented in robustfit with 'bisquare' weighting functions
% and a tuning constant of 4.685. The recursive algorithm is only 
% implemented for the particular weighting scheme.
%
% It iteratively updates the robust fitting algorithm:
% 
%   TUNE = 10
%   E0   = Y - X*B0
%   S    = SQRT(VAR(e))/0.6745
%   H    = 1 - R2
%   R    = E0/(TUNE*S*SQRT(1-H))
%   WTS  = (ABS(R)<1) .* (1 - R.^2).^2
%
% So finding the forgetting factor (EWMA) updated out-lier down-weightings
%
%   LAMBDA_WTS   = 1-WTS*(1-LAMBDA)
%
% The algorithm iteratively updates the model:
%
%   Q1 = LAMBDA_WTS^2*Q0  + (1-LAMBDA_WTS)^2*(X'*X)
%   B1 = inv(Q1)*(LAMBDA_WTS^2*Q0*B0 + (1-LAMBDA_WTS)^2*(X'*Y))
%
% See Also : EWMAWEIGHTS, ROBUSTFIT

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $

% Author: Tim Gebbie 

% Developer notes: Some of the algorithm was implemented based on ideas
% discussed with J. Solms and A. Beaven in 1999-2001. Similar 
% implementatios exist elsewhere. A key innovation is the idea to 
% recursively adapt the the co-efficient as new information arrives, this 
% provides significant improvements in algorithm implementation speed. It 
% does however limit the fitting to bi-square weighting.

% the default forgetting factor
lambda = 0.98;

switch nargin
    case 2
        % Default input case 
        [b, Q, stats] = ewmarobustfit(varargin{1},varargin{2},lambda);
        
    case 3
        % ADAPTIVE ROBUST REGRESSION
        lambda = varargin{3};
        % Default lambda
        if isempty(lambda), lambda = 0.98; end;
        % Missing lambda
        if length(lambda) ~= 1, error('Lambda must be a scalar.'); end;
        % Inputs
        X      = varargin{1};
        X      = [ones(size(X,1),1) X];
        % Outputs
        y      = varargin{2};
        % Get the window weights for the correct length for the data set
        w = ewmaweights(length(y),lambda);
        % Window the data with the EWMA weights
        Xw = X .* repmat(w, 1, size(X,2));
        yw = y .* repmat(w, 1, size(y,2));
        % Carry out the robust M-estimation regressions
        % ---------------------------------------------
        [b,S] = robustfit(Xw, yw, 'bisquare', 4.685, 'off');
        % ---------------------------------------------
        % Update the inner product of the inputs
        Q  = transpose(Xw)*Xw;
        % Find the estimated output (prediction if delayed)
        yhat = X*b;
        % Find the innovations
        u = y - yhat;
        % find the EWMA covariance that are consistent in lambda
        [var_u,  mean_u ] = ewmacov(u, lambda);
        [var_y,  mean_y ] = ewmacov(y, lambda);
        [var_yyhat,  mean_yyhat] = ewmacov([y yhat], lambda);
        % Compute prediction goodness statistics
        % In sample R-squares
        R2  = 1 - var_u./var_y;
        % Keep the fitting statistics
        stats.mean_u        = mean_u;
        stats.var_u         = var_u;
        stats.mean_y        = mean_y;
        stats.var_y         = var_y;
        stats.mean_yyhat    = mean_yyhat;
        stats.var_yyhat     = var_yyhat;
        stats.R2            = R2;
        stats.mean_b        = repmat(transpose(b), size(y,1), 1);
        stats.var_b         = repmat(diag(S.se.*S.se), [1, 1, size(y,1)]);
        % t-Statistics for the co-efficients
        for i = 1:size(stats.var_b,3),
            K = (stats.var_u(:,:,i) * Q);
            stats.t(i,:) = transpose(b ./ sqrt(diag(K)));
        end;

    case 4
        % Default input case 
        [b, Q, stats] = ewmarobustfit(varargin{1},varargin{2},lambda,varargin{3},varargin{4});
        
    case 5
        % ADAPTIVE RECURSIVE REGRESSION
        lambda = varargin{3};
        % Default lambda
        if isempty(lambda), lambda = 0.98; end;
        % Missing lambda
        if length(lambda) ~= 1, error('Lambda must be a scalar.'); end;
        % Inputs
        X      = varargin{1};
        X      = [ones(size(X,1),1) X];
        % Outputs
        y      = varargin{2};
        % Previous model state
        b0     = varargin{4};
        Q0     = varargin{5};
        % get input data set size
        [p,q] = size(X);
        % ensure that there is only one input at a time for the model to 
        % be recursive
        if p ~= 1, 
            error('Recursion only allows one input measurement vector'); 
        end;
        % Fitting algorithm for the adaptive recursive updating
        % -----------------------------------------------------
        b = lambda^2*Q0*b0 + (1-lambda)^2*X'*y;
        Q = lambda^2*Q0  + (1-lambda)^2*X'*X;
        b = inv(Q)*b;
        % -----------------------------------------------------
        stats = [];

    case 6
        % ADAPTIVE RECURSIVE ROBUST REGRESSION
        lambda = varargin{3};
        % Default lambda
        if isempty(lambda), lambda = 0.98; end;
        % Missing lambda
        if length(lambda) ~= 1, error('Lambda must be a scalar.'); end;
        % Inputs
        X      = varargin{1};
        X      = [ones(size(X,1),1) X];
        % Outputs
        y      = varargin{2};
        % Previous model states
        b0     = varargin{4};
        Q0     = varargin{5};
        stats  = varargin{6};
        % Get the last last values of the fitting statistics for next iteration
        stats.mean_u        = stats.mean_u(end ,:);
        stats.var_u         = stats.var_u(:,:,end);
        stats.mean_y        = stats.mean_y(end ,:);
        stats.var_y         = stats.var_y(:,:,end);
        stats.mean_yyhat    = stats.mean_yyhat(end ,:);
        stats.var_yyhat     = stats.var_yyhat(:,:,end);
        stats.R2            = stats.R2(:,:,end);
        stats.mean_b        = stats.mean_b(end ,:);
        stats.var_b         = stats.var_b(:,:,end);
        stats.t             = stats.t(end ,:);
        % get input data set size
        [p,q] = size(X);
        % ensure that there is only one input at a time for the model to 
        % be recursive
        if p ~= 1, 
            error('Recursion only allows one input measurement vector'); 
        end; 
        % Fitting algorithm for the adaptive recursive updating
        % -----------------------------------------------------
        % Compute de-weighting of outliers
        tune = 4.658;
        % find the residuals
        e0 = y - X*b0;
        % line 138 stats.statrobustfit
        % standard deviation estimate
        s = sqrt(stats.var_u) / 0.6745;
        % correlation is required
        h = 1-stats.R2;
        % find the weight adjusted residuals
        r = e0/(tune*s*sqrt(1-h));
        % bi-square weighting scheme (Alternative weighting schemes can be
        % added here if required - see weight function line 162 - 191
        % stats.statrobustfit
        w = (abs(r)<1) .* (1 - r.^2).^2;
        % EWMA weighting of weighting scheme
        lw = 1-w*(1-lambda);
        % Update the Fit with new weighting factors
        b = lw^2*Q0*b0 + (1-lw)^2*X'*y;
        Q = lw^2*Q0  + (1-lw)^2*X'*X;
        % update co-efficients
        b = inv(Q)*b;
        % -----------------------------------------------------
        % Find the estimated output (prediction if delayed)
        yhat = X*b;
        % Find the innovations
        u = y - yhat;
        % find the EWMA covariance that are consistent in lambda
        [var_u, mean_u]         = ewmacov(u, lambda, stats.var_u, stats.mean_u);
        [var_y, mean_y]         = ewmacov(y, lambda, stats.var_y, stats.mean_y);
        [var_yyhat, mean_yyhat] = ewmacov([y yhat], lambda, stats.var_yyhat, stats.mean_yyhat);
        [var_b, mean_b]         = ewmacov(transpose(b), lambda, stats.var_b, stats.mean_b);
        % In sample R-squares
        R2  = 1 - var_u./var_y;
        % Find the t-statistics
        K = (var_u(:,:,end) * Q);
        tb = transpose(b ./ sqrt(diag(K)));
        % Keep the last values for iteration
        stats.mean_u        = mean_u(end ,:);
        stats.var_u         = var_u(:,:,end);
        stats.mean_y        = mean_y(end ,:);
        stats.var_y         = var_y(:,:,end);
        stats.mean_yyhat    = mean_yyhat(end ,:);
        stats.var_yyhat     = var_yyhat(:,:,end);
        stats.R2            = R2(:,:,end);
        stats.mean_b        = mean_b(end ,:);
        stats.var_b         = var_b(:,:,end);
        stats.t             = tb;

    otherwise
        error('Incorrect Input Arguments');
end;


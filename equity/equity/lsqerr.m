function [p,resn,res,eflag] = lsqerr(varargin),
% LSQERR Use the LSQNONLINE function to calibrate the models
%
% [P,RESN,RES,EXITFLAG] = LSQERR(FN,T,YTILDE,P0) Where FN is a function handle 
% and P0 is the initial conditions for the function and YTILDE is the 
% measured data matrix at times in T. Parameter P, the residual norm RESN 
% the residuals RES and the exit flag EXITFLAG.
%
% [P,RESN,RES,EXITFLAG] = LSQERR(FN,T,YTILDE,P0,LB,UB) Where FN is a function 
% handle and P0 is the initial conditions for the function and YTILDE is the 
% measured data matrix at times in T. Parameter P, the residual norm RESN 
% the residuals RES and the exit flag EXITFLAG. Using LB and UB for the 
% parameter feasible region.
%
% Example 1.
%   % parameters ~ (A, B, C, beta, t_c, w, phi)
%   p0 = [3.5,-3,2.27,0.35,2003,7,-14];
%   [p,c] = LSQERR(@logp,t,p0,y);
%
% See Also: LOGP, MC, MCMC

% Author Tim Gebbie

% $Revision: 1.1 $ $Date: 2008/07/01 14:45:58 $ $Author: Tim Gebbie $

% Initial defaults 
lb = []; % upper bounds
ub = []; % lower bounds

switch nargin,
    case 4,
        fn = varargin{1};
        t = varargin{2};
        p0 = varargin{3};
        ytilde = varargin{4};     
    case 6,
        fn = varargin{1};
        t = varargin{2};
        p0 = varargin{3};
        ytilde = varargin{4};
        lb = varargin{5};
        ub = varargin{6};
    case 7,
        fn = varargin{1};
        t = varargin{2};
        p0 = varargin{3};
        ytilde = varargin{4};
        lb = varargin{5};
        ub = varargin{6};
        options = varargin{7};
    otherwise
        error('Incorrect number of input arguments');
end;

if nargin<7,
    % get the option set
    options = optimset('lsqnonlin');
    % modify options
    options.MaxFunEvals = 1000*length(p0);
    options.MaxIter     = 10000;
    options.Display     = 'iter';
    options.TolFun      = 1e-5;
    options.TolX        = 1e-5;
end;
% use lsqnonlin
[p,resn,res,eflag] = lsqnonlin(@(p) reserr(@logp,t,p,ytilde),p0,lb,ub,options);

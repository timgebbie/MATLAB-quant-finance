function e = reserr(FUN,p,t,y),
% RESERRLOGP Is the residual error function between data and model 
%
% ERR = RESERR(FUN,Y) For model data Y and FUN with appropriate 
% parameters. This is typically used in the computation of the 
% mean square error MEAN(SQRT(ERR.^2)) for use in LSQNONLIN.
%
% Example 1:
%   err = reserr(@logp,t,p0,ytilde);
%
% See Also:

% Author: Tim Gebbie

% 1.1 2008/07/01 14:45:33 Tim Gebbie

% compute the difference between the model and measured data
e = feval(FUN,p,t) - y;
function iytm=besaimpytm(valuedate,aip,details)
%BESAIMPYTM Implied yield-to-maturity from All-in-price for BESA Gilt
%   [IYTM] = BESAIMPYTM(VALUE,AIP,DETAILS) Find the implied yield from the
%   AIP.
%
%   See Also: FZERO, BESAAIP

% Copyright 2006 Tim Gebbie, Futuregrowth Asset Management and
%                OPTI-NUM solutions (Pty) Ltd
% $Revision: 1.3 $ $Date: 2006-03-28 15:43:14+02 $
       
% start at the risk-free rate
ytm0 = details.coupon; 
% optimization settings
options = optimset('GradObj','on','Hessian','on');
% optimization that finds the zero of the obective function
[iytm,fEval,exitflag]=fzero(@p2y,ytm0,options,details,aip); 
% check solution
if exitflag>0,
    aip_test = besaaip(valuedate,iytm,details);
    if ~(round((aip_test - aip)*10000)==0),
        error('Unable to find the correct implied YTM');
    end;
else
    error('Unable to find the correct implied YTM');   
end;

%% HELPER FUNCTIONS
% the objective function to find the strike yield given the price
function [objf,g,H]=p2y(x,valuedate,details,aip)
% function being evaluated
f = besaaip(valuedate,x,details); 
objf = f - aip;
% the jacobian (first derivatives - gradient)
fm = besaaip(valuedate,x-0.0001,details);
fp = besaaip(valuedate,x+0.0001,details);
% the gradient of the objective function           
MD = ((fm - fp)/( f * 2 * 0.0001));
 g = MD;
% the hessian (second derivative)
CV = (fp + fm - 2 * f) / ( f * 0.0001 * 0.0001);
 H = CV;
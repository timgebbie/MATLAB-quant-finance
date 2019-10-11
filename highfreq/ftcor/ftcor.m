function varargout = ftcor(varargin)
% FTCORR calculates the correlation of two processes
%
% CORR = FTCORR(p1,p2,N,nrfc,n0)
%
% p1       - [1:N,1:2] time series 1
% p2       - [1:N,1:2] time series 2
% N        - length of time scale
% nrfc     - number of fourier coefficients to be included in estimation
% n0       - number of fourier coefficients that should be emitted
% 
% FTCOR(p1,p2,N,nrfc,n0) calculates the correlation between two processes 
% using the method proposed by Malliavin and Mancino in 
% their paper 'Harmonic analysis 
% methods for nonparametric estimation of volatility'.
%
% See also ftvar.m, ftcovar.m
%
% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: user $
%
% $Author Chanel Malherbe

%assign the input arguments
switch nargin
case 3  
    p1 = varargin{1};
    p2 = varargin{2};
    N =  varargin{3};
    nrfc = round(N/2);
    n0 = 1;
case 4
    p1 = varargin{1};
    p2 = varargin{2};
    N = varargin{3};
    nrfc = varargin{4};
    n0 = 1;
case 5
    p1 = varargin{1};
    p2 = varargin{2};
    N = varargin{3};
    nrfc = varargin{4};
    n0 = varargin{5};
    
otherwise
    error('Incorrect Input Arguments')
end
%preallocate arrays
fca = zeros(2,nrfc);
fcb = zeros(2,nrfc);
%determine the size of the input series p1 and p2
N1 = length(p1); N2 = length(p2);
%rescale the time series from [t1,t2] to [0,2pi]
p1(1:N1,1) = rescale(p1); p2(1:N2,1) = rescale(p2);
%calculate the fourier coefficients of the time series
for s = 1:2
    clear ts; clear p;
    if (s == 1); ts = p1(1:N1,1); N = N1; p = p1; end
    if (s == 2); ts = p2(1:N2,1); N = N2; p = p2; end    
    drift = (p(N,2) - p(1,2))/pi;
    for k = 1:nrfc
        cossin =[cos(k*ts(2:N)) - cos(k*ts(1:N-1)),sin(k*ts(2:N)) - sin(k*ts(1:N-1))];
        fca(s,k) = drift -(1/pi)*(sum(p(1:N-1,2)'*cossin(1:N-1,1)));
        fcb(s,k) = (1/pi)*(sum(p(1:N-1,2)'*cossin(1:N-1,2)));
    end
end
%calculate the integrated volatility and covolatility over the entire time window
covar = (pi^2/(nrfc + 1 - n0))*(sum(fca(1,n0:nrfc).*fca(2,n0:nrfc)) + sum(fcb(1,n0:nrfc).*fcb(2,n0:nrfc)));
var1 =  (pi^2/(nrfc + 1 - n0))*(sum(fca(1,n0:nrfc).*fca(1,n0:nrfc)) + sum(fcb(1,n0:nrfc).*fcb(1,n0:nrfc)));
var2 =  (pi^2/(nrfc + 1 - n0))*(sum(fca(2,n0:nrfc).*fca(2,n0:nrfc)) + sum(fcb(2,n0:nrfc).*fcb(2,n0:nrfc)));  
%calculate the correlation
varargout{1} = covar/(sqrt(var1*var2));
varargout{2} = covar;
varargout{3} = sqrt([var1;var2]);


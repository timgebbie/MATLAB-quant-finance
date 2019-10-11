function [prices,k] = fftcfprc(varargin)
% FFTCFPRC Risk Neutral FFT Option price using Carr-Madan
%
% PHI = FFTCFPRC(P,TYPE) Find the Risk-Neutral option prices for european
% options with parameters P of process type TYPE. This methods uses the
% Carr-Madan formulae and Simpsons Rule. This methods is suited for 
% Monte Carlo and Calibration problems that required fast robust pricing.
%
% Table 1: Supported Types
% +------+----------------------------------+---------------------------+
% | TYPE | Description                      | parameters                |
% +------+----------------------------------+---------------------------+
% | bs   | Black-Scholes (E)uropean         | P=[prc,rfr,dy,sig,t0]     |     
% | vg   | Variance Gamma (E)               | P=[prc,rfr,dy,w,t0,c,g,m] |
% | bsga | Black-Scholes Gamma (E)          |
% | hest | Heston (E)                       |
% | vgmc | Variance Gamma Mean-Correct (E)  |
% +------+----------------------------------+---------------------------+
%
% Examples 1:
%
% See Also: 

% Author : Tim Gebbie 2006

switch nargin
    case 2
        p    = varargin{1};
        type = varargin{2};
        % grid variables
        n = 4096;
        a = 1.5; % compute optimal alpha
        e = 0.25;
    case 5
        p    = varargin{1};
        type = varargin{2};
        % grid variables
        n = varargin{3};
        a = varargin{4};
        e = varargin{5};
    otherwise
        error('Incorrect Input Arguments');

end

% PARAMETERS
prc = p(1); % price
rfr = p(2); % risk free rate
dy  = p(3); % dividend yield
t0  = p(5); % maturity

% THE GRID
% make the variance gride
v = 0:e:(n-1)*e;
% make the strike gride
% \lambda \eta = 2 * pi / N
lambda = 2 * pi / n / e;
% \lamba = 2 b / N
b = (lambda * n) / 2;
% strike grid
k = [-b:lambda:b-lambda];

% CARR-MADAN FORMULAE
% risk neutral discounting factor
cm0 = exp(-rfr * t0);
% scaling factor determined by european pay-off function
cm1 = (a^2 + a - v.^2 + i * (2 * a + 1) .* v);
% combined with the characteristic function
cmf = (cm0 ./ cm1) .* rnfftcf(v-(a+1)*i,p,type);

% INTEGRATION USING SIMPSONS RULE CORRECTION
% simpson rule correction (else use de = 1)
% de = (3 + (-1).^(1:n) - [1,zeros(1,n-1)])/3;
% faster version
de = (3 + (-1).^(1:n)); de(1) = 1; de = de / 3;
% simpson rule corrected A
aa = exp(i .* v * b) .* cmf .* e .* de;

% discounting (k is the log(K))
prices = (exp(- a * k) ./ pi) .* real(fft(aa));


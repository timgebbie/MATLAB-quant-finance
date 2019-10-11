function phi = rnfftcf(u,p,type)
% RNFFTCF Risk Neutral Characteristic Functions for FFT evaluation
%
% PHI = RNFFTCF(U,P,TYPE) Find the Risk-Neutral characteristic functions
% for range of prices U and parameters P of process type TYPE.
%
% Table 1: Supported Types
% +------+----------------------------------+-----------------------+
% | TYPE | Description                      | parameters            |
% +------+----------------------------------+-----------------------+
% | bs   | Black-Scholes (E)uropean         | P=[prc,rfr,dy,sig,t0] |              
% | bsga | Black-Scholes Gamma (E)          |
% | hest | Heston (E)                       |
% | vgmc | Variance Gamma Mean-Correct (E)  |
% +------+----------------------------------+-----------------------+
%
% Examples 1:
%
% See Also: 

% Author: Tim Gebbie 2006

switch lower(type)
    case 'bs'
        % Black-Scholes parameters
        prc = p(1); % price
        rfr = p(2); % risk free rate
        dy  = p(3); % dividend yield
        sig = p(4); % volatility
        t0  = p(5); % maturity
        % Black-Scholes RN CF
        u1  = log(prc) + (rfr - dy - sig.^2/2) .* t0;
        u2  = - 0.5 * sig .^2 * t0 .* u.^2;
        phi = exp(i .* u .* u1) .* exp(u2); 
        
    case 'vg'
        % Variance Gamma parameters
        prc   = p(1); % price
        rfr   = p(2); % risk free rate
        dy    = p(3); % dividend yield
        omega = p(4); % volatility (sigma^2 -theta^2 nu
        t0    = p(5); % maturity
        c     = p(6); % C : controls kurtosis
        g     = p(7); % G : G<M negative skew, G>M positive skew
        m     = p(8); % M : G=M mean=0, skew=0
        % Variance Gamma RN CF
        u1  = log(prc) + (rfr - dy - omega) .* t0;
        u2  = ((g * m) ./ (g * m + (m - g) * i .* u + u .^2)) .^ (c .* t0);
        phi = exp(i .* u .* u1) .* u2;
        
    case 'bsga'
        % Black-Scholes Gamma Variance
        
    case 'hest'
        % Heston parameters
        prc   = p(1); % price
        rfr   = p(2); % risk free rate
        dy    = p(3); % dividend yield
        sig0  = p(4); % volatility
        t0    = p(5); % maturity
        kappa = p(6); % rate of mean-reversion
        eta   = p(7); % long term volatility
        lambda= p(8); % vol of the vol
        rho   = p(9); % correlation
        % ensure that  2 kappa eta > lambda^2
        if ~(2 * kappa * eta > lambda^2), error('condition: 2 \kappa \eta > \lambda^2 failed'); end;
        % Heston (pg 118)
        u1 = log(prc) + (rfr - dy) .* t0;
        u2 = eta * kappa * lambda ^(-2);
        d  = sqrt((rho * lambda .* u * i - kappa).^2 - lambda^2 *( - i .* u - u .* u));
        g2 = (kappa - rho * lambda * i .* u -d) .* (kappa - rho * lambda * i .* u + d);
        u3 = ((kappa - rho * lambda * i .* u - d).* t0 - 2 .* log((1 - g2 .* exp(- d .* t0))./(1-g2)));
        u4 = sig0^2 * lambda ^(-2) * (kappa - rho * lambda * i .* u -d).*(1-exp(- d .* t0)) ./ ( 1- g2 .* exp(-d .* t0));
        % uses phi_2 (second cut - not the principle cut form numerical reasons)
        phi = exp(i .* u .* u1) .* exp(u2 .* u3) .* exp(u4);
        
    case 'vgmc'
        % VGMC Parameters (VG-CIR)
        prc   = p(1); % price
        rfr   = p(2); % risk free rate
        dy    = p(3); % dividend yield
        sig   = p(4); % volatility
        t0    = p(5); % maturity
        nu    = abs(p(6)); %
        th    = p(7); % 
        % Variance Gamma Mean-Correcting 
        u1 =log(prc)+rfr.*t0+(t0./nu).*log(1-th.*nu-sig.^2.*nu./2);
        u2 =exp(i.*u*u1);
        u3 =1-i.*th.*nu.*u+(sig.^2.*nu./2).*u.^2;
        %phi = u2 .* u3.^(-t./nu); (discrete)
        phi  = u2 .* exp(log(u3)*(-t0./nu));
        
    case {'vgsv','vgcir'}
        % Variance Gamma Stochastic Volatility (CIR model)
        
        
    otherwise
        error('Unrecognized process type');
end;
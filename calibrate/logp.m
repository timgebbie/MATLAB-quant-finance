function y = logp(t,p),
% LOPG Log-periodic precursor fitting functions
%
% Y = LOGP(T,[A,B,C,BETA,TC,OMEGA,PHI]) 
%
% See Also: MCMC

% 1.1 2008/07/01 14:45:33 Tim Gebbie

% The parameters
A   = p(1);
B   = p(2);
C   = p(3);
beta = p(4);
tc  = p(5);
w   = p(6);
phi = p(7);

% The log-periodic precursor function
y = real(A + B.*(tc-t).^(beta) + C.*((tc-t).^(beta)).*(cos(w.*log(tc-t) - phi)));
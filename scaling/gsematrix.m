function p=gsematrix(s)
% GSEMATRIX Distribution of eigenvalues
%
% P = GSEMATRIX(S)
%
% P(s) = (2^18/3^6 pi^3) s^4 exp(- 64/9 pi s^2)
%
% See Also:

% $ Author Tim Gebbie

p = ((2^18)/(3^6 * pi^3)) .* (s .^4 ) .* exp( -(64 / (9*pi)) .* s .^ 2);
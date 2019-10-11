function [p,x]=porterpdf(s),
% PORTERPDF Porter-Thomas PDF
%
% [P,X]=PORTERPDF(X) one-parameter Porter-Thomas PDF
%
%  P(X) = 1 /sqrt(2 pi) exp( - s^2/2)
%
% See Also : POISSONPDF, BRODYPDF

% $ Author Tim Gebbie

p = 1 / ( 2 * pi)^0.5 * exp( - 0.5 * s.^2);


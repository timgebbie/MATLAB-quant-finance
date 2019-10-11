function [p,x]=wignersurmise(s),
% [P,X]=WIGNERSURMISE(A,B,X) The Wigner Surmise for nearest-neighbours
%
%  P(X) = (pi s /2) exp(- (pi/2)s^2)
%
% See Also : POISSONPDF

% $ Author Tim Gebbie

p = (pi / 2) .* s .* exp( - (pi/4) .* s.^2);


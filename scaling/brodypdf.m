function [p,x]=brodypdf(a,b,s),
% BRODYPDF The Brody PDF
%
% [P,X]=BRODYPDF(A,B,X) one-parameter brody PDF
%
%  P(X) = a ( 1 + b ) x^b exp( - b s^(1+b))
%
% See Also : poissonpdf.m

% $ Author Tim Gebbie

p = a. ( 1 + b) .* x .^b .* exp( - b .* s.^(1+b));


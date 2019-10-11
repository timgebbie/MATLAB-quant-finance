function I = ipratio(V,k)
% I = IPRATIO(V,K) Inverse Participation Ratio
%
% V - eigen-vector
% K - power
%
% K = 4 is typical. The reciprocal of the number 
% of eignevector components that contribute 
% significantly.

% $ Author Tim Gebbie

I = sum(V.^k);

I=I(:);
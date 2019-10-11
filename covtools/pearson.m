function c=pearson(x)
% PEARSONS COEFFICIENT
%
% C_ij= x^T_i x_j / sqrt(x_i^2 x_j^2).
%

% $ Author Tim Gebbie

c = x' * x;
v = diag(c);
n = sqrt(v * v');
c = c ./ n;
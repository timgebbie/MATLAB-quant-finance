function [C,N,I]=nancov(x)
% NANCOV Covariance of NaN filled matrix
%
% C=NANCOV(X)

% $ Author Tim Gebbie

% Not NaNs index
I = double(~isnan(x));
% Compute the count without NaNs
N=(I'*I);
% convert NaNs to zeros so that they are ignored in multiplication operations
xo = x;
xo(~I) = 0;
% mean matrix where mean i'th is computed for use with j'th data row
M = (xo'*I)./N;
% Sums of squares matrix ignoring NaNs in both i'th and j'th data columns
Z = xo'*xo;
%Covariance
C = (Z - N.*M.*M')./(N-1);

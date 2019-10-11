function [x]=zeroorderhold(x)
% ZEROORDERHOLD Zero-order hold extrapolation
%
% XHAT = ZEROORDERHOLD(X) X is M by N matrix the columns are extrapolated
%   using zero-order holds where the NaN values take on the preceeding
%   non-NaN values.
%
% See Also: HPFILTER, KALMANF1

% 1.2 2009/05/28 11:40:51 Tim Gebbie

% Loop through each column then each row
[n,m]=size(x);
for i = 1:n % row
    for j = 1:m % columns
        if isnan(x(i, j)) & (i ~= 1) %#ok
            % If NaNs populate the first elements, leave them alone.
            x(i, j) = x(i-1, j);
        end
    end
end
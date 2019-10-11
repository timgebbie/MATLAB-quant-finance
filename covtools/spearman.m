function s = spearman(x)
% SPEARMAN Rank order correlation matrix 
%
% S = SPEARMAN(X) For data matrix X. Spearman Rank Correlation Coefficient 
% is a nonparametric (distribution-free) rank statistic proposed by 
% Spearman in 1904 as a measure of the strength of the associations 
% between two variables. The Spearman rank correlation coefficient is a 
% measure of monotone association that is used when the distribution of 
% the data make Pearson's correlation coefficient misleading
%
% See Also : PEARSON, KENDALL, SIGNRANK, TIEDRANK, RANKSUM

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:12 $ $Author: Tim Gebbie $

% find the size of the data
[n,m] = size(x);
% find the spearman correlation
for i = 1:m,
    % find the statistical ranks
    ri = tiedrank(x(:,i));
    for j = 1:m,
        % find the statistical ranks
        rj = tiedrank(x(:,j));
        % find the difference between the statistical ranks
        d = ri(:) - rj(:);
        % find the spearman co-efficient
        s(i,j) = 1 - (6 / n * (n^2 -1)) * (d' * d);
    end; % j
end; % i


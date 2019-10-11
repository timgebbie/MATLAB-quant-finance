function varargout = autocorr1(varargin);
% AUTOCORR1 finds the autocorrelation function from time-series data
%
% [AC, M , SD] = AUTOCORR(X) For autocorrelations AC
% means M, standard deviations SD
%
% See Also : POWER

% Author: Tim Gebbie, Diane Wilcox

% Copyright(c) 2004 Tim Gebbie & Diane Wilcox, University of Cape Town.
% $Revision: 1.1 $ $Date: 2009/04/28 06:55:12 $ $Author: Tim Gebbie $

switch nargin
case 1
    y = varargin{1};
    x = y;
case 2
    y = varargin{1};
    x = varargin{2};
otherwise
    error;
end

[n, m] = size(y);

% z-score the data
y = (y - repmat(nanmean(y),n,1));
x = (x - repmat(nanmean(x),n,1));

% normalization constant
Nc = sum(y .* x);

% find the auto correlation function
for i=1:n-1
    y1 = y(1:(n-i),:);
    y2 = x(i+1:(n),:);  
    % correctly normalized with respect to degrees of freedom
    AC(i,:) = sum(y1 .* y2) ./ Nc;
end

% output variables tranpose to ensure columns are objects and
% rows are the delays
M  = nanmean(AC');
SD = sqrt(nanstd(AC').^2);
    
switch nargout,
case 0;      
case {1,2,3},
    varargout{1} = AC;
    varargout{2} = M;
    varargout{3} = SD;   
otherwise
    error('incorrect number of output arguments');
end
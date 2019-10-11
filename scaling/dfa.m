function [e,f,t] = dfa(x)
% DFA Detrended fluctuation analysis of time-series data
%
% [E,F,T] = DFA(X) for a matrix X the detrended fluctuation 
% analysis is carried out. For each column in X an exponent is computed. 
% Exponent E, fluctuation F and box size T. NaN values are set to zero 
% rather than ignored.
%
% See Also:

% Author: Tim Gebbie 31-09-2004

% 1.1 2008/07/01 14:51:18 Tim Gebbie

[m,n]=size(x); t = 2:m; 
% remove rows with NaNs
x(isnan(x))=0;
% de-mean the data
x = x - repmat(mean(x),size(x,1),1);
% normalize
x = x ./ repmat(std(x),size(x,1),1);
% wrap the data to deal with fitting all box sizes
x = [x; flipud(x)];
% 1. find the cumulative sum
x = cumsum(x);
% add on window for those that do not fit
nj = floor(m ./ t) + double(abs(mod(m,t))>0);
% loop through objects
for i=1:n,
  % loop through boxes of equal size by wrapping the data
  for j=t,
    % break each column into matrices of length window
    yf = reshape(x(1:nj(j-t(1)+1)*j,i),j,nj(j-t(1)+1));
    % linearly detrend data in window
    dty = detrend(yf);
    % detrended fluctuations as time-series RMS
    f(j-t(1)+1,i) = sqrt(mean(dty(:).^2));
  end; % for t
  % ln(<f2>) = a + b ln(t) <=> <f2> ~ t^b
  % remove zero fluctuations
  y = log(f(:,i));
  X = [ones(m-t(1)+1,1), log(t(:))];
  % find the exponent for the time-series
  a(:,i) = regress(y,X);
end; % for i
% the exponent
e = a(end,:);

function [h,c,rs,t]=hurst(varargin);
% HURST Find the hurst exponent for matrix P
%
% [H,INTH,RS,N]=HURST(P) Find the hurst exponent for matrix P
% use RS or MRS accumulated data ranges. The Hurst exponent H
% for each column in P is given with the associated 95% CI for
% the exponent in INTH. 
%
%    ln(H(N))= a + H ln(N) <=> H(N) = c N^H
%
% Here we use the rescaled range
%
%     H(N) = (R/S)_N
%
% See Also : DFA, VARIANCE

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:51:18 $ $Author: Tim Gebbie $

switch nargin
case 1
  p = varargin{1};
  scaling = 'standard';
  % truncation lag
  q = 1; 
case 2
  p = varargin{1};
  scaling = varargin{2};
  % truncation lag
  q = 1;
case 3
  p = varargin{1};
  scaling = varargin{2};
  q = varargin{3};
otherwise
  error('Incorrect input arguments');   
end
% find the maximum window size
[m,n]=size(p); 
% remove the NaN's
p(isnan(p))=0;
% find the maximum window size
[m,n]=size(p);
% warnings off
ws = warning('off');
% initialize window 
w0 = Inf; 
% initialize counter
jj = 1;

% CLASSIC METHOD
% find the accumulated deviations in the independent and 
% non-over lapping sub-periods by iterative division
for j=1:floor(m/2), % window size divisor
   % construct the independed non-overlapping windows
   [w,idx] = windows(m,j);
   % skip repeat windows
   if ~(w==w0),
        % loop through the columns
        for i=1:n,
            % loop through windows
            for k=1:length(idx),
                % find the windowed data mean recursively
                d = mean(p(idx{k},i)) - p(idx{k},i);     
                % find the detrended data on the scale n
                x = cumsum(d);
                % find the range upto tau
                r(k) = range(x);
                % find the normalization scaling upto tau
                v = variance(d,q,scaling);
                % set the scaling normalization
                if v==0,
                    s(k) = NaN;
                else
                    s(k) = sqrt(v);
                end;
            end; % loop across the windows k
            % find the rescaled range as a function of tau
            rs(jj,i) = nanmean(r ./ s);
            % the window size
            t(jj) = w;
            % update window counter
            w0 = w;
        end; % next i
        % increment counter
        jj = jj + 1; 
   end; % if no repeat window
end; % next j : loop through the windows size divisor
    
for j=1:n,    
    % find the inputs
    y = log(rs(:,j));
    x = log(t(:));
    % constraints
    [coeff,cint] = regress(y,[ones(size(x)) x]);
    % save the outputs
    h(j)=coeff(2);
    c(:,j)=cint(2,:)-h(j);
end; % end loop across the stocks

 % return warning state
 warning(ws);
 
 %% HELPER FUNCTIONS
 function [w,idx] = windows(m,j),
 % IDX = WINDOWS(M,J) M is length of data, J is number
 % of windows required.
 
 % find the window size
 w = round(m/j);
 if j==1, 
    % total span of data
    idx{1} = 1:m; 
 else
    % initial window
    idx{1} = [1:w]; 
    % find the second last termination value
    r = j-(min(find((1:j)*w > m))-1);
    if isempty(r), r=1; end;
    % for more than one window
    for k=2:j-r, idx{k} = (k-1)*w+1:k*w; end;
    % if the remainder is greater
    if mod(m,j)<w
        % the last window
        idx{j} = (j-r)*w+1:m;
    else
        idx{j-r} = (j-r)*w+1:min(max(j*w,m),m); 
    end
 end; % end-if
function [beta, pstat] = dickeyfuller(x),
% DICKEYFULLER co-integration coefficients for matrix X
%
% COEFF = DICKEYFULLER(X) Get the auto-regressive parameter COEFF.
%
% [COEFF,STATS] = DICKEYFULLER(X) Get the auto-regressive parameter
% and compute the fitting statistics using Newey-West.
%
% [COEFF,STATS] = DICKEYFULLER(X,TYPE) Get the auto-regressive parameter
% and compute the fitting statistics using Newey-West. Type of statistic
% can either be 'DF' or 'ADF', for Dickey-Fuller the TYPE is an integer 
% taken to be the lag order.
%
% Example 1: No cointegration
%       dx = randn(50,2);
%        y = cumsum(dx);
%   [a,pa] = dickeyfuller(y);
%
% a  =   0      -0.1295
%       -0.1900  0
%
% pa =   NaN    -1.8144
%       -2.4913  NaN
%
% Example 2: Co-integration
%        z = [y(:,1) + dx(:,2), y(:,1)];
%   [a,pa] = dickeyfuller(z);
%
% a =  0       -0.8561
%     -0.8249   0
%
% pa = NaN    -6.0141
%     -5.8433  NaN
%
% See Also: HURST, DFA, CORR

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:51:18 $ $Author: Tim Gebbie $

switch nargin
    case 1
        x = varargin{1};
        type = 'DF';
    case 2
        x = varargin{1};
        if isnumeric(varargin{2}),
            type = 'ADF';
            lagk = varargin{2};
        else
            error('Second argument must be numeric');
        end;
    otherwise
        error('Incorrect Input Arguments');
end

%% COMPUTE THE DICKEY-FULLER STATISTIC
     lagn  = 1;
     % size of the data set
     [n,m] = size(x); 
     % Not NaNs index
     I = double(~isnan(x));
     % convert NaNs to zeros so that they are 
     % ignored in multiplication operations
     x(~I) = 0;
     % find the covariance
     rho   = x' * x;
     % beta matrix
     b     = repmat(1./diag(rho)',m,1) .* rho;
     % de-factor the data row by row
     for i=1:m,
         for j=1:m,
            % select the statistic type
            switch type
                case 'DF',    % Dickey-Fuller
                    u            = x(:,i) - x(:,j) .* b(i,j);
                    du           = diff(u,lagn);
                    lu           = u(1:end-lagn,:);
                    beta(i,j)    = lu \ du; 
                case 'ADF',   % Augmented Dickey-Fuller
                    for k=1:lagk,
                        lu = [lu lag(du,k)];
                    end;
                    beta(i,j) = detrend(lu) \ detrend(du) ;
                otherwise
            end
            % compute statistics if nargout required
            if nargout>1,
                 % -> from phillips.m : James P. LeSage
                 r = detrend(du)- detrend(lu) * beta(i,j); 
                 rss = r'*r;
                 sigma = rss/(size(du,1)-size(lu,2));
                 var_cov = sigma*inv(lu'*lu) ;
                 stdb = sqrt(var_cov(1,1));
                 tstat = beta(i,j)/stdb;
                 % Apply Newey & West (1987) adjustment:
                 nw = rss;
                 cs = fix(4*(n/100)^(1/4));
                 for k = 1:cs,
                     nw = nw + 2*(1-k/(cs+1))*(r(1:end-k)'*r(k+1:end));
                 end;
                 nw = nw/n;
                 pstat(i,j) = sqrt(rss/n / nw) * tstat - 1/2* (nw - rss/n)/sqrt(nw) * n*stdb/sigma;
                 % <- from phillips.m : James P. LeSage
            end;
         end; % for j
     end; % for i
      
 



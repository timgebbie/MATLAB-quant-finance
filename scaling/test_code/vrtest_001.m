function [vr, zq, zsq, q, psisig] = vrtest(varargin),
% VRTEST Variance-Ratio Test
%
% [VR,ZQ,ZSQ,Q,PSISIG] = VRTEST(X,Q) compute the Variance-Ratio as in Eqn. 1 
% below with the lag Q. X is a matrix of log price data. The 
% data can have missing data. 
%
% Following the approach of Lo & MacKinlay 1988.
%
% Example 1.
%
%       x = 0.20 * diff(rand(100,1));
%       [j,m,z] = vrtest(x,2);
%
% Example 2. 
%
%       x = 0.20 * diff(randn(100,2));
%       [j,m,z] = vrtest(x,2);
%
% Example 3.
%
%       x = 0.20 * diff(110,2);
%       x = diff(x(1:100)) + diff(x(10:end)); 
%       [j,m,z] = vrtest(x,[2 4]);
%
% See Also:

% Author: Tim Gebbie, Diane Wilcox

switch nargin
    case 2
        % variance-ratio test
        r = varargin{1}; % return increments from log price
        q = varargin{2}; % lag increments
        
    otherwise
        error('Unrecognized inputs')
end

% number of observations
t = size(r,1);
% MAIN LOOP OVER Q
for qq = q, % loop over delays
    % find nq 
    nq = t-1;
    % find n
    n  = nq ./ q;
    if qq<t
        % compute the q-integrated series R_t(q) for t
        for tt=qq:t, rq(tt,:) = nansum(r(tt-qq+1:tt,:)); end;
        % vr(q)
        vr(qq,:) = (1/qq) .* var(rq) ./ var(r); % variance ratio
        % \bar M_r(q)
        barMrq(qq,:) = vr(qq,:) - 1;
        % homoscedastic normalization
        homonorm = sqrt((2 * (2*qq-1) * (qq-1)) / (3 * qq * t));
        % z(q)
        zq(qq,:) = barMrq(qq,:) ./ repmat(homonorm,1,size(vr,2));
        % initialise 
        theta(qq,:) = zeros(1,size(vr,2)); % FIXME
        % delta(j)
        clear deltaj;
        % FIXM -->
        for j=1:qq-1.
            i = j+1:t;
            delta(j,:) = sum((r(i,:) - repmat(mean(r),t-j,1)).^2 .* (r(i-j,:) - repmat(mean(r),t-j,1)).^2);
            delta(j,:) = delta(j,:) ./ (sum((r -  repmat(mean(r),t,1))).^2).^2;
            % the heteroscedastic normalisation
            heteronorm = ((2.*(qq-j)./qq).^2);
            % theta(q)
            theta(qq,:) =  heteronorm * delta(j,:);
        end;
        % z*(q)
        zsq(qq,:) = sqrt(t) * (barMrq(qq,:) ./ sqrt(theta(qq,:)));
        % < -- FIXME
        psisig(qq,:) = min(normcdf(zsq(qq,:),0,1), 1-normcdf(zsq(qq,:),0,1))*2;
    end
end; % for qq

% reformat output
vr      = vr(2:end,:);
zsq     = zsq(2:end,:);
zq      = zq(2:end,:);
psisig  = psisig(2:end,:);
  
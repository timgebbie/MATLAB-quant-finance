function [nspix] = ntile(varargin)
% NTILE Compute the symmetric N-tiles and index 
%
% [NTIL] = NTILE(X, N) Partitions a MxK matrix X into N parts and 
% provides the index I for each N-tile. NTIL is the same size as 
% X with indices for membership in each N-tile as N. Missing data
% is returned as NaN's. The N-tiles are computed column by column.
%
% [NTIL] = NTILE(X, N, SORT) SORT is either 'ascend' or 'descend'.
%
% [NWTS]  = NTILE(FTS, N, SORT, NUM) NUM is a vector of length N 
% ordered from 1 to N to replace n-tile integers. 
%
% Example 1: 
%  [n] = ntile(rand(23,3), 5)
%
% Example 2:
%  x = rand(23,3);
%  x([floor(rand(5,1)*22)+1 ,floor(rand(5,1)*2)+1])=NaN;
%  [n]=ntile(x,5,[],[0.01 0.005 0 -0.005 -0.01]);
%
% See Also: PRCTILE, QUANTILE, SORT

% Author: Tim Gebbie

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

% RETRIEVE INPUTS
switch nargin
    case 2
        x = varargin{1};
        np = varargin{2};
        so = 'ascend';
        vi = 1:np;
    case 3
        x = varargin{1};
        np = varargin{2};
        so = varargin{3};
        switch lower(varargin{3})
            case 'ascend'
                vi = 1:np;
            case 'descend'
                vi = np:-1:1;
            otherwise
                error('Unrecognized sort direction');
        end
    case 4
        x = varargin{1};
        np = varargin{2};
        so = varargin{3};
        if isempty(varargin{3}), so = 'ascend'; end;
        vi = varargin{4};
        switch lower(so)
            case 'ascend'
            case 'descend'
                vi = flipup(vi);
            otherwise
                error('Unrecognized sort direction');
        end
        if np~=length(vi),
            warning('Weight vector length inconsistent with number of quantiles: reseting number');
            np = length(vi); % CHECK ensure consistency with wieght vector VI
        end
        if nargout > 1, error('This is only allowed with a single output argument'); end;
    otherwise
        error('Incorrect Input Arguments');
end

% SORT DIRECTION

%% SANITY CHECKS
% n must be numeric and contains only one element
if numel(np) ~=1 || ~isnumeric(np),
    error('number of parts must be real integer');
end
% NaN index
nind = isnan(x); 
ni = sum(~nind); 
[n,m]   = size(x);
if n<np, error('Not enough data to ntile'); end;
ps = floor(ni./np); % partition size
pr = rem(ni, ps); % partition residual
% column index
cols = 1:m;
% remove complete NaN columns
if any(ps==0),
  cols = cols(~(ps==0)); 
end
ps = repmat(ps, np, 1); % populate full partition size set
for j=cols, % columns
    if (mod(pr(j),2)==0) & ~(pr(j)==0), % even
        % start at ends and loop inward
        for k=1:pr(j)/2,
            ps([k np-k+1],j) = ps([k np-k+1],j)+1; % add above and below 
        end
    elseif ~(pr(j)==0) % odd
        % start nearest the lower middle
        mp = floor(np/2)+1;
        ps(mp,j) = ps(mp,j)+1;
        % start in middle and loop outwards
        for k=1:(pr(j)-1)/2,
            ps([mp+k mp-k],j) = ps([mp+k mp-k],j)+1; % add above and below
        end
    else
        % do nothing
    end
end
% sort the data
[y,sind]=sort(x);
% invert the sorting index
for i=cols, for j=1:n, isind(sind(j,i),i)=j; end; end;
nspiy = vi(1)*ones(size(x)); % everything in partition 1 
nspiy(isnan(y))=NaN; % populate the NaN's
cps = cumsum(ps); % reference indices
for i=2:np,
    for j=cols
        nspiy(cps(i-1,j)+1:cps(i,j),j) = vi(i); % assign output index
        nspix(:,j) = nspiy(isind(:,j),j);
    end
end

% EOF
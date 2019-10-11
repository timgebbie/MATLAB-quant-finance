function [b r] = momwts(varargin) 
% MOMWTS/TECHNICAL Momentum to controls algorithm 
%
% [B I] = MOM2WTS(P,W,NORM,T,RS) Find the controls B for the next 
%   trading increment given the window size W, the index of the last 
%   trading increment T, historical sequence of market prices P. Matrix X 
%   has time as rows and stocks as columns i.e. Time x Entity. There are M 
%   stocks. NORM is by default TRUE to normalize weights to ONE, if FALSE 
%   weights are normalised to zero. RS is the returns to be used for attribution 
%   if this does not conform with the return of prices P. Typically this 
%   is empty or ignored, if P is smoothed then for attribution purposes RS 
%   will be the raw returns. I is the price index using the price P if no
%   RS is provided else RS is used.
%
% Example 1: Long-only at a single date-time
%     >> p = [ones(1,3); cumprod(exp(0.03*randn(10,3) + 0.01))];
%     >> [b1] = mom2wts(p,5,true)
%
% Example 2: Long-only sequence with initial BH conditions
%     >> p = [ones(1,3); cumprod(exp(0.03*randn(10,3) + 0.01))];
%     >> [b1] = mom2wts(p,5,true)
%
% Example 3: Long-short
%     >> p = [ones(1,3); cumprod(exp(0.03*randn(10,3) + 0.01))];
%     >> [b1] = mom2wts(p,w,false)
%     
%   See also: 

%   Author: Tim Gebbie, Raphael Nkomo, QT Capital Management

% /CVSRepo/MATLAB/toolboxes/technical/functions/mom2wtsr.m,v 1.0 2008/07/11 10:56:42 Tim Gebbie Exp

%% Required data inputs
p = varargin{1}; % window size
w = varargin{2}; % last trading time-date
[n,m] = size(p);
tn=1:n-1;    % the time index
norm = true; % long-only (true) and long-short (false)
dir = +1;    % direction flag (+1 mean-reversals -1 for momentum)
type = 'Simple';
bias = []; % default bias is zero
leverage = 1; % default leverage is one

%% 0. Compute relative log-prices (returns)
x = tick2ret(p,[],type);
% repeated returns
ridx=transpose((sum(transpose((x==0)))==size(x,2)));
% compounding
switch type
    case 'Simple'
        x = (1+x); 
    case 'Continuous'
        x = exp(x); % was exp(x)
    otherwise
end
% remove NaN
x(isnan(x)) = NaN;
% remove Inf
x(isinf(x)) = NaN;
% zscore the returns
z0 = nanzscore(x);
% remove repeats
% FIXME x(ridx,:) = NaN;
rS = x; % attribution returns

%% Input arguments
switch nargin
    case 2    
    case 3
        if islogical(varargin{3}), norm = varargin{3}; end;
        
    case 4
        if ~isempty(varargin{3}) & islogical(varargin{3}), norm = varargin{3}; end;
        tn = varargin{4}; % market price sequence
        [n,m] = size(p);
        if isempty(varargin{4}), tn=1:n-1; end;
             
    case 5
        if ~isempty(varargin{3}) & islogical(varargin{3}), norm = varargin{3}; end;
        if ~isempty(varargin{4}),  tn = varargin{4}; end;  % market price sequence
        if all(size(varargin{5})==size(x)), rS = varargin{5}; else error('rS dimensions incorrect'); end;
        
    otherwise
        error('Incorrect Input Arguments');
end

%% 1. Loop over time
for t=tn
    % 0. return the current portfolio if t < 2 w
    if t >= 2*w, % Inside the moving window
        % 1. Compute the average return (z-scored) for a given window and 
        % and the weight the stocks by this return to compute weights.
        m0 = ((z0(t,:)+1)./(z0(t-w,:)+1))-1;
        % 2. Z-score in cross-section
        b0 = transpose(nanzscore(transpose(m0)));
        % 3. weight by rank-auto-correlation 
        for icol=1:size(m0,2)
            c0(icol) = (1/w) * nansum(sign(z0(t-w+2:t,icol)) .* sign(z0(t-w+1:t-1,icol)));
        end
        c0 = nanzscore(c0);
        % 4. compute the score keeping only positive values
        c0(c0<0) = 0; 
        % 5. compute the new portfolio proportions
        b(t+1,:) = b0 .* c0;
        % renormalize weights to correct for missing data residuals
        if norm
            % 1. re-normalize to one
            b(t+1,:) = b(t+1,:) ./ nansum(b(t+1,:));
            % 3. re-bias if necessary
            b(t+1,:) = bias * b(t+1,:);
        else
            % long and short index
            lnidx = (b(t+1,:)>0);
            snidx = (b(t+1,:)<0);
            % all none zero weights
            nznidx = lnidx | snidx;
            if sum(nznidx)==0
                b(t+1,:) = b(t,:);
            else
                % initial bias
                bias0 = nansum(b(t+1,:));
                % 1. re-normalize to zero
                b(t+1,nznidx) = b(t+1,nznidx) - (1/sum(nznidx)) * bias0;
                % 2. re-leverage
                b(t+1,:) = epsclean(leverage * b(t+1,:) ./ sum(abs(b(t+1,:))));
                % 3. re-bias
                % b(t+1,lnidx) = b(t+1,lnidx) + (1/sum(lnidx)) * bias;
                % b(t+1,snidx) = b(t+1,snidx) - (1/sum(snidx)) * bias;
            end
        end
    end
end

%% post-process for output compatible with online functionality
b(isnan(b))=0;
% FIXME if ~isempty(find(ridx)), b(find(ridx)+1,:)=NaN; end;
if length(tn)==1, 
    b = b(tn+1,:); 
    r = NaN * b; 
else
    r = NaN * zeros(size(b));
    if ~isempty(rS), 
        % note that rS is a price relative => return = rS - 1
        xret = rS - 1;
        % must exclude the last control for which no return is avaliable
        % control b(n) at time n is invested at time n-1 for return
        % computed from n-1 until n. r(n) = sum_i b(n,i) * r(i,n)
        r = ret2tick(transpose(nansum(transpose(b(tn,:) .* xret(tn,:)))),[],[],[],type); 
    end;
end


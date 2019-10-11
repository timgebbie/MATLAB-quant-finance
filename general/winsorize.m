function [wx,b,ui,li] = winsorize(varargin),
%  WINSORIZE Trim vectors using winsorization.
%
%  [WX,B] = WINSORIZE(X) Winsorize the data in the matrix 
%  X by columns. The truncation is at 2 times the standard deviation.
%  The recursive winsorization is convergent in the standard deviation of
%  each column in X to Tol = 1e-2. Winsorize takes the non-missing values 
%  of a variable and generates a new variable identical except 
%  that the H highest and H lowest values are replaced by the next 
%  value counting inwards from the extremes.  B is the truncation 
%  boundary for each column and WX is the winsorized matrix of data.
%  his transformation is named after the biostatistician C.P. Winsor. 
%  WX is in the order that it was inputed.
%
%  [WX,B] = WINSORIZE(X,P) P is the amount of Winsorization as a function 
%  of the standard deviation. The default value of P is 2.
%
%  [WX,B] = WINSORIZE(X,P,TYPE) TYPE is either 'percentage' for percentage, 
%  'standard' for multiple of the standard deviation or 'median' where the  
%  distribution is around the median. The default value of 
%  type 'standard' is P = 2. H can be specified directly or indirectly by 
%  specifying a fraction P of the number of observations: H = [P N]. 
%  Typical values of H are 0.2 for TYPE 'percentage'.
%
%  [WX,B] = WINSORIZE(X,P,TYPE,CONV) Winsorize the data in the matrix 
%  X by columns. P is the amount of Winsorization as a function of 
%  the standard deviation.  The logical flag CONV determines whether or 
%  not to iteratively truncate until the boundary converges or not.
%
% [WX,B,UI,LI] = WINSORIZE(X,P,TYPE,CONV) Here UI is the index to where
% the data was changed on the upper boundary. LI is the index to where
% the data was changed on the lower boudary. The non-zero values are the
% boundary values used and zeros are unchanged data.
%
% [WX,B,UI,LI] = WINSORIZE(X,P,TYPE,CONV,CST) To substitute boundary
% values for particular data points for particular columns in WX. CST is
% an integer valued matrix of the dimension of X where it takes on values
% +1, 0 and -1 to respectively denote, using upper boundary, do nothing 
% and use the lower boundary value actions on WX.
%
%  Example 1: Winsorize at 4.5 standard deviations :
%       wx = winsorize(x,4.5,'standard') 
%
%  Example 2: Winsorize 90% or the data :
%       wx = winsorize(x,0.10,'percentage') 
%
%  Example 3: The key refinement is to fit the boundary such that the 
%       boundary is convergent, CONV is 'true' :
%       wx = winsorize(x,4.5,'standard',true);
%
%  Example 4: Change boundary values for particular data points
%       [wx,ulb,ui,li] = winsorize(x,2.5,'standard',true,bv)
%
%  Note that Winsorization is not equivalent to simply throwing 
%  some of the data away. This is because the order statistics 
%  are not independent. 
%
%  See Also: AVERAGE, PEARSON, KENDALL

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

% Defaults
bv = zeros(size(varargin{1}));

switch nargin
    case 1
        if isnumeric(varargin{1}),    x = varargin{1}; else, error('Incorrect Input Arguments'); end;
        tr   = 2;
        type = 'standard';
        conv = true;
        anom = false;
        
    case 2
        if isnumeric(varargin{1}),    x = varargin{1}; else, error('Incorrect Input Arguments'); end;
        if isnumeric(varargin{2}),   tr = varargin{2}; else, error('Incorrect Input Arguments'); end;
        type = 'standard';
        conv = true;
        anom = false;
        
    case 3
        if isnumeric(varargin{1}),    x = varargin{1}; else, error('Incorrect Input Arguments'); end;
        if isnumeric(varargin{2}),   tr = varargin{2}; else, error('Incorrect Input Arguments'); end;
        if isstr(varargin{3}),     type = varargin{3}; else, error('Incorrect Input Arguments'); end;
        conv = true;
        anom = false;
        
    case 4
        if isnumeric(varargin{1}),    x = varargin{1}; else, error('Incorrect Input Arguments'); end;
        if isnumeric(varargin{2}),   tr = varargin{2}; else, error('Incorrect Input Arguments'); end;
        if isstr(varargin{3}),     type = varargin{3}; else, error('Incorrect Input Arguments'); end;
        if islogical(varargin{4}), conv = varargin{4}; else, error('Incorrect Input Arguments'); end;
        anom = false;
        
    case 5,
        if isnumeric(varargin{1}),    x = varargin{1}; else, error('Incorrect Input Arguments'); end;
        if isnumeric(varargin{2}),   tr = varargin{2}; else, error('Incorrect Input Arguments'); end;
        if isstr(varargin{3}),     type = varargin{3}; else, error('Incorrect Input Arguments'); end;
        if islogical(varargin{4}), conv = varargin{4}; else, error('Incorrect Input Arguments'); end;
        if isnumeric(varargin{5}), bv = varargin{5}; else, error('Incorrect Input Arguments'); end;
        if ~((size(bv,1)==size(x,1)) & (size(bv,2)==size(x,2))), error('Incorrect CST Input Argument'); end;
        anom = true;
        
    otherwise
        error('Incorrect Input Arguments');
end

% get the size of the data
[n,m] = size(x);

% INFINITE VALUES IN DATA SET
% look for +Inf and -Inf in the data set 
pinf_i = (x==+Inf);
ninf_i = (x==-Inf);
% If +Inf and -Inf are found in the data set treat as missing data
x(pinf_i) = NaN;
x(ninf_i) = NaN;
% set the anomalous data index -> user provide CTS takes precedence
if nargin<5, bv = +pinf_i - ninf_i; anom=true; end;

% METHODS
% construct the index into the data to be winsorized
switch type
    case 'standard',
        % find the standard deviation
        nsx = tr * nanstd(x);
        % find the mean (Could use median)
        mx  = nanmean(x);
        % find the lower bounds
        xbot = mx - nsx;
        xbot = repmat(xbot,n,1);
        % find the upper bounds
        xtop = mx + nsx;
        xtop = repmat(xtop,n,1);
        
    case 'percentage',
        % sort the data into ascending order wx = x(sortindex)
        [wx, sindx] = sort(x);
        % find the top and bottom values
        ibot = floor(tr*n)+1;
        itop = length(wx)-ibot+1;
        xbot = wx(ibot,:);
        xbot = repmat(xbot,n,1);
        xtop = wx(itop,:); 
        xtop = repmat(xtop,n,1);
        % find the index into the top values
        wx = unsort(wx,sindx);
        
    case 'median',  
        % find the median
        mx  = nanmedian(x);
        % find the mean absolute deviation 
        nsx = tr * mad(x, 1);
        % find the lower bounds
        xbot = mx - nsx; % mean absolute deviation about median
        xbot = repmat(xbot,n,1);
        % find the upper bounds
        xtop = mx + nsx;
        xtop = repmat(xtop,n,1);

    otherwise
        error('Unrecognized Winsorization type');
end

% TRUNCATION
% use index to truncate the bottom
bindx = ((x-xbot)<=0);
x(bindx) = 0;
li = bindx .* xbot;
wx = x + li;

% use index to truncate top
tindx = ((wx-xtop)>=0); 
wx(tindx) = 0;
ui = tindx .* xtop;
wx = wx + ui;

% the boundary term
b = [xtop(1,:);xbot(1,:)];

% IF CONVERGENCE on the boundary is required
if conv,
    % convergence tolerance
    tol  = 1e-2;
    % initialize difference between standard deviations
    sy12 = ones(1,m);
    % initialize standard deviation
    sy2  = nanstd(wx);
    % the while loop to ensure that we have a convergent boundary
    while mean(sy12) > tol,
        ci       = find(sy12>tol); % sort index
        sy1      = sy2; % update the last iterations values
        % ----------------> ITERATING THE BOUNDARY TERMS
        [wx(:,ci),b(:,ci),ui(:,ci),li(:,ci)] = winsorize(wx(:,ci),tr,type,false); % winsorize again
        % <----------------
        sy2      = nanstd(wx); % second winsorizations standard deviation
        sy12     = abs(sy1-sy2); % error terms
    end; % while tol
end; % if

% IF ADDITIONAL DATA SUBSTITUTION IS REQUIRED
if anom,
    % separate the upper bounds from the lower bounds
    ubv = bv;
    ubv(bv<0) = 0; % upper bound matrix
    bv(bv>0) = 0; % lower bound matrix
    % re-create the boundary objects
    xtop = repmat(b(1,:),n,1);
    xbot = repmat(b(2,:),n,1);
    % the index to the data that is to be changed
    uid = (abs(ubv)>0);
    lid = (abs(bv)>0);
    % clear the data that is to be changed 
    wx(uid) = 0;
    wx(lid) = 0;
    % the change indices
    ui2 = xtop .* uid;
    li2 = xbot .* lid;
    % change the data
    wx = wx + ui2;
    wx = wx + li2;
    % change the upper and lower index
    ui = ui + ui2;
    li = li + li2;
end; % if anom

% Helper Functions:

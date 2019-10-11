function z = nanzscore(varargin)
% NANZSCORE Standardized z score.
%
%   Z = NANZSCORE(X) returns a centered, scaled version of X, known as the Z
%   scores of X.  For a vector input, Z = (X - MEAN(X)) ./ STD(X).  For a
%   matrix input, Z is a row vector containing the Z scores of each column
%   of X.  For N-D arrays, ZSCORE operates along the first non-singleton
%   dimension.
%
%   Z has sample mean zero and sample standard deviation one.  ZSCORE is
%   commonly used to preprocess data before computing distances for cluster
%   analysis.
%
%   Z = NANZSCORE(X,MEAN_TYPE) For MEAN_TYPE either 'mean' or 'median' for 
%   the numerator.
%
%   Z = NANZSCORE(X,MEAN_TYPE,SPREAD_TYPE) For SPREAD_TYPE either 'std' or
%   'mad' for the denominator.
%
% Example: Z = nanzscore(x,'median','mad');
%
%   See also NANMEAN, NANVAR, NANCOV, PDIST, CLUSTER, CLUSTERDATA.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1 $  $Date: 2008/07/01 14:51:18 $

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:51:18 $ $Author: Tim Gebbie $

switch nargin
    case 1
        x = varargin{1};
        center_type = 'mean';
        spread_type = 'std';
    case 2
        x = varargin{1};
        center_type = varargin{2};
        spread_type = 'std';
    case 3
        x = varargin{1};
        center_type = varargin{2};
        spread_type = varargin{3};
    otherwise
        error('Incorrect input arguments');
end

% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = []; return; end

% Figure out which dimension sum will work along.
sz = size(x);
dim = find(sz ~= 1, 1);
if isempty(dim), dim = 1; end

% Need to tile the output of mean and std to standardize X.
tile = ones(1,ndims(x)); tile(dim) = sz(dim);

% Compute X's mean and sd, and standardize it.
warn = warning('off','MATLAB:divideByZero');

% the de-meaning
switch center_type,
    case 'median',
        xbar = repmat(nanmedian(x), tile);
    case 'mean',
        xbar = repmat(nanmean(x), tile);
    otherwise
        error('Unrecognized center of distribution');
end

% the normalization
switch spread_type,
    case 'std',
        sd = repmat(nanstd(x), tile);
    case 'mad',
        sd = repmat(mad(x, 1), tile);
    otherwise
        error('Unrecognized spread of distribution');
end

warning(warn)
sd(sd==0) = 1; % don't try to scale constant columns
z = (x - xbar) ./ sd;

function ewts=ewmaweights(varargin)
%EWMAWEIGHTS Generates a suite of exponential windows, each of increasing length.
%
%    W = EWMAWEIGHTS(MAXLENGTH) Generates a column vector of
%    exponential window weights of MAXLENGTH. The weights
%    increase exponentially down the rows and always sum to one.
%
%    W = EWMAWEIGHTS(MAXLENGTH, LAMBDA) Same as above but take LAMBDA above the
%    default of 0.98
%
%    W = EWMAWEIGHTS(MAXLENGTH, LAMBDA, N) Generates a matrix of column vector
%    exponential window weights of MAXLENGTH rows by N columns. The first
%    column will have the top element non-zero and equal to one. Each following
%    column will have a sequence of non-zero weights one longer than the column
%    to its left.
%
%    W = EWMAWEIGHTS(MAXLENGTH, LAMBDA, N, ILENGTH) Generates a matrix of
%    column vector exponential window weights of MAXLENGTH rows by N columns.
%    The weights increase down the columns and always sum to one. N is the
%    number of windows and MAXLENGTH is the maximum length of the windows.
%    ILENGTH is the initial length of the first (leftmost) window. Each window
%    column vector has a length one greater than the vector to its left.
%
%    Example:
%
%        w = ewmaweights(6, [], 5, 3)
%
%        w =
%
%            0.3266    0.2425    0.1920    0.1584    0.1584
%            0.3333    0.2474    0.1959    0.1616    0.1616
%            0.3401    0.2525    0.1999    0.1649    0.1649
%                 0    0.2576    0.2040    0.1683    0.1683
%                 0         0    0.2082    0.1717    0.1717
%                 0         0         0    0.1752    0.1752
%
%        s = sum(w)
%
%        s =
%
%                1     1     1     1     1
%
%    Also see 

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $

% Default Lambda
lambda = 0.98;

switch nargin
case 1
    ell= varargin{1};
    w  = 1;
    p  = ell;
case 2
    ell     = varargin{1};
    if ~isempty(varargin{2}), lambda  = varargin{2}; end;
    w  = 1;
    p  = ell;
case 3
    ell     = varargin{1};
    if ~isempty(varargin{2}), lambda  = varargin{2}; end;
    w       = varargin{3};
    p  = ell;
case 4
    ell     = varargin{1};
    if ~isempty(varargin{2}), lambda  = varargin{2}; end;
    w       = varargin{3};
    p       = varargin{4};
otherwise
    error;
end

if p > ell, error('ILENGTH > MAXLENGTH'); end;
if p < 1, error ('ILENGTH < 1'); end;
if lambda == 1, error('LAMBDA = 1'); end;

ewts=[];
for i=1:w

if (ell-(p-1)-i)>0
% get the length
  index = (p-1)+i:-1:1;
else
  index = ell:-1:1;
end
% generate the weight vector
  wts = lambda .^ index(:);
% condition the series
  wts = (1-lambda) * wts(:);
% m_normalize the weights
  wts = wts ./ sum(wts);

  if (ell-(p-1)-i)>0
  % pad with zeros
      new_column = [wts; zeros((ell-(p-1))-i,1)];
  else
      new_column = wts;
  end
% build the matrix
  ewts = [ewts, new_column];
end;


function v=variance(varargin);
% VARIANCE Compute different types of variance
%
% V = VARIANCE(X,Q,TYPE) For data X lag Q and type TYPE.
%
% Allowed types TYPE : 
%   'standard'       Usual sample estimator
%   * 'hanson_hodrick' Hansen-Hodrick MA variance 
%   'newey_west'     Newey-West AR and MA variance
%
% The lag order is Q
%
% * not yet implemented

switch nargin
case 1
    x = varargin{1};
    q = 1;
    type = 'standard';
    
case 2
    x = varargin{1};
    q = varargin{2}; 
    type = 'standard';
    
case 3
    x = varargin{1};
    q = varargin{2};
    type = varargin{3};
    
otherwise
    error('Incorrect input arguments');
end

% get the size
[n,m]=size(x);
% demean r
x=x-repmat(nanmean(x),n,1); 

switch type
case 'standard'
  v = sum(x .* x) ./ (n-1);

case 'newey_west',
    
  % reset the lag of the data is to short  
  q = min(q,n-1);
  % the lag index
  j = 1:q;
  % initialize g
  g=ones(0,m);
  % find the auto correlation function
  for i=j, g(i,:) = sum(x(1:(n-i),:) .*  x(i+1:n,:),1) ./ n; end;
  % find the sample variance
  v = sum(x .* x) ./ (n-1);
  % find the scaling factor omega
  w = repmat(1 - j(:) / (q+1),1,m);
  % find the corrected variance
  v = v + 2 * sum(w .* g,1);
    
otherwise
    error('Unrecognized variance type');
end



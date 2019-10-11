function varargout = cleancov(varargin)
% cleancov Find the clean covariance matrix using density of eigenvalues.
%
%   [CLEANSIGMA,LAMBDAmax,LAMBDAmin] = cleancov(A) 
%  
%   Find the clean covariance matrix of A using the
%   density of eigenvalues for a N observations (rows) M securities (columns) as
%   input -- uses the large M random matrix density of eigenvalues to find the 
%   min and max random eigenvalues, this subspace is then flatterend.
%
%   A is a matrix of data
%   CLEANSIGMA Clean Covariance Matrix
%   LAMBDAmax  Upper Cut-Off
%   LAMBDAmin  Lower Cut-Off
%

% $Author: Tim Gebbie $

% "Theory of Financial Risk" 2000 Bouchaud&Potter pg 120

switch nargin
 case 1 % input c_fin_array of m_returns
  % input data array
  a=varargin{1};
  
  % the number of data points    (length) N 
  % and the number of securities (width)  M
  [N,M] = size(a);
  Q = N/M; % quality ratio

  covariance = cov(a);   % the c_portfolio covariance

  % find the eigenvalues and vectors fo the covariance matrix
  [V,D,s]=condeig(covariance);

  pvar = mean(diag(D));   % the average eigenvalue of the covariance matrix

  % upper and lower random matrix eigenvalues
  lambdamax = pvar * ( 1 + (1/Q) + 2 * sqrt(1/Q));
  lambdamin = pvar * ( 1 + (1/Q) - 2 * sqrt(1/Q));

  density=[];

     eind=[];
  for i=1:size(covariance,1) % find the sub-matrix to be excluded
     D(find(abs(D)<1000*eps))=0;
   if D(i,i) < lambdamax
     eind = [eind;i];
   end
  end

   nl=length(eind);
  if ~isempty(nl)
    total = trace(D(eind,eind)); % trace to be perserved
    coeff = total / nl;
    D(eind,eind)=coeff * eye(nl,nl); % the new submatrix
  end

   cleansigma = V * D * inv(V);
   cleansigma(find(abs(cleansigma) < 1000 * eps))=0;

 case 2  % input c_fin_array of m_returns and lambda to find density
        a = varargin{1};
  lambdac = varargin{2};
  
 % the number of data points    (length) N 
 % and the number of securities (width)  M
  [N,M] = size(a);
  Q     = N/M; % quality ratio

  % find the sample covariance
  covariance= cov(a);
  [V,D,s]   = condeig(covariance);
  pvar      = mean(diag(D));

  % upper and lower random matrix eigenvalues
  lambdamax = pvar * ( 1 + (1/Q) + 2 * sqrt(1/Q));
  lambdamin = pvar * ( 1 + (1/Q) - 2 * sqrt(1/Q));

  % density of eigenvalues
  density   = ( Q / 2 * pi * pvar) * sqrt( (lambdamax - lambdac) * (lambdamin-lambdac))/ lambdac;
  cleansigma=[];

end

switch nargout
case 0
    display(cleansigma);
case 1
    varargout{1}=cleansigma;
case 3
    varargout{1}=cleansigma;
    varargout{2}=lambdamax;
    varargout{3}=lambdamin;
case 4
    varargout{1}=cleansigma;
    varargout{2}=lambdamax;
    varargout{3}=lambdamin;
    varargout{4}=density;
otherwise
    error
end
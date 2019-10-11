function cleansigma = cov2clean(varargin)
% COV2CLEAN convert covariance matrix to a clean covariance matrix
%
% C = COV2CLEAN(SIGMA,Q)
%
% N is the degrees of freedom
% SIGMA is the covariance matrix
%
% see cleancov

% $ Author Tim Gebbie

    covariance = varargin{1};
    Q = varargin{2};
    
% number of securities
  M = length(covariance);
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
   

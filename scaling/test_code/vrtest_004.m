function [vr, psi, psisig] = varratio(P,Q)
%VARRATIO Heteroskedasticity-consistent variance ratio evaluation for any q spacing
%
% [VR, PSI, PSISIG] = VARRATIO (P, Q) performs heteroskedasticity-consistent variance-
%   ratio tests using overlapping observations for each spacing q defined in Q on time
%   series P, and returns the corresponding result vectors
%
%   VR     = the variance ratios
%   PSI    = the test statistics, and
%   PSISIG = the significance levels at which each H0: VR = 1 (indicating a random walk)
%            is rejected against H1: VR <> 1.
%            (Assumes NaN if the MATLAB Statistics Toolbox is not installed).
%
%   P must be strictly positive and in levels, and
%   Q must be a vector of integers (in any order) greater than 1 (default is 2).
%   (See also the NOTE at the bottom of the script.)
%
% The author assumes no responsibility for errors or damage resulting from usage. All
% rights reserved. Usage of the programme in applications and alterations of the code
% should be referenced. This script may be redistributed if nothing has been added or
% removed and nothing is charged. Positive or negative feedback would be appreciated.

%                     Copyright (c) 23 March 1998 by Ludwig Kanzler
%                     Department of Economics, University of Oxford
%                     Postal: Christ Church,  Oxford OX1 1DP,  U.K.
%                     E-mail: ludwig.kanzler@economics.oxford.ac.uk
%                     Homepage:      http://users.ox.ac.uk/~econlrk
%                     $ Revision: 1.11 $$ Date: 27 September 1998 $

% Check input arguments/assign default:
if sum(P <= 0)
   error('All elements of the time series must be strictly positive.')
end

if nargin < 2
   Q = 2;
elseif Q~= round(Q) | sum(Q < 2)
   error('Spacing can only be specified by integers greater than 1.')
end

% The idea of the variance-ratio test is to check whether the variance of random-walk
% increments can be described as a linear function of the time interval (the null
% hypothesis). These increments are simply defined as continuously compounded "returns"
% on the price series (i.e. a time series in levels):
p   = log(P(:));
r   = p(2:end) - p(1:end-1);
obs = length(p);

% Compute the variance-ratio statistics for each q contained in Q:
i = 0;
for q = Q
   i = i + 1;

   % Define n such that (the total number of price) obs. = nq + 1
   % (so n defines the number of non-overlapping q-spaced returns):
   n = fix((obs-1)/q);

   % The unbiased sample mean (also maximum likelihood) estimator of r is given by:
   mu = (p(n*q+1) - p(1)) / (n*q);

   % The unbiased sample variance (also maximum likelihood) estimator of r is defined as:
   ssa = r(1:n*q)' * r(1:n*q);
   sa  = ssa / (n*q-1);

   % The alternative unbiased estimator of the sample variance of r using the sum of
   % q-period over-lapping returns is computed as follows:
   dev = p(q+1:n*q+1) - p(1:n*q-q+1) - q*mu*ones(n*q-q+1,1);
   sc = dev' * dev / (q*(n*q-q+1)*(1-1/n));

   % And one thus obtains the variance ratio:
   vr(i) = sc / sa;

   % The heteroskedasticity-consistent estimator of the variance of VR is th/(n*q):
   th = 0;
   for k = 1 : q-1
      th = th + 4*(1-k/q)^2 * n*q / ssa^2 * ...
            ((r(k+1:n*q) - mu*ones(n*q-k, 1)).^2)' * (r(1:n*q-k) - mu*ones(n*q-k, 1)).^2;
   end

   % Then, the standardised test statistic is given by:
   psi(i) = sqrt(n*q) * (vr(i) - 1) / sqrt(th);

end

% Since the test statistic follows a N(0,1) distribution, its level of significance is
% easily evaluated:
if exist('normcdf.m','file') & nargout == 3
   psisig      = min(normcdf(psi,0,1), 1-normcdf(psi,0,1))*2;
elseif nargout == 3
   psisig(1:i) = NaN;
end

% End of function.

% NOTE:
%
% This script's procedure uses the theoretical exposition of Campbell, Lo & MacKinlay,
% 1997, pp. 48-55, which unsurprisingly follows Lo & MacKinlay (1988, 1989). The code
% adopts their notation as far as possible, but as the lowest index number in MATLAB is,
% of course, 1 (not 0), all indices are shifted up by 1. Also, while Campbell et al.
% (1997) arbitrarily restrict possible values of q to multiples of the smallest value 2
% (presumably for computational convenience), q can take the value of any integer greater
% than 1 in this implementation. Of course, this requires not only sc and psi to be
% functions of q, but also mu and sa (so their computation is part of the loop).

% REFERENCES:
%
% Campbell, John, Andrew Lo & Craig MacKinlay (1997), "The Econometrics of Financial
%    Markets", Princeton University Press, Princeton, New Jersey
%
% Lo, Andrew & Craig MacKinlay (1988), "Stock Market Prices Do Not Follow Random Walks:
%    Evidence from a Simple Specification Test", Review of Financial Studies, vol. 1,
%    no. 1, pp. 41-66
%
% Lo, Andrew & Craig MacKinlay (1989), "The Size and Power of the Variance Ratio Test in
%    Finite Samples: A Monte Carlo Investigation", Journal of Econometrics, vol. 40,
%    pp. 203-238

% End of file.

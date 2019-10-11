% Scaling Analysis Toolbox
% Version 1.1 (R2006a) 31-Jul-2006 
%
% General information.
%   Comprises functions to model scaling and aperiod signals
%
% General Functions:
%   hurst         - estimate hurst exponents
%   dfa           - estimate dfa exponents
%   dickeyfuller  - cointegration auto-regression coefficients
%   nanzscore     - z-score data by mean or median
%   wignersurmise - The Wigner distribution of eigenvalues
%   variance      - compute newey-west variance
%   porterpdf     - Porter-Thomas PDF
%   poissonpdf    - Poisson PDF
%   brodypdf      - Brody PDF
%   ipratio       - Inverse participation ratio
%   epsclean      - remove almost zero values at EPS
%   wishart       - the eigendensity distribution for GRM
%
% To Be Checked
%   unfolding     - Unfold the eigenvalues(ksdensity)
%   unfolding2    - Unfold the eigenvalues 
%   twopoint      - The number of eigenvalues in each interval
%   intnumber     - The number of intervals between eigenvalues
%   nearestnd     - Find the next-nearest neighbourhood distributions (ksdensity)
%   nearestned2   - Find the next-nearest neighbourhood distributions
%   pdfcdf        - Use Guassian broadening to find PDF and CDF (ksdensity)
%   pdfcdf2       - Use Guassian broadening to find PDF and CDF 
%
% To Be Phased Out
%   acorr         - autocorrelation functions
%   integrate     - numerically integrate using the trapezoidal rule
%   gsematrix     - distribution of eigenvalue matrix ????
%   cumintegrate  - cumulative numercal integration
%
% Test Code
%   scaling_test_001    - test code library to audit system functionality.
%   eigenmode_test_001  - the eigenmode analysis
%
% Obsolete functions.
%   eigendensity  - Analytic estimated eigenvalue density
%
% Others
%   None at this time
%
% GUI Utilities.
%   None at this time.

%   Copyright 2001-2006 Diane Wilcox, Tim Gebbie, University of Cape Town

% Terms and Conditions of Use
%
% THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER 
% EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
% THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS 
% WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF 
% ALL NECESSARY SERVICING, REPAIR OR CORRECTION. 
%
% IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY OTHER 
% PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THIS SOFTWARE, BE LIABLE TO 
% YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR 
% CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE 
% PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING 
% RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A 
% FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF 
% SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
% DAMAGES. 

% $Revision: 1.1 $ $Date: 2008/07/01 14:51:18 $ $Author: Tim Gebbie $



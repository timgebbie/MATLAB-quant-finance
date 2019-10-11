% Exponentially Weighted Moving Average Toolbox
% Version 1.0 (R14) 01-Nov-2004 
%
% Copyright (C) 2004 Tim Gebbie, Diane Wilcox, University of Cape Town
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
%
% General information.
%   Comprises functions to implement exponential weighted moving averages
%
% General Functions:
%    ewmaweights   - EWMA weight matrix
%    ewmavar       - EWMA variance vector
%    ewmarobustfit - EWMA adaptive robust regression (online)
%    ewmamean      - EWMA mean vector
%    ewmatheil     - EWMA theil indicators
%    ewmarmse      - EWMA root-mean-square-errors
%    ewmamse       - EWMA mean-square-errors
%    ewmacov       - EWMA covariance matrix arrays
%    ewmacorr      - EWMA correlations matrix arrays
%    epsclean      - Clean to numerical accuracy
%
% Test Code
%   ewma_test_001    - test code library to audit system functionality.
%
% Obsolete functions.
%   None at this time.
%
% Others
%   None at this time
%
% GUI Utilities.
%   None at this time.

%   Copyright 2001-2004 Tim Gebbie & Diane Wilcox 
%   (of Futuregrowth Asset Management & University of Cape Town, 
%    respectively)
%
% Terms and Conditions of Use
%
% (1) THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
% EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
%
% (2) THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS 
% WITH THE USER. SHOULD THE PROGRAM PROVE DEFECTIVE, THE USER ASSUMES THE   
% COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION. 
%
% (3) IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY 
% OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THIS SOFTWARE, BE LIABLE 
% TO THE USER FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR 
% CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE 
% PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING 
% RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A 
% FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF 
% SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
% DAMAGES. 

% $Revision: 1.1 $ $Date: 2008/07/01 14:46:06 $ $Author: Tim Gebbie $



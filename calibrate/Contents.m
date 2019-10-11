% Calibration Toolbox 
% Version 1.0 (R14) 01-Jan-2006
%
% Copyright (C) 2004 Tim Gebbie
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%    USA
%
% General information.
%   Comprises tools for the estimate of non-linear parameter fitting and 
%   Fitting statistics. This includes Monte Carol Markov Chain, Monte
%   Carlo and Nonlinear least squares.
%
% Functions
%   mcmc      - mcmc fitting code
%   logp      - function to be fitted
%   lsqerr    - calibrate the model using lsqnonlin.m
%   reserr    - residual error for use in lsqerr
%   lsqerrfit - alternative lsq-err fit written by U. Krichner
%
% Test Code
%   mcmclogp_test_001    - test code library to audit system functionality.
%   lsqerrlog_test_001   - test code examples for the lest square errors
%
% Test Data
%   workspace_zar.mat    - test data for USDZAR crash
%
% Obsolete functions.
%   None at this time.
%
% GUI Utilities.
%   None at this time.

%   Copyright 2001-2004 Tim Gebbie
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

% 1.1 2008/07/01 14:45:33 Tim Gebbie

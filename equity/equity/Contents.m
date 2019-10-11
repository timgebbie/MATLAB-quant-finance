% Equity Model Toolbox
% Version 1.0 (R2006b)
%
% Copyright (C) 2006 Tim Gebbie
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
% Description: Uses the Carr-Madan formulae to price
% options of various characteristic functions. This is
% includes both stochastic volatility and jump models. The 
% emphasis is on Variance Gamma (VG) and Heston type 
% models (HEST).
%
% References: 
% [1.] Schoutens W., (2003) Lévy Processes in Finance, Wiley
%
% The toolbox comprise four distinct components
%   1. ) FFT machinery for pricing using Carr-Madan
%   2. ) Calibration machinery (using the FFT methods)
%   3. ) Monte Carlo machinery for path generation for pricing
%   4. ) Finite Difference PIDE machinery
%
% The approach:
%
% (I) Use vanilla volatility surfaces in conjunction
% with the battery of stochastic volatility and jump models to 
% calibrate the battery of processes. This requires the use of 
% the FFT pricing tools in conjunction with optimizations 
% methods to search for the optimal parameters.
%
% (II) Once the processes have been calibrated to use Monte-Carlo
% to price various exotic options using the paths generated. 
%
% (III) For speed the PIDE methods are recommended these are ideal
% for the pricing of barrier and american options and various
% credit derivative such as credit default swaps.
%
% The models include here are:
%
% VG        - Variance Gamma (pure jump model using Gamma jumps)
% HEST      - Heston (pure stochastic volatility using sqrt vol)
% VGCIR     - Variance Gamma CIR using time-changing volatility
% VGMC      - Variance Gamma with mean-correction (deterministic time)
% BS        - Black-Scholes (benchmark price)
% BSCIR     - Black-Scholes with CIR time-changing volatility
% BSGA      - Black-Scholes with Gamma Volatility
%
% The approach is based on the book of Wim Schoutens
%
% Functions:
%   RNFFTCF   Risk-neutral characteristic functions
%   FFTCFPRC  Price option using Carr-Madan formulae
%   RNPRC     Risk-neutral process for monte-carlo
%   CALIBRATE Calibration functions
%   MCPRC     Monte-Carlo Loop for various process
%   PIDEFD    Partial Integral Differential Equition using finite difference 
%   VGPRCG1G2 Variance Gamma paths using two Gamma jump processes
%   VGPRCTCBM Variance Gamma paths using Time-Changing Brownian Motion
%   VGPRCINTCIR VG-CIR paths
%   HESTPRC   Heston paths
%   HESTMC    Monte-Carlo of Heston model
%
% Testcode
%   fftequity_testcode_001  Demonstrate the FFT pricing
%   calib_testcode_001      Demonstrate Calibration 
%   mc_testcode_001         Demonstrate Monte-Carlo Pricing
%   pide_testcode_001       Demonstrate PIDE pricing
%
% 

% Author : Tim Gebbie 2006 (based on notes of Wim Schoutens)

%   Copyright 2006 Tim Gebbie
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


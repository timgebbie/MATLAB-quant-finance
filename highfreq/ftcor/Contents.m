% Fourier Variance Toolbox 
% Version 1.0 (R14) 13 June 2005 
%
% Copyright (C) 2005 Chanel Malherbe
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
%   Comprises functions to calculate the correlation of two time series using the Fourier
%   method proposed by Malliavin and Mancino
%
% General Functions:
%   ftcorr      - calculate correlation of two time series using the Fourier method
%   removedrift - remove drift
%   rescale     - rescale time series
%
% Test Code
%   ftcorr_test_001_0   - script file testing fourier correlation for irregularly spaced data
%   ftcorr_test_001_1   - script file testing fourier correlation estimator using evenly 
%                         spaced data

% Obsolete functions.
%   None at this time.
%
% Others
%
%   pearson             - function to calculate pearson coefficient
%   gencordata          - function two create correlated time series to be used during testing
%
% GUI Utilities.
%   None at this time.

% Author : Chanel Malherbe

% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: Chanel Malherbe $



% Covariance Toolbox 
% Version 2.0 (R14) 01-Feb-2009
%
% General information.
%   Comprises functions to manipulate, estimate, visualise and refine
%   covariance matrices with particular emphasis on portfolio choice 
%   problems. 
%
% General Functions:
%       adjacency      - distance matrix to adjacency matrix
%       average        - remove market mode for financial data using averaging
%       cleancov       - estimate a guassian noice reduced covariance using SVD
%       oldnancov      - Missing pair-wise data covariance
%       coordinates    - coordinates from minimal spanning tree adj. matrix
%       disjointmstplot - disjoint MST 
%       gamgconfig     - Use GA to solve for Marsili-Giada configuration
%       minspantree    - compute minimal spanning tree from adj. matrix
%       mstcoords      - oordinates from MST adjacency matrix for gplot
%       mstplot        - use gplot to plot MST
%       pearson        - pearson covariance and correlation
%       kendall        - kendal-tau covariance
%       spearman       - pearson covariance and correlation
%       nanspy         - plot missing data
%       distance       - statistical distance functions (extension of stats toolbox function)
%       cov2clean      - remove guassian noise from covariances using SVD
%       epsclean       - remove trailing data to machine precision
%       autocorr1      - legacy autocorrelation function
%       posdef         - factor matrix in positive semi-definite form
%       
% Function to be developed
%       shrink         - shrink covariance matrix to prior distribution
%
% Test Code
%   scripts\cov_test_001     - test code library to audit system functionality.
%   scripts\posdef_test_001
%   scripts\posdef_test_002
%   scripts\minimal_spanning_tree_test 
%   scripts\minimal_spanning_tree_test_2
%   scripts\sectors_test_gamgconfig_002
%
% Obsolete functions.
%   None at this time.
%
% Others
%   None at this time
%
% GUI Utilities.
%   None at this time.

% Copyright(c) 2004 Tim Gebbie & Diane Wilcox, University of Cape Town.  
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
% NO WARRANTY
%
% 11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
% FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
% OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
% PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
% OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
% TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
% PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
% REPAIR OR CORRECTION.
%
% 12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
% WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
% REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
% INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
% OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
% TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
% YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
% PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGES.
%

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:12 $ $Author: Tim Gebbie $



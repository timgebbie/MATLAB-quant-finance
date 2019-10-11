% Sector and States Toolbox
% Version 1.0 (R14) 01-Sep-2005
%
% Copyright (C) 2004  Bongani Mbambiso, Tim Gebbie, Diane Wilcox, University of Cape Town
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
%   Comprises functions to generate clusters of objects using the
%   covariance matrix and a utility function. Clusters are defined by the 
%   their linkaged structure. There are two approaches followed here based 
%   on Giada & Marsili 2002:
%

%   See the matlab LINKAGE, CLUSTER and DENDROGRAM functions for the
%   conventions used here. The linkage structure Z is output of the
%   functions provided here based on the input covariance matrix or
%   correlation matrix. To compute the covariance or correlation matrix use
%   the functions provided in covariance toolbox.
%
% Also Uses: COVTOOLS/AVERAGE, COVTOOLS/SPEARMAN, COVTOOLS/KENDALL
%
% General Functions:
%   energy         - internal energy of a cluster based on number of 
%                    elements and the internal correlation.
%   likelihood     - Likelihood of the configuration based on the number of 
%                    clusters and their internal correlations.
%   determine      - (rm) Clusters by deterministic recursive cluster
%                    merging (principle).
%   parameters     - (rm) Find new clusters parameters from configuration 
%                    and correlations.
%   minimal        - (rm) Find the next deterministic minimal combination 
%                    of clusters.  
%   annealing      - (sa) Find clusters by simulated annealing.
%   configuration  - (sa) Compute the initial configuration structure to be
%                    used with annealing.
%   change         - (sa) Change configuration of lattice using: sweep,
%                    merge and split. 
%   cfsweep        - (sa) Randomly swap pairs of elements between pairs 
%                    of clusters. 
%   cfmerge        - (sa) Randomly merge 2 clusters that have at least two 
%                    elements.
%   cfsplit        - (sa) Split a cluster, with at atleast 4 elements, 
%                    according to the correlation distances of the elments.
%   cfupdates      - (sa) Rearrange and update the temporal update 
%                    variables for a new configuration structure.
%   cfreset        - (sa) Resets the temporal update variables
%   ground         - (sa) Reset the ground state variables of the 
%                    configuration structure.
%   AnalysisOutputs- (sa) Calculate and output analysis variables.
%
% Test Code
%   sectors_test_determine_001.m - deterministic merging with small 
%                                  synthetic data sets.
%   sectors_test_determine_002.m - deterministic merging with large 
%                                  synthetic data sets.
%   sectors_test_annealing_001.m - simulated annealing with small 
%                                  synthetic data sets.
%   sectors_test_annealing_002.m - simulated annealing with large 
%                                  synthetic data sets.
%
% Obsolete functions.
%   None at this time.
%
% Future Development
%   sectors_test_determine_003.m - deterministic merging J203 data sectors
%   sectors_test_determine_004.m - deterministic merging J203 data states
%   sectors_test_annealing_003.m - simulated annealing J203 data sectors
%   sectors_test_annealing_004.m - simulated annealing J203 data states
%                                  
%
% Others
%   (every graph in paper Marsili 2002)
%
% GUI Utilities.
%   None at this time.

% Copyright 2004, Tim Gebbie, (Futuregrowth Asset Management), Diane Wilcox   
% (University of Cape Town)
%
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

% 1.2 2009/02/06 13:11:50 Tim Gebbie



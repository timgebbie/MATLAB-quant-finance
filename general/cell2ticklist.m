function [tl,t] = cell2ticklist(clist)
% CELL2TICKLIST Convert cell string into comma separated list
%
% See also: commalist2cell

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: tgebbie

tl= [clist{1} sprintf('|%s',clist{2:end})];
t = 1:length(clist);
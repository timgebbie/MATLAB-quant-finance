function Y = openstructfts(varargin)
% FINTS/OPENSTRUCTFTS Open structure of FINTS object in workspace variable editor.
%
%    OPENSTRUCTFTS(X) Open structure X of N FINTS objects in workspace variable editor.
%
% See Also: OPENFTS, OPENSTRUCT

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:57 $ $Author: Tim Gebbie $

for i=1:size(varargin{1},2),
   openvar(fts2mat(varargin{1}{i})); 
end
function Y = structmatview(varargin)
% FINTS/OPENFTS Open STRUCT in workspace variable editor.
%
%    OPENFTS(X) Open STRUCT X of N matrices in workspace variable editor.
%
% See Also: STRUCTFTSVIEW

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

for i=1:size(varargin{1},2),
   openvar(varargin{1}{i}); 
end
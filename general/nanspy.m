function nanspy(A)
% NANSPY nanspy plots an image of NaN's.

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

colormap([1 1 1;1 0 0]);
image(isnan(A)*256);


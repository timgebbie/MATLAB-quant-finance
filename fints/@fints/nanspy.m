function nanspy(a)
% FINTS/NANSPY nanspy plots an image of NaN's.

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

da = fts2mat(a,1);
colormap([1 1 1;1 0 0]);
image(isnan(da(:,2:end))*256);
yticks = get(gca,'YTick');
datenums = da(yticks,1);
yticks = cell2ticklist(cellstr(datestr(datenums)));
set(gca,'YTickLabel',yticks);
title(a.data{1});

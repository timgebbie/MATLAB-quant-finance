function c = commalist2cell(s)
%COMMALIST2CELL Convert a comma separated string to a cell string column
%vector.
%
% See also: cell2commalist

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: tgebbie

s1 = strrep(s, ' ', '');
s2 = strrep(s1, ',', ''',''');
s3 = ['{''' s2 '''}'];
c = eval(s3);
c=c';


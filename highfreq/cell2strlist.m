function str = cell2strlist(C)
% CELL2STRLIST Converts a cellstring to a string list
%
% STR = CELL2STRLIST(CELL) CELL is converted into string list LIST. String 
% lists are used by SQL language 'in' clauses.
%
% Example 1: 
%    str = ' ''Code'',''Item'',''Type'' '
%    str = 'Code','Item','Type'
%
% See also: @FDS

% Author: Tim Gebbie 31-09-2004

% $Revision$ $Date$ $Author$

% Create 'where' string from strCode
str = cell2commalist(C);
str = strrep(str, ',', ''',''');
str = ['''' str ''''];
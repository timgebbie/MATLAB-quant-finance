function item = itemtrim(varargin),
% ITEMTRIM Trim item to friendly name size
%
% ITEMTRIM(ITEM) Default with TERM as true. Trim to last blank space
% or ':' and remove trailing blank spaces.
%
% ITEMTRIM(ITEM,TERM) Trim the text items in ITEM from end (beginning)
% of the string for TERM = true (false). The default is true. 
%
% ITEMTRIM(ITEM,CHAR) Trim the given character CHAR removing trailing
% blank spaces and ':'.
%
% ITEMTRIM(ITEM,CHAR,TERM) Trim to from end (beginning) of string
% character CHAR or ':' with TERM as true (false) removal trailing blanks.
%
% Example 1:
%       itemtrim('Capital Asset Pricing Model',true)
%       ans = 'Model'
% Example 2:
%       itemtrim('Capital Asset Pricing Model',false)
%       ans = 'Capital'
%
% See Also: STRTRIM

% Author: Tim Gebbie 01-01-2005

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

switch nargin
    case 1
        item = varargin{1};
        char = ' '; % blank
        trim = true;
    case 2 
        item = varargin{1};
        if islogical(varargin{2}),
            trim = varargin{2};
            char = ' '; % blank
        else
            char = varargin{2};
            trim = true;
        end;
    case 3
        item = varargin{1};
        char = varargin{2};
        trim = varargin{3};
    otherwise
        error('Incorrect Input Arguments');
end

item = cellstr(item);

for i=1:length(item),
    % find the ':' in the name for modified data
    item_ind   = findstr(item{i},':');
    % look for whitespaces and remove these
    item_ind   = [item_ind, findstr(item{i},char)];
    % find the unique entries in item_ind
    item_ind   = unique(sort(item_ind));
    % if there are no whitespace trim the entire string
    if isempty(item_ind), 
        item{i} = strtrim(item{i}); 
    else,
        % remove trailing white spaces
        if trim
            item{i}  = strtrim(item{i}(item_ind(end)+1:end));
        else
            item{i}  = strtrim(item{i}(1:item_ind(1)-1));
        end
    end;
end; % for i
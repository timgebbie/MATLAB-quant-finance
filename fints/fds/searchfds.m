function [e, d] = searchfds(varargin),
% SEARCHFDS Finds the matches to a search pattern in the FDS 
%
%   [ENTITY, DESC] = SEARCHFDS(PATTERN) uses PATTERN to search the Financial
%   Database System (FDS) for matches in the name. PATTERN is the pattern 
%   used to search for in an attempt to match the expression it includes
%   the following SQL Server wildcard characters: % _ [ ] [^]. 
%
%   [ENTITY, DESC] = SEARCHFDS(PATTERN,ATTR) use PATTERN to search
%   attribute ATTR in the Financil Database System. Can search ATTR 
%   'Description','Exchange','Currency','Entity', and 'ISIN'. The 
%   default is 'Description'.
%    
%   [ENTITY, DESC] = SEARCHFDS(PATTERN,ATTR,VIEW) use PATTERN to search
%   attribute ATTR in the Financil Database System. Can search ATTR 
%   'Description','Exchange','Currency','Entity', and 'ISIN'. The 
%   default is 'Description'. VIEW is either 'Item', 'Entity' or
%   'Portfolio' to search the FDS Item and Entity Description or Portfolio
%   Data views.
%
%   Example 1: '%' for any string of zero or more characters as in    
%       WHERE title LIKE ‘%tactical%’ finds all book titles with the
%       word ‘tactical’ anywhere in the book title.
%
%   Example 2: '_' (underscore) for any single character as in WHERE 
%       name LIKE ‘_olio’ finds all four-letter first names that
%       end with olio (portfolio, folio, and so forth).
%
%   Example 3: '[ ]' for any single character within the specified range ([a-f]) 
%       or set ([abcdef]). WHERE name LIKE ‘[A-D]enders’ finds author last 
%       names ending with nders and beginning with any single character 
%       between A and D, for example Aenders, Cenders, Benders, and so on.
%
%   Example 4: '[^]' for any single character not within specified range 
%       ([^a-f]) or set the ([^abcdef]) WHERE name LIKE ‘ba[^k]%’ all author 
%       last names beginning with ba and where the following letter is not k.
%                       
%   Example 5: 'escape_character' is any valid SQL Server expression of any 
%       of the data types of the character string data type category. 
%       escape_character has no default and must consist of only one character.
%
% Note: Single output returns the entire view as a cell-array. No output 
% returns a screen friendly text presentation of the Entity and
% Description. Multiple comma separated PATTERN input arguments are 
% accepted this results in multiple searches who results are 
% concatenated together e.g. SEARCHFDS('AGL,RCH','Entity') will return
% all information with the PATTERN 'AGL' and 'RCH'.
%
% See also : @FDS

% $Revision: 1.0 $ $Date: 2006/03/29 12:26:34 $ $Author: tgebbie $

% defaults
dim             = 'Description';
database_object = 'view_EntityDescription';
curs_index      = [2 4];
out_key         = '*';

switch nargin
    case 1
       pattern = commalist2cell(cell2commalist(varargin{1})); 

    case 2
       pattern = commalist2cell(cell2commalist(varargin{1}));
       dim     = varargin{2};
       
    case 3
       % The search pattern
       pattern = commalist2cell(cell2commalist(varargin{1}));
       % The search attribute
       if ~isempty(varargin{2}), dim = varargin{2}; end;
       % The search database object
       switch lower(varargin{3}),
           case 'entity',
               database_object = 'view_EntityDescription';
               curs_index = [2 4];
           case 'item',
               database_object = 'view_ItemDescription';
               curs_index = [2 3];
           case 'portfolio',
               database_object = 'view_PortfolioData';
               curs_index = [1 2];
               out_key = 'ParentNode';
           otherwise
               error('Unrecognized or unsupported view');
       end
    otherwise
        error('Unrecognized Input arguments');
end

% defaults to the FDS 
f = fds;
% Open default database connection
conn=database(get(f,'database'),get(f,'username'),get(f,'password'));
% loop through input string queries
for i=1:length(pattern),
    % construct the query string
    strSQL = sprintf('select %s from %s where %s like ''%s''',out_key,database_object,dim,pattern{i});
    % set the cursor using the connection and query
    curs = exec(conn, strSQL);
    % get the cursor from the FDS
    curs = fetch(curs);
    % get the required data from the cursor
    switch curs.Data{1,1}
        case 'No Data',
            if (i==1),
                if (nargout==1),
                    e = {};
                    d = {};
                else
                    e = {};
                end;
            end;
        otherwise,
            if (i==1),
                if (nargout==1),
                    e = [curs.Data, cellstr(num2str(i*ones(size(curs.Data,1),1)))];
                else
                    e = curs.Data(:,curs_index(1));
                    d = curs.Data(:,curs_index(2));
                end;
            else
                if (nargout==1),
                    e = [e; [curs.Data, cellstr(num2str(i*ones(size(curs.Data,1),1)))]];
                else
                    e = [e; curs.Data(:,curs_index(1))];
                    d = [e; curs.Data(:,curs_index(2))];
                end;
            end;
    end;
end;
% Close database cursor
close(curs);
% Close database connection
close(conn);
% format output arguments
if nargout == 0,
  for i = 1:size(e,1), 
      fprintf('%5i. %7s  - %s\n', i, e{i}, d{i}); 
  end;
end;

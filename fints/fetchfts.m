function fts = fetchfts(varargin),
% FETCHFTS Fetch data for FINTS object from the database
%
% FTS = FETCHFTS(SERIES,DESC) Fetch all the data avaliable for the
% series of names SERIES and data description DESC,.
%
%   Example 1: f = fetchfts('A,B','MyData');  
%
% FTS = FETCHFTS(SERIES,DESC,DATES) Get data for description DESC for 
% all series names SERIES in the range of DATES. DATES can be either a
% single date string, e.g. '10-Oct-2004', or a datestr range, e.g.
% '[10-Oct-2004,20-Oct-2004]' or '10-Oct-2004::20-Oct-2004' or a date 
% string list, e.g. {'10-Oct-2004', '11-Oct-2004','12-Oct-2004'}. 
% Date numbers are not accepted.
%
%   Example 2: f = fetchfts('A,B','MyData','08-Oct-2004::20-Oct-2004')
%
% 1. Fetch's data from the table 'table_TimeSeriesData'
% 2. The table should have attributes: 
%       'Series', 
%       'Description', 
%       'DateTime', 
%       'Value', 
% 3. The default database instance is 'MyFinancialDatabase'.
% 4. The default dateform expected: 'yyyy-mm-dd HH:MM:SS' this is matlab
%    dateform 31 e.g. 2000-03-01 15:45:17. 
%
% See Also: FINTS, @FINTS\INSERT, COMMALIST2CELL
 
% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:57 $ $Author: Tim Gebbie $

% This defaults to the database are
instance = 'MyFinancialDatabase';
% default username from system environment
username = getenv('username'); 
% default password
password = 'MyPassword';
% Specify view/table attributes
colnames = {'Series', 'Description', 'DateTime', 'Value'};
% Default database oject
database_object = 'table_TimeSeriesData';
% Default dateform
% 31             'yyyy-mm-dd HH:MM:SS'    2000-03-01 15:45:17 
dateform = 31; 

%% Build the required SQL statements
switch nargin,
    case 2,
        % description and seriesnames are provided
        attr = colnames{1,2};
        attr_range = varargin; 
    case 3, 
        % description, seriesnames, date range are provided
        attr = colnames{1,2,3};
        attr_range = varargin;
        attr_range{3} = daterange(varargin{3});
    otherwise
        error('Incorrect Input Data');
end;

%% CONSTRUCT THE SQL REQUEST
str_select = sprintf('select * from %s ', database_object);
str_where = '';
str_clause = 'where';
% loop through the attributes
for i = 1:length(attr),
    % Construct the where part based upon the data type.
    if strcmp(attr{i},'DateTime') & length(attr_range{i})==2,
         str_where = sprintf('%s %s %s between ''%s'' and ''%s''',  ...
            str_where, str_clause, attr{i}, ...
            attr_range{i}{1},attr_range{i}{2});
    else
        str_where = sprintf('%s %s %s in (%s)', ...
            str_where, str_clause, attr{i},attr_range{i});
    end
        str_clause = 'and';
end; %for
        
%% ACCESS DATABASE and LOAD DATA        

% Make data connection to default database and test connection
conn = database(instance,username,password);
if ~isconnection(conn),
  close(conn);
  error(sprintf('%s - %s','Database error', curs.Message));
end;%if

% Execute SQL statement and open cursor
curs = exec(conn, str_select);
if ~isempty(curs.Message),
  % Always try to close but recover.
  try close(curs); catch end; % is the cursor is a figure handle? 
  close(conn);
  error(sprintf('%s - %s','Database error', curs.Message));
end;%if

%% LOAD THE DATA RECURSIVELY INCASE THE DATA VOLUME IS LARGE
% initialize data
data = {};
% initialize the number rows to load at each iteration
row_num = 3000; 
% recursive fetch of the data
while 1,
    % fetch row_num rows at each time
    curs = fetch(curs,row_num);
    % trap erros
    if ~isempty(curs.Message),
        close(curs);
        close(conn);
        error(sprintf('%s - %s','Database error', curs.Message));
    end;%if
    if rows(curs)==0, break; end;
    % Extract data from cursor
    data = cat(1,data,curs.Data);
end;

% get the no data case
if strcmp(data,'No Data'), error('Database error - No Data'); end;

% Get the attributes of the cursor
attributes = attr(curs);

% Check if data returned otherwise error
if isempty(data), error(sprintf('Database error - No Data \n%s',curs.SQLQuery)); end;%if

%% Sort and extract the data
series = deblank(curs.Data(:,1));
desc   = deblank(curs.Data(:,2));
dates  = datenum(char(curs.Data(:,3)),'yyyy-mm-dd HH:MM:SS');
values = cell2mat(curs.Data(:,4));

%% Create the new FINTS object
try
    fts = fints(datetime,values,series,freq,desc);
    warning(lasterr);
catch
    try
        fts = fints(datetime,values,series,freq);
        warning(lasterr);
    catch
        try
            fts = fints(datetime,values,series);
            warning(lasterr);
        catch
            try
                fts = fints(datetime,values);
                warning(lasterr);
            catch
                error(lasterr);
            end
        end
   end
end

%% CLEAN UP
% Close cursor and connection
close(curs);
close(conn);

% Check for empty data
if strcmp(data{1}, 'No Data'), data = []; end; %if
return;


%% HELPER FUNCTIONS
function dates = daterange(incell),
% DATERANGE Convert a date-range to date numbers
%
% [DATES] = DATERANGE(CELL) CELL is a string cell-array of the 
% date range. CELL can also be a datenumbers, this will then
% produce a date-range. The date range can be expressed in one 
% of the following forms:
%
% 1. An inclusive date range string: '[datestr1, datestr2]'
% 2. An includive double colon delimited range: 'datestr1::datestr2'
% 3. A comma separated list of dates 'datestr1,datestr2'
%
% These are converted into MATLAB date number.
%
% See Also: DATESTR, DATENUM

switch class(incell),
    case {'char','str','cell'}
        % get the list of datestrings
        datestrs = char(incell);
        % can be:
        %
        % 1. An inclusive range string, '[datestr1, datestr2]',
        % 2. '::' double colon delimiter for date ranges
        % 3. A comma separated list, 'datstr1, datestr2'.  
        %
        % Test firstly for '[]' because of the comma in it the 1. and 2.
        if all(ismember('[]', [datestrs(1) datestrs(end)])),
            % 1. Inclusive range string, '[datestr1, datestr2]' => convert to date number range pair.
            dates = datenum(commalist2cell(datestrs(2:end-1)));     
        elseif any(findstr(datestrs,'::')),
            % 2. Inclusive range string, 'datestr1::datestr2' => convert to date range pair
            cind  = findstr(datestrs,'::');
            dates = datenum([datestrs(1:cind-1);datestrs(cind+2:end)]);
        elseif any(ismember(',', datestrs)),
            % 3. Comma separated list, 'datstr1, datestr2' => convert to date numbers vectors.
            dates = datenum(commalist2cell(datestrs),'yyyy-mm-dd HH:MM:SS');  
        else
            % We assume it is a single date string
            dates = datenum(char(incell)); 
        end;%if
        
    case {'double'}
        dates = sprintf('%s::%s',datestr(incell(1)),datestr(incell(end)));
    otherwise
        error('Incorrect Input arguments');
end
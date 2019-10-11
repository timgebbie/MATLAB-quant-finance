function fts = fetchfts(varargin),
% EXECFETCHFTS Fetch data for FINTS object from the database directly
%
% FTS = EXECFETCHFTS(ENTITIES,ITEMS) Fetch all the data avaliable 
% for the entities ENTITES and data items ITEMS in the last 2 working days. 
%
%   Example 1: f = execfetchfts('R:AGLJ,R:BILJ','RI');
%
% FTS = EXECFETCHFTS(ENTITIES,ITEMS,DATERANGE) Fetch all the data avaliable 
% for the entities ENTITES and data items ITEMS in the range of DATES. 
% DATES can be either a single date string, e.g. '10-Oct-2004', or a 
% datestr range, e.g. '[10-Oct-2004,20-Oct-2004]' or '10-Oct-2004::20-Oct-2004'. 
% Date numbers are not accepted. Default frequency is 'D' (Daily).
%
%   Example 2: f = execfetchfts('R:AGLJ,R:BILJ','RI','08-Oct-2004::20-Oct-2004')
%
% FTS = EXECFETCHFTS(SERIES,DESC,DATERANGE,FREQ) Get data for description DESC for 
% all series names SERIES in the range of DATES. DATES can be either a
% single date string, e.g. '10-Oct-2004', or a datestr range, e.g.
% '[10-Oct-2004,20-Oct-2004]' or '10-Oct-2004::20-Oct-2004' and the
% sampling frequency as FREQ. Date numbers are not accepted.
%
%   Example 3: f = execfetchfts('R:AGLJ,R:BILJ','RI','08-Oct-2004::20-Oct-2004','D')
%
% See Also: FINTS, @FINTS\INSERT, COMMALIST2CELL
 
% Author: Tim Gebbie 

% $Revision: 1.0 $ $Date: 2006/03/31 05:04:38 $ $Author: tgebbie $

% This defaults to the database are
instance = 'QT_FDS_MadHatter';
% default username from system environment
% username = getenv('username');
username = 'QT_edit';
% default password
% password = 'MyPassword';
password = 'write_QT;
% Specify view/table attributes
% creator = {'FG_QED'};
creator = 'DATASTREAM_QAD';
% frequency
freq = 'D';
% Default database oject
database_object = 'TS_View_Item_Entities';
% Default dateform
% 31             'yyyy-mm-dd HH:MM:SS'    2000-03-01 15:45:17 
% dateform = 31; 
dateform = 'yyyy/mm/dd';

%% Build the required SQL statements
switch nargin,
    case 2,
        % description and seriesnames are provided
        entities   = varargin{1};
        items      = varargin{2};
        date_range = busdays(today-5,today);
        date_range = datestr(date_range(1:2),dateform);
        
    case 3,
        % description and seriesnames are provided
        entities   = varargin{1};
        items      = varargin{2};
        date_range = datestr(daterange(varargin{3}),dateform); 
        freq       = 'D';
        
    case 4, 
        % description, seriesnames, date range are provided
        entities   = varargin{1};
        items      = varargin{2};
        date_range = datestr(daterange(varargin{3}),dateform); 
        freq       = varargin{3};
        
    otherwise
        error('Incorrect Input Data');
end;

%% PREPARE THE ENTITY AND ITEM LIST
if length(commalist2cell(entities))>1, entities = [cell2commalist(entities) ',@']; end;
if length(commalist2cell(items))>1, items = [cell2commalist(items) ',@']; end;
date_range = cellstr(date_range);

%% CONSTRUCT THE SQL REQUEST
% strSQL = sprintf('exec %s ''%s'',''%s'',''%s'',''%s'',''%s'',''%s''', ...
%                    database_object, creator, entities, items, date_range{1}, date_range{2}, freq);
strSQL = sprintf('exec %s ''%s'',''%s'',''%s'',''%s'',''%s''', ...
                    database_object, creator, entities, items, date_range{1}, date_range{2});

%% ACCESS DATABASE and LOAD DATA        

% Make data connection to default database and test connection
conn = database(instance,username,password);
if ~isconnection(conn),
  close(conn);
  error(sprintf('%s - %s','Database error', curs.Message));
end;%if

% Execute SQL statement and open cursor
curs = exec(conn, strSQL);
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
dates  = datenum(char(cursData(:,3)),'yyyy-mm-dd HH:MM:SS');
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

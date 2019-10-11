function f = insert(varargin)
% @FINTS/INSERT Insert (Append) Matlab data to specficed database tables
%
% F=INSERT(FTS) Append FINT data into default database's TABLE using 
% column names COLNAMES. This overloads Matlabs insert.
%
% 1. Inserts data into the temporary table 'updateTimeSeries'
% 2. Execute stored procedure 'proc_updateTimeSeries'
% 3. The table should have attributes: 
%       'Series', 
%       'Description', 
%       'DateTime', 
%       'Value'. 
% 4. The default database object is 'table_TimeSeriesData'
%
% Note: Requires Database Toolbox 3.0.1. This can be implemented 
% using a stored procedure and a scratch patch table if the time 
% series database object is a view. 
%
% See also: INSERT, FETCH

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

% Get object variable
ftinfo = ftsinfo(varargin{1});
ftdata = fts2mat(varargin{1},1);
% This defaults to the database are
instance = 'MyFinancialDatabase';
username = getenv('username'); 
password = 'MyPassword';
table    = 'table_TimeSeriesData');
% Specify column names
colnames = {'Series', 'Description', 'DateTime', 'Value'};
% Get size of c_portfolio
[m,n] = size(ftdata);
% convert data to cells for database columns
cell_Series      = cellstr(reshape(repmat(ftinfo.seriesnames', m, 1),m*(n-1),1));
cell_Description = repmat(cellstr(ftinfo.desc),m*(n-1),1);
cell_DateTime    = reshape(repmat(cellstr(datestr(ftdata(:,1),29)),1,n-1),m*(n-1),1);
cell_Value       = num2cell(reshape(ftdata(:,2:end),m*(n-1),1));
% Concattenate data into rows for database table
data = [cell_Series cell_Description cell_DateTime cell_Value];
% Ensure that the input are correct before opening the database instance
if ~isstr(table), error('Incorrect input arguments'); end; %if
if ~iscellstr(colnames), error('Incorrect input arguments'); end; %if
if ~(iscell(data) | isnumeric(data) | isstruct(data)), error('Incorrect input arguments'); end; %if
% Open default database connection and test connection
[conn]= database(instance,username,password); 
if ~isconnection(conn),
  close(conn); % close connection if an error is encountered
  error('Database error', conn.Message);
end;%if
% Insert (Append) the data in database using matlab insert
insert(conn, table, colnames, data);
% Close connection
close(conn);





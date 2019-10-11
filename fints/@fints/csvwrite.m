function csvwrite(varargin)
% @FINTS/CSVWRITE Save FINTS object to an excel spreadsheet
%
% CSVWRITE(FTS) Saves the FINTS object FTS to file with name as in the
% object decription and the sheet namm as in the object description.
%
% CSVWRITE(FTS, FILENAME) Saves the FINTS object FTS to the file FILENAME. 
% FILENAME may be the full [drive:][path]filename[.xls]
%
% Examples:
%
% See Also: XLSREAD, XLSWRITE, XLSINFO

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

if ~isa(varargin{1},'fints'), error('Incorrect Input Arguments'); end;
% get the FINTS object
fts = varargin{1};
% get the data and include the dates as the first column
fts_data = fts2mat(fts,1);
% convert the date to excel dates
if ~isempty(fts_data), fts_data(:,1) = m2xdate(fts_data(:,1)); end;
% get the general information about the time-series object
fts_info = ftsinfo(fts);

switch nargin
case 1
    filename    = sprintf('FINTS-%s-%s',shorten(fts_info.desc),datestr(now,'yyyymmdd'));
case 2
    filename    = varargin{2};
otherwise
    error('Incorrect Input Arguments');
end

% Condition the filename stuff
[D,fil,ext]=fileparts(filename);
% set the default directory
if isempty(D), D=pwd; end;
% set the default extensions
if isempty(ext), ext = '.csv'; end;
% construct the filename
filename = fullfile(D,[fil  ext]);
% create the cell array object
cell_Series      = ['Dates' transpose(fts_info.seriesnames)];
% open the file
h = fopen(filename);
% write to the flat comma delimited file
fprintf(h,'%s,',cell_Series);
% close the file
fclose(h);
% write to the flat comma delimited file
dlmwrite(filename, fts_data,'-append','delimiter',',');

% helper function
function str = shorten(str),
% STR = SHORTEN(STR) Remove padding and colons in strings
% find colon
ci = ~ismember(str,':');
% find spaces
si = findstr(str,' ');
% replace space with dash
str(si)='-';
% remove colon
str = str(ci);
% keep only the last 30 characters
if length(str)>30, str = str(end-29:end); end;


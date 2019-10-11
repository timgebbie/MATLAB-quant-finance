function [s,m] = xlswrite(varargin)
% @FINTS/XLSWRITE Save FINTS object to an excel spreadsheet
%
% XLSWRITE(FTS) Saves the FINTS object FTS to file with name as in the
% object decription and the sheet namm as in the object description.
%
% XLSWRITE(FTS, FILENAME) Saves the FINTS object FTS to the file FILENAME. 
% FILENAME may be the full [drive:][path]filename[.xls]
%
% XLSWRITE(FTS, FILENAME, SHEETNAME) Saves the FINTS object FTS to the file
% FILENAME and the sheet name SHEETNAME.
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
    filename    = sprintf('FINTS-%s-%s',shorten(char(fts_info.desc)),datestr(now,'yyyymmdd'));
    sheetname   = shorten(char(fts_info.desc));
case 2
    filename    = varargin{2};
    sheetname   = shorten(char(fts_info.desc));
case 3
    filename    = varargin{2};
    sheetname   = varargin{3};
otherwise
    error('Incorrect Input Arguments');
end

% Condition the filename stuff
[D,fil,ext]=fileparts(filename);
% set the default directory
if isempty(D), D=pwd; end;
% set the default extensions
if isempty(ext), ext = '.xls'; end;
% construct the filename
filename = fullfile(D,[fil  ext]);
% write to the excel spreadsheet and range
[s,m] = xlswrite(filename,fts_data,sheetname,'A2');
% write the share names to the excel spreadsheet with range
[s,m] = xlswrite(filename,{'Dates', fts_info.seriesnames{:}},sheetname,'A1');

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


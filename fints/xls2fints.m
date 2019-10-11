function fts = xls2fints(varargin)
% XLS2FINTS Convert an EXCEL workbook into a FINTS object
% 
% FTS = XLS2FINTS(FILE) This is initiates the interactive region 
% selection. You have to select the active region and the active 
% sheet in the EXCEL window that will come into focus. Enter any 
% letter at Matlab command line when finish selecting the active region.
%
% FTS = XLS2FINTS(FILE,SHEET,RANGE) reads the data specified
% in RANGE from the worksheet SHEET, in the Excel file specified in FILE. The
% numeric cells in FILE are returned in NUMERIC, the text cells in FILE are
% returned in TXT, while the raw, unprocessed cell content is returned in
% RAW. It is possible to select the range of data interactively (see Examples
% below). Please note that the full functionality of XLSREAD depends on the
% ability to start Excel as a COM server from MATLAB. The data is expected 
% to be in the format with the first row being the ENTITIES and the first
% entry in the first row the ITEM type, the first column is assumed to be
% the DATE-TIMES in EXCEL date-time format, the remaining data is taken to
% be the values i.e.
%
%       [ITEM]        [ENTITY1] [ENTITY2] ... [ENTITYN]
%       [DATETIME1]   [VALUE11]    
%           ...                     ....
%       [DATETIMEN]   ...                     [VALUENN]
% 
% FTS = XLS2FINTS(FILE,SHEET,RANGE,'basic') reads an XLS file as
% above, using basic input mode. This is the mode used on UNIX platforms
% as well as on Windows when Excel is not availabe as a COM server.  
% In this mode, XLS2FINTS does not use Excel as a COM server, which limits
% import ability. Without Excel as a COM server, RANGE will be ignored
% and, consequently, the whole active range of a sheet will be imported. 
% Also, in basic mode, SHEET is case-sensitive and must be a string.
% 
% Input Parameters:
%
%    FILE: string defining the file to read from. Default directory is pwd.
%          Default extension is 'xls'. See NOTE 1.
%    SHEET: string defining worksheet name in workbook FILE.
%           double scalar defining worksheet index in workbook FILE.
%    RANGE: string defining the data range in a worksheet. See NOTE 2.
%    MODE: string enforcing basic import mode. Valid value = 'basic'.
%
% Example 1:
%    file = 'C:\Spreadsheets\MyFile.xls';
%    fts = xls2fints(file);
%
% See Also: XLSREAD

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:57 $ $Author: Tim Gebbie $

switch nargin
    case 1
        [numeric,txt,raw] = xlsread(varargin{1},-1);
    case 2
        [numeric,txt,raw] = xlsread(varargin{1},varargin{2});
    case 3
        [numeric,txt,raw] = xlsread(varargin{1},varargin{2},varargin{3});
    case 4
        [numeric,txt,raw] = xlsread(varargin{1},varargin{2},varargin{3},varargin{4});
    otherwise
        error('Incorrect Input Arguments');
end;

%% Process the data
% check that the size of txt is the same as the numeric 
% Three cases are considered:
%   1. All the data is numeric with a the first row being text entries
%   2. The width of the text data is the same as the numeric data so
%   assuming that the first column of numeric data is dates.
%   3. The default assumption.
if all(size(numeric)==size(txt)),
    % assume that there are no column title and the first row are dates
    % dates
    date = x2mdate(numeric(:,1));
    % numeric values
    value = numeric(:,2:end); 
    % the entity types
    entity = {}; 
    % the items
    item = {}; 
elseif (size(numeric,2)==size(txt,2)),
    % the dates
    date = x2mdate(numeric(:,1));
    % the values
    value = numeric(:,2:end);
    % the entities
    entity = txt(2:end);
    % the item description
    item = txt(1,1);
else ((size(txt,1)==(1+size(numeric,1))) & (size(txt,2)==(1+size(numeric,2)))),
    % check that the first column of text are dates
    try
        date = datenum(txt{2:end,1});
    catch
        % catch altnerative date format not automatically recognized
        try
            date = datenum(txt(2:end,1),'yyyy/mm/dd');
        catch
            error(lasterr);
        end
    end
    % the values
    value = numeric;
    % the items
    item = txt(1,1);
    % the entities
    entity = txt(1,2:end);
end;

%% Construct the FINT object
% loop through each unique item 
try
    %       FTS = fints(DATES, DATA, DATANAMES, FREQ, DESC);
    %       FTS = fints(DATES_TIMES, DATA, DATANAMES, FREQ, DESC);
    fts = fints(date, value, entity, [], char(item));
catch
    try
        warning(lasterr);
        %       FTS = fints(DATES, DATA, DATANAMES, FREQ);
        %       FTS = fints(DATES_TIMES, DATA, DATANAMES, FREQ);
        fts = fints(date, value, entity, []);
    catch
            try
                warning(lasterr);
                %       FTS = fints(DATES, DATA, DATANAMES);
                %       FTS = fints(DATES_TIMES, DATA, DATANAMES);
                fts = fints(date, value, entity);
            catch
                try              
                    warning(lasterr);
                    %       FTS = fints(DATES, DATA);
                    %       FTS = fints(DATES_TIMES,DATA);
                    fts = fints(date, value);
                catch
                    try 
                        warning(lasterr);
                        %       FTS = fints(DATES_AND_DATA);
                        %       FTS = fints(DATES_TIMES_AND_DATA);
                        fts = fints(value);
                    catch
                         error('Cannot convert to FINTS');
                    end; % end try catch
                end; % end try catch
         end; % end try catch
    end; % end try catch
end; % end try catch 
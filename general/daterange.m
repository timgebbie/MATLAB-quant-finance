function dates = daterange(varargin)
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
% [DATES] =DATERANGE(DATE1,DATE2) For DATE1 and DATE2 either
% date numbers or strings.
%
% [DATES] =DATERANGE(DATE1,DATE2,FREQ) Where FREQ is one of the 
% following: 'D','W','M','Q','S','A'. The dates are return as a
% cell-array of string dates.
%
% These are converted into MATLAB date number.
%
% See Also: DATESTR, DATENUM

% Author: Tim Gebbie 31-09-2004

% 1.2 2009/02/06 14:21:56 Tim Gebbie

switch nargin
    case 1
        % first input arguments as cell-array
        incell=varargin{1};
        switch class(incell),
        case {'char','str','cell'}
            % get the list of datestrings
            datestrs = char(incell);
            % can be:
            %
            % 0. A single date with no fractional componente'
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
                % 0. single non-fractional date implies daily sampling 
                if ~(abs(round(dates)-dates)>0),
                    % find the next business day using holidays
                    bdates = busdays(dates,dates+12,'D');
                    % generate the range from DATE to next business day
                    dates = [dates;bdates(2) - 6.9444440305233e-4]; 
                end;
            end;%if
        
        case {'double'}
            dates = sprintf('%s::%s',datestr(incell(1)),datestr(incell(end)));
            otherwise
            error('Incorrect Input arguments');
        end
        
    case 2
        % first date
        date1 = datestr(varargin{1});
        % second date
        date2 = datestr(varargin{2});
        % date range string
        dates = sprintf('%s::%s',date1,date2);
        
    case 3
        
        % date1 < date2
        if datenum(datestr(varargin{1}))>datenum(datestr(varargin{2})), error('DATE1 must be less than DATE2'); end;
        % The date range between the first and second dates
        date12 = (datenum(datestr(varargin{1})):datenum(datestr(varargin{2})));
        % condition the dates
        date12 = date12(:);
        % the date vector format
        fts = fints(date12,NaN*ones(size(date12)));
        % sampling frequency
        fts = convertto(fts,varargin{3});
        % get the dates
        dates = cellstr(datestr(fts.dates));
        % ensure that no dates larger that the second date occur
        dates = dates(datenum(dates)<=date12(end));
        % if the date range is empty use the 'Nearest' date in the 
        % resample date range
        if isempty(dates),
            dates = datenum(datestr(varargin{1})) - str2num(datestr(varargin{2},7));      
        end;
 
    otherwise
        error('Incorrect Input Arguments');
end
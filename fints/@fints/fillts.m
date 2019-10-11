function fts = fillts(ftsa, fillmethod, newdates, varargin)
%@FINTS/FILLTS replaces the NaN's in a FINTS object through interpolation.
%
%   NEWFTS = FILLTS(OLDFTS) will replace the missing values (NaN's) in OLDFTS
%   with via an interpolation process using LINEAR interpolation.
%
%   Note: 'Filled' will be to the description in NEWFTS.
%
%   For example:
%      %% Create the FINTS object %%
%      dates = ['01-Jan-2001';'01-Jan-2001'; '02-Jan-2001'; ...
%              '02-Jan-2001'; '03-Jan-2001';'03-Jan-2001'];
%      times = ['11:00';'12:00';'11:00';'12:00';'11:00';'12:00'];
%      dates_times = cellstr([dates, repmat(' ',size(dates,1),1), times]);
%      myFts = fints(dates_times,[(1:3)'; nan; nan; 6],{'Data1'},1, ...
%              'My first FINTS')
%      %% Create the FINTS object %%
%
%      newFts = fillts(myFts)
%
%      newFts =
%
%      desc:  Filled My first FINTS
%      freq:  Unknown (0)
%
%      'dates:  (6)'    'times:  (6)'    'Data1:  (6)'
%      '01-Jan-2001'    '11:00'          [          1]
%      '     "     '    '12:00'          [          2]
%      '02-Jan-2001'    '11:00'          [          3]
%      '     "     '    '12:00'          [     3.1200]
%      '03-Jan-2001'    '11:00'          [     5.8800]
%      '     "     '    '12:00'          [          6]
%
%   NEWFTS = FILLTS(OLDFTS, FILLMETHOD) will replace the missing values (NaN's)
%   in OLDFTS via an interpolation process*, through a zero-order hold**, or
%   with a constant***.
%
%   (*) To replace missing values via an interpolation process.%
%   Valid interpolation method (FILLMETHOD):
%
%      linear  - 'linear',   'l' (DEFAULT)
%      cubic   - 'cubic',    'c'
%      spline  - 'spline',   's'
%      nearest - 'nearest',  'n'
%      pchip   - 'pchip',    'p'
%
%      linear with extrapolation   - 'linearExtrap',     'le'
%      cubic with extrapolation    - 'cubicExtrap',      'ce'
%      spline with extrapolation   - 'splineExtrap',     'se'
%      nearest with extrapolation  - 'nearestExtrap',    'ne'
%      pchip with extrapolation    - 'pchipExtrap',      'pe'
%
%   (**) To replace missing values via a zero-order hold, enter 'zero' as the
%   FILLMETHOD. Zero-order hold will fill missing (NaN) values with the value
%   preceding it. However, if the first value of the object is missing (NaN),
%   it will remain missing (NaN).
%
%   (***) To replace missing values with a constant, enter a constant as the
%   FILLMETHOD.
%
%   For example:
%
%      newFts = fillts(myFts, 'cubic')
%
%      newFts =
%
%      desc:  Filled My first FINTS
%      freq:  Unknown (0)
%
%      'dates:  (6)'    'times:  (6)'    'Data1:  (6)'
%      '01-Jan-2001'    '11:00'          [          1]
%      '     "     '    '12:00'          [          2]
%      '02-Jan-2001'    '11:00'          [          3]
%      '     "     '    '12:00'          [     3.0663]
%      '03-Jan-2001'    '11:00'          [     5.8411]
%      '     "     '    '12:00'          [     6.0000]
%
%    OR
%
%      newFts = fillts(myFts, 'zero')
%
%      newFts =
%
%      desc:  Filled My first FINTS
%      freq:  Unknown (0)
%
%      'dates:  (6)'    'times:  (6)'    'Data1:  (6)'
%      '01-Jan-2001'    '11:00'          [          1]
%      '     "     '    '12:00'          [          2]
%      '02-Jan-2001'    '11:00'          [          3]
%      '     "     '    '12:00'          [          3]
%      '03-Jan-2001'    '11:00'          [          3]
%      '     "     '    '12:00'          [          6]
%
%    OR
%
%      newFts = fillts(myFts, 0.3)
%
%      newFts =
%
%      desc:  Filled My first FINTS
%      freq:  Unknown (0)
%
%      'dates:  (6)'    'times:  (6)'    'Data1:  (6)'
%      '01-Jan-2001'    '11:00'          [          1]
%      '     "     '    '12:00'          [          2]
%      '02-Jan-2001'    '11:00'          [          3]
%      '     "     '    '12:00'          [     0.3000]
%      '03-Jan-2001'    '11:00'          [     0.3000]
%      '     "     '    '12:00'          [          6]
%
%   NEWFTS = FILLTS(OLDFTS, FILLMETHOD, NEWDATES) is similar to the above
%   except for the ability to add new dates to the OLDFTS. FILLTS, in this
%   case, will provide data on the specified NEWDATES. If any NEWDATES exist
%   in the OLDFTS, the existing dates have precedence. Furthermore, if missing
%   values exist in OLDFTS in addition to the supplemented NEWDATES, the
%   missing values will be filled.
%
%   NEWDATES can be a column vector of serial dates, a single date string,
%   or a column cell array of date strings. If no NEWDATES exist, a [] may
%   be substituted in its place. In addition, if the object contains time
%   information, the NEWDATES must be accompanied by a Time Vector (see
%   example below) or the NEWDATES will be assumed to have times of '00:00'.
%
%   NEWFTS = FILLTS(OLDFTS, FILLMETHOD, NEWDATES, SORTMODE) is similar to
%   the above with the addition of SORTMODE. SORTMODE can either keep the
%   order of the NEWFTS the same as OLDFTS or sort NEWFTS chronologically.
%
%   The default SORTMODE is unsorted; SORTMODE = 0. In this mode any new
%   dates will be appended to the end. However, the interpolation and
%   zero-order hold processes that calculate the values for the new dates
%   are applied on the sorted object.
%
%   SORTMODE = 1 sorts the dates (and times) in chronological order.
%
%   NEWFTS = FILLTS(OLDFTS, FILLMETHOD, NEWDATES, {'T1','T2',...}, SORTMODE)
%   is similar to NEWFTS = FILLTS(OLDFTS, FILLMETHOD, NEWDATES) with the
%   addition of being able to specify specific times {'T1','T2',...} that
%   correspond to the NEWDATES. These times can either replace or be added
%   existing dates. The length of NEWDATES must equal the length of the
%   Time Vector.
%
%   For example:
%
%      newFts = fillts(myFts,'c',{'04-Jan-2001';'05-Jan-2001'}, ...
%               {'11:00';'12:00'},0)
%
%      newFts =
%
%      desc:  Filled My first FINTS
%      freq:  Unknown (0)
%
%      'dates:  (8)'    'times:  (8)'    'Data1:  (8)'
%      '01-Jan-2001'    '11:00'          [                1]
%      '     "     '    '12:00'          [                2]
%      '02-Jan-2001'    '11:00'          [                3]
%      '     "     '    '12:00'          [ 3.06632313179959]
%      '03-Jan-2001'    '11:00'          [ 5.84109679730184]
%      '     "     '    '12:00'          [ 6.00000000000000]
%      '04-Jan-2001'    '11:00'          [ 9.84041139653613]
%      '05-Jan-2001'    '12:00'          [12.84461537334308]
%
%   NEWFTS = FILLTS(OLDFTS, FILLMETHOD, NEWDATES, 'SPAN', {'TS','TE'}, DELTA, SORTMODE)
%   and NEWFTS = FILLTS(OLDFTS, FILLMETHOD, NEWDATES, {'T1','T2',...}, SORTMODE)
%   work similarly except that only two times, a Starting Time (ST) and an
%   Ending Time (ET) are required.
%
%   Additionally, a spanning Time Interval, DELTA, must be supplied. DELTA
%   is a Time Interval, in minutes, between the Starting Time and Ending
%   Time. DELTA can be any positive integer (Note: Please use a reasonable
%   number). If NEWDATES contains one date, specifying a Starting and
%   Ending Time will generate only a time for that specific date.
%
%   For example:
%      Add an additional day, 04-Jan-2001, from 11:00 to 12:00 to the
%      object, myFts.
%
%      DELTA = 60 (minutes) because every hour is desired between 11:00 and
%      12:00 inclusive.
%
%      myFts =
%
%      desc:  My first FINTS
%      freq:  Daily (1)
%
%      'dates:  (6)'    'times:  (6)'    'Data1:  (6)'
%      '01-Jan-2001'    '11:00'          [          1]
%      '     "     '    '12:00'          [          2]
%      '02-Jan-2001'    '11:00'          [          3]
%      '     "     '    '12:00'          [        NaN]
%      '03-Jan-2001'    '11:00'          [        NaN]
%      '     "     '    '12:00'          [          6]
%
%      newFts = fillts(myFts,'c','04-Jan-2001','span',{'11:00';'12:00'},60,0)
%
%      newFts =
%
%      desc:  Filled My first FINTS
%      freq:  Unknown (0)
%
%      'dates:  (8)'    'times:  (8)'    'Data1:  (8)'
%      '01-Jan-2001'    '11:00'          [          1]
%      '     "     '    '12:00'          [          2]
%      '02-Jan-2001'    '11:00'          [          3]
%      '     "     '    '12:00'          [     3.0663]
%      '03-Jan-2001'    '11:00'          [     5.8411]
%      '     "     '    '12:00'          [     6.0000]
%      '04-Jan-2001'    '11:00'          [     9.8404]
%      '     "     '    '12:00'          [     9.9994]
%
%   See also INTERP1.

%   Author: P. N. Secakusuma, P. Wang
%   Copyright 1995-2003 The MathWorks, Inc.
%   Revision: 1.1    Date: 2005-05-26 14:32:53+02 

% Author: Tim Gebbie : Modified to correct the bug with implementation
% of the zero-order-hold. 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

% Determine fints version, if version 1 convert to version 2 and do not
% sort.
[ftsVersion, timeData] = fintsver(ftsa);
if ftsVersion == 1
    ftsa.names{length(ftsa.names)+1} = 'times';
    ftsa.data{5} = [];
end

constFill = NaN;
extrap = 0;

% If 'fillmethod' is not specified, assume LINEAR method.
switch nargin
    case 1
        fillmethod = 'l';
        sortmode = 0;   % Not sorted.

    case 2
        % Check fillmethod
        if ischar(fillmethod)
            [fillmethod, extrap] = methodabbrv(fillmethod);

            if isempty(fillmethod)
                error('Ftseries:fillts:InvalidMethod', ...
                    [fillmethod, ' is an invalid FILLMETHOD.']);
            end

        elseif isempty(fillmethod)
            fillmethod = 'l';

        elseif isnumeric(fillmethod)
            constFill = fillmethod;

        else
            error('Ftseries:fillts:InvalidMethod', ...
                'Invalid FILLMETHOD.');
        end
        sortmode = 0;

    case 3
        % Check fillmethod
        if ischar(fillmethod)
            [fillmethod, extrap] = methodabbrv(fillmethod);

            if isempty(fillmethod)
                error('Ftseries:fillts:InvalidMethod', ...
                    [fillmethod, ' is an invalid FILLMETHOD.']);
            end

        elseif isempty(fillmethod)
            fillmethod = 'l';

        elseif isnumeric(fillmethod)
            constFill = fillmethod;

        else
            error('Ftseries:fillts:InvalidMethod', ...
                'Invalid FILLMETHOD.');
        end

        % Check newdates
        if ~isempty(newdates)
            if isnumeric(newdates) || iscell(newdates)
                if size(newdates, 2) ~= 1
                    error('Ftseries:fillts:NEWDATESInvalid', ...
                        ['NEWDATES need to be a column vector of serial dates\n', ...
                        'or a column cell array of date strings.']);
                end

            elseif ischar(newdates),
                if size(newdates, 1) ~= 1
                    error('Ftseries:fillts:NEWDATESInvalid', ...
                        ['NEWDATES can take only 1 date string or a column\n', ...
                        'cell array of date strings.']);
                end
            end
        end
        sortmode = 0;

    case {4, 5, 6, 7}
        % Check fillmethod
        if ischar(fillmethod)
            [fillmethod, extrap] = methodabbrv(fillmethod);

            if isempty(fillmethod)
                error('Ftseries:fillts:InvalidMethod', ...
                    [fillmethod, ' is an invalid FILLMETHOD.']);
            end

        elseif isempty(fillmethod)
            fillmethod = 'l';

        elseif isnumeric(fillmethod)
            constFill = fillmethod;

        else
            error('Ftseries:fillts:InvalidMethod', ...
                'Invalid FILLMETHOD.');
        end

        % Check newdates
        if ~isempty(newdates)
            if isnumeric(newdates) || iscell(newdates)
                if size(newdates, 2) ~= 1
                    error('Ftseries:fillts:NEWDATESInvalid', ...
                        ['NEWDATES need to be a column vector of serial dates\n', ...
                        'or a column cell array of date strings.']);
                end

            elseif ischar(newdates),
                if size(newdates, 1) ~= 1
                    error('Ftseries:fillts:NEWDATESInvalid', ...
                        ['NEWDATES can take only 1 date string or a column\n', ...
                        'cell array of date strings.']);
                end
            end
        end

        % Check to see if sort mode is entered as 4th argument
        sortmodeOrOther = varargin{1};
        if isnumeric(sortmodeOrOther)
            % 4th argument is sortmode and thus no times are inputted
            % so just let everything pass through.
            sortmode = sortmodeOrOther;

            if isempty(sortmode) || sortmode < 0 || sortmode > 1
                error('Ftseries:fillts:SORTMODEInvalid', ...
                    ['Either SORTMODE is empty or invalid, a Time Vector is\n',...
                    'required, or ''SPAN'' is needed.']);
            end
        end

    otherwise
        error('Ftseries:fillts:InvalidNumOfArgs', ...
            'Invalid number of input arguments.');
end

% Sort the input series based on dates.
oldfts = ftsa;
[ftsa, origidx] = sortfts(oldfts);
allTimes = ftsa.data{5};

% Get all available dates, existing and new.
% Process 3rd input argument, if supplied.
% Dates outside the bounds of the current time series will be removed
% also.
if nargin >= 3
    newdates = extractdates(newdates);

    % Deal with time inputs
    if ~exist('sortmode', 'var') % "if sort mode does not exist as the 4th argument"
        % If there is no time in the object, specifying a Time Vector is not allowed
        if timeData == 0    % If there is NO time information
            error('Ftseries:fillts:NoTime', ...
                ['The object being referenced does not contain time\n', ...
                'information, thus specifying a Time Vector is invalid.']);

        else                % If there is time information
            % Determine what came in as the 4th arg
            if iscell(sortmodeOrOther) % Specifying specific dates
                % Run some checks
                if any(strcmp('',sortmodeOrOther)) || any(strcmp(' ',sortmodeOrOther))
                    error('Ftseries:fillts:MissingTimes', ...
                        'One or more times may be missing or empty.');

                elseif length(sortmodeOrOther) ~= length(newdates)
                    error('Ftseries:fillts:LengthsMustAgree', ...
                        'The lengths of NEWDATES and Times Vector must be equal.');
                end

                % Convert the strings into serial nums without sec and check
                % if there are any errors
                try
                    [Y,M,D,H,MI,S] = datevec(sortmodeOrOther);%#ok

                catch
                    error('Ftseries:fillts:InvalidTimes', ...
                        ['There may be invalid time entries in Time Vector.\n' ...
                        'Make sure all times are in the same format.']);
                end

                % Get time serial number
                z = zeros(length(Y), 1);
                timetime = datenum([z,z,z,H,MI,S]);

                % Add the time information to 'newdates'
                newdates = newdates + timetime;

                % Check sortmode
                try
                    sortmode = varargin{2};

                catch
                    sortmode = 0;   % default to 0
                end

                if ~isnumeric(sortmode) || isempty(sortmode) || (sortmode < 0) || (sortmode > 1)
                    error('Ftseries:fillts:SORTMODEInvalid', ...
                        'SORTMODE can only be 0 or 1.');
                end

            elseif ischar(sortmodeOrOther)  % Specifying spanning times
                % lower case
                sp = lower(sortmodeOrOther);

                % Check 'SPAN'
                if ~strcmp('s', sp(1))
                    error('Ftseries:fillts:UseSPAN', ...
                        ['To initiate the spanning time option, please enter\n', ...
                        '''span'' as the fourth argument.']);
                end

                % Determine what kind of sort mode is desired
                if nargin == 5
                    error('Ftseries:fillts:MissingTimeInterval', ...
                        'Spanning times must include times and a Time Interval.');

                elseif (nargin == 6) || ( nargin == 7)
                    % Get input args
                    spTimes = varargin{2};
                    spInterval = varargin{3};
                    sortmode = 0; % default to 0
                    if nargin == 7
                        sortmode = varargin{4};
                        % Check sortmode
                        if ~isnumeric(sortmode) || isempty(sortmode) || (sortmode < 0) || (sortmode > 1)
                            error('Ftseries:fillts:SORTMODEInvalid', ...
                                'SORTMODE can only be 0 or 1.');
                        end
                    end

                    % Check spanning times
                    if ~iscell(spTimes)
                        error('Ftseries:fillts:InvalidTimes', ...
                            'Times must be a row/column cell array.');

                    elseif isempty(spTimes)
                        error('Ftseries:fillts:IndicateStartingTime', ...
                            'Please specify a starting and ending time.');

                    elseif any(strcmp('', spTimes)) || any(strcmp(' ', spTimes))
                        error('Ftseries:fillts:IndicateTimes', ...
                            ['Either the starting and/or ending time is empty.\n', ...
                            'Please specify a starting and ending time.']);

                    elseif numel(spTimes) ~= 2
                        error('Ftseries:fillts:StringsRequired', ...
                            'Times must contain only a starting time and an ending time.');
                    end

                    % Check spanning interval
                    if ~isnumeric(spInterval) | (spInterval <= 0) | (floor(spInterval) ~= spInterval)%#ok
                        error('Ftseries:fillts:DELTAInvalid', ...
                            ['The spanning Time Interval, ''DELTA'', must be a positive\n', ...
                            'integer greater than 0.']);

                    elseif numel(spInterval) ~= 1
                        error('Ftseries:fillts:DELTAInvalid', ...
                            'The spanning Time Interval, ''DELTA'', must be a single integer.');

                    elseif isempty(spInterval)
                        error('Ftseries:fillts:DELTAInvalid', ...
                            ['The spanning Time Interval, ''DELTA'', is empty. Please\n', ...
                            'specify a Time Interval.']);
                    end

                    try
                        [Y,M,D,H,MI,S] = datevec(spTimes);%#ok

                    catch
                        error('Ftseries:fillts:InvalidTimes', ...
                            ['There may be invalid spanning time entries.\n', ...
                            'Make sure all times are in the same format.']);
                    end

                    % Get time serial number
                    z = zeros(length(Y), 1);
                    serialTimes = datenum([z,z,z,H,MI,S]);

                    interval = spInterval/60/24;
                    timeVec = serialTimes(1):interval:serialTimes(2);

                    % Check to see if starting time is less than ending time
                    if abs(serialTimes(1) - serialTimes(2)) < (0.001/60/60/24)
                        error('Ftseries:fillts:InvalidSTandET', ...
                            'The Starting Time (ST) must not be the same as the Ending Time (ET).');

                    elseif ~(serialTimes(1) < serialTimes(2))
                        error('Ftseries:fillts:InvalidSTandET', ...
                            'The Starting Time (ST) must be earlier than the Ending Time (ET).');
                    end

                    % Combine NEWDATES and timeVec to create list of new dates and times
                    if length(newdates) == 1
                        % If there is only one date entered and it is to be repeated.
                        % i.e. fillts(f,'l',cellstr(repmat('02-jan-2001',5,1)),'span', ...)
                        lenTime = length(timeVec);
                        repNewDates = repmat(newdates, lenTime, 1);

                        newdates = repNewDates + timeVec(:);

                    else
                        % Check lengths of dates against times
                        if length(newdates) > length(timeVec)
                            error('Ftseries:fillts:TooFewTimes', ...
                                'There are too few times as compared to the dates.');

                        elseif length(newdates) < length(timeVec)
                            error('Ftseries:fillts:TooManyTimes', ...
                                'There are too many times as compared to the dates.');
                        end

                        newdates = newdates + timeVec(:);
                    end

                else
                    error('Ftseries:fillts:InvalidNumOfOutputs', ...
                        'Invalid number of inputs.')
                end % end of 'if nargin == 5'

            else
                % If 4th argument is not a cell or char or numeric
                error('Ftseries:fillts:InvalidInputType', ...
                    'Invalid input type.');
            end % end of 'if iscell(sortmodeOrOther)'
        end % end of 'if timeData == 0'
    end % end of 'if exist(sortmode)'

    % Force to be column vector if necessary
    newdates = newdates(:);

    if timeData == 1
        [commdates, icommold, icommnew] = intersect(ftsa.data{3}+ftsa.data{5}, newdates);%#ok

    else
        [commdates, icommold, icommnew] = intersect(ftsa.data{3}, newdates);%#ok
    end
    newdates(icommnew) = [];
    [newdates, isnd] = sort(newdates);

else
    newdates = [];
end

% Combine old and new dates (and times if they exist).
if timeData == 1
    [alldates, holdIdx] = unique([ftsa.data{3} + ftsa.data{5}; newdates]);

    [Y,M,D,H,MI,S] = datevec(alldates); %#ok
    z = zeros(length(Y), 1);

    allTimes = datenum([z,z,z,H,MI,S]);

else
    [alldates, holdIdx] = unique([ftsa.data{3}; newdates]);
end

% Find either missing data or existing data.
if ~isnumeric(fillmethod) && ~strcmpi(fillmethod, 'z')
    alldata = zeros(length(alldates), ftsa.serscount);

    % Find the existing data
    for idx = 1:ftsa.serscount
        notmissingidx(:, idx) = ~isnan(ftsa.data{4}(:, idx));
    end

else
    alldata = (ones(length(alldates), ftsa.serscount)) * NaN;

    if ~isempty(newdates)
        % Create a new set of data that incorporates any NEWDATES
        newData = [ftsa.data{4}; ones(length(newdates), ftsa.serscount) * NaN];
        newData = newData(holdIdx, :);

        % Find the missing data
        for idx = 1:ftsa.serscount
            missingidx(:, idx) = isnan(newData(:, idx));
        end

    else
        % Find the missing data
        for idx = 1:ftsa.serscount
            missingidx(:, idx) = isnan(ftsa.data{4}(:, idx));
        end
    end
end

% Fill missing data (NaN's).
if ~isnumeric(fillmethod)
    switch fillmethod
        case {'c', 'l', 'n', 's', 'p', 'ce', 'le', 'ne', 'se', 'pe'}
            % First order hold: interpolation
            if any(diff(notmissingidx, [], 2))   % If the missings are not on the same rows, do loops.
                for idx = 1:ftsa.serscount
                    notmissingdata = ftsa.data{4}(notmissingidx(:, idx), idx);
                    if timeData == 1
                        notmissingdates = (ftsa.data{3}(notmissingidx(:, idx))) + (ftsa.data{5}(notmissingidx(:, idx)));

                    else
                        notmissingdates = ftsa.data{3}(notmissingidx(:, idx));
                    end

                    % Interp1 cannot handle interpolation with duplicate
                    % dates.
                    try
                        if extrap
                            % Extrapolation
                            alldata(:, idx) = interp1(notmissingdates, notmissingdata, alldates, fillmethod, 'extrap');

                        else
                            % No extrapolation
                            alldata(:, idx) = interp1(notmissingdates, notmissingdata, alldates, fillmethod);
                        end

                    catch
                        msg = lasterror;

                        if strcmp(msg.identifier, 'MATLAB:interp1:RepeatedValuesX')
                            error('Ftseries:fillts:invalidToUseRepeated', ...
                                'FILLTS does not handle interpolation with duplicate dates.')

                        else
                            error('Ftseries:fillts:genericInterp1Error', ...
                                msg.message)
                        end
                    end
                end

            else
                notmissingdata  = ftsa.data{4}(notmissingidx(:, 1), :);
                if timeData == 1
                    notmissingdates = (ftsa.data{3}(notmissingidx(:, 1))) + (ftsa.data{5}(notmissingidx(:, 1)));

                else
                    notmissingdates = ftsa.data{3}(notmissingidx(:, 1));
                end

                % Interp1 cannot handle interpolation with duplicate dates.
                try
                    if extrap
                        % Extrapolation
                        alldata(:) = interp1(notmissingdates, notmissingdata, alldates, fillmethod, 'extrap');

                    else
                        % No extrapolation
                        alldata(:) = interp1(notmissingdates, notmissingdata, alldates, fillmethod);
                    end

                catch
                    msg = lasterror;

                    if strcmp(msg.identifier, 'MATLAB:interp1:RepeatedValuesX')
                        error('Ftseries:fillts:invalidToUseRepeated', ...
                            'FILLTS does not handle interpolation with duplicate dates.')

                    else
                        error('Ftseries:fillts:genericInterp1Error', ...
                            msg.message)
                    end
                end
            end

        case {'z'}
            % zero order hold

            % Take into account any new dates and order the data
            % accordingly. This will place the new nans introduced via the
            % new dates in the right places.
            if ~isempty(newdates)
                % if new dates were introduced
                for idx = 1:ftsa.serscount
                    logMiss = logical(missingidx(:, idx));
                    alldata(~logMiss, idx) = newData(~logMiss, idx);
                end

            else
                % if no new dates were introduced
                for idx = 1:ftsa.serscount
                    logMiss = logical(missingidx(:, idx));
                    alldata(~logMiss, idx) = ftsa.data{4}(~logMiss, idx);
                end
            end

            % Loop through each column then each row
            for dIdx = 1:ftsa.serscount
                for zIdx = 1:size(alldata,1)
                    if isnan(alldata(zIdx, dIdx)) & (zIdx ~= 1) %#ok
                        % If NaNs populate the first elements, leave them
                        % alone.
                        alldata(zIdx, dIdx) = alldata(zIdx-1, dIdx);
                    end
                end
            end

        otherwise
            error('Ftseries:fillts:invalidFILLMETHOD', ...
                'Invalid FILLMETHOD.');
    end

else
    if ~isempty(newdates)
        % if new dates were introduced
        for idx = 1:ftsa.serscount
            logMiss = logical(missingidx(:, idx));
            alldata(logMiss, idx) = constFill;
            alldata(~logMiss, idx) = newData(~logMiss, idx);
        end

    else
        % if no new dates were introduced
        for idx = 1:ftsa.serscount
            logMiss = logical(missingidx(:, idx));
            alldata(logMiss, idx) = constFill;
            alldata(~logMiss, idx) = ftsa.data{4}(~logMiss, idx);
        end
    end
end

% If the output is not supposed to be sorted, put the data back in the
% original order and append any new dates to the end of the object.
if ~sortmode
    % Sort the index of the sorted original.
    % Find the original dates in the list of all dates.
    % Get the index of the original dates in the list of all dates and get it in
    % order.
    [sorigidx, isorigidx] = sort(origidx); %#ok
    if timeData == 1
        [oldall, iold, iallold] = intersect(oldfts.data{3}+oldfts.data{5}, alldates);%#ok

    else
        [oldall, iold, iallold] = intersect(oldfts.data{3}, alldates); %#ok
    end
    olddatesidx = iallold(isorigidx);

    % if new dates exist, do the same as above to them.
    if exist('newdates', 'var') && ~isempty(newdates)
        [snewidx,  isnewidx]  = sort(isnd); %#ok
        [newall, inew, iallnew] = intersect(newdates, alldates); %#ok
        newdatesidx = iallnew(isnewidx);

    else
        newdatesidx = [];
    end

    % Get the order correctly.
    neworder = [olddatesidx(:); newdatesidx(:)];

    % Reorder the dates, times, and data.
    alldates = alldates(neworder);
    alldata  = alldata(neworder, :);

    if timeData == 1
        allTimes = allTimes(neworder);

    else
        allTimes = [];
    end
end % end of 'if ~sortmode'

% Up till now, if there was time data, alldates included the time info too.
% So now that all the calcs are done, remove the time data.
[Y2,M2,D2] = datevec(alldates);
alldates = datenum([Y2,M2,D2]);

% Create a FINTS object.
fts = fints;
fts.names       = ftsa.names;
fts.data{1}     = ['Filled ', ftsa.data{1}];  % desc
fts.data{2}     = 0;                          % freq
fts.data{3}     = alldates(:);                % dates
fts.data{4}     = alldata;                    % data
fts.data{5}     = allTimes;                   % times
fts.serscount   = ftsa.serscount;
fts.datacount   = size(alldata, 1);


% -------------------------------------------------------------------------
function datepnt = extractdates(datearg)
% DATEPNT extracts the dates.

if ischar(datearg)   % Index is date string(s).
    if size(datearg, 1)==1   % Index is date string or date string range.
        colonidx = findstr(datearg, '::');
        if isempty(colonidx)
            if findstr(datearg, ':')
                error('Ftseries:fillts:InvalidOperator', ...
                    'Please use :: operator instead of : operator.');
            end

            % Convert to serial dates.
            datepnt = datenum(char(datearg));

        else
            datepnts = char(datearg);
            if colonidx(1) == 1
                % Undocumented 'start' feature.
                daterow1 = fts.data{3}(1);

                % Convert to serial dates.
                daterow2 = datenum(datepnts(colonidx+2:end));

            elseif colonidx(1)+1 == length(datepnts)
                % Undocumented 'end' feature.

                % Convert to serial dates.
                datarow1 = datenum(datepnts(1:colonidx-1)); %#ok

                daterow2 = fts.data{3}(end);

            else
                % Convert to serial dates.
                daterow1 = (datepnts(1:colonidx-1));

                % Convert to serial dates.
                daterow2 = datenum(datepnts(colonidx+2:end));
            end

            datepnt = daterow1:daterow2;
        end

    else
        % Index is a date string matrix.

        % Convert to serial dates.
        datepnt = datenum(char(datearg));
    end

elseif iscell(datearg)
    % Index is a cell array of date strings.
    if size(datearg, 1) ~= 1 && size(datearg, 2) ~= 1
        error('Ftseries:fillts:VectorCellExpected', ...
            'Cell array must be a vector cell array.');
    end

    if size(datearg, 1) == 1 && size(datearg, 2) == 1
        datearg = datearg{:};
        colonidx = findstr(datearg, '::');
        if isempty(colonidx)
            if findstr(datearg, ':')
                error('Ftseries:fillts:InvalidOperator', ...
                    'Please use :: operator instead of : operator.');
            end

            % Convert to serial dates.
            datepnt = datenum(char(datearg));

        else
            datepnts = char(datearg);
            if colonidx(1) == 1
                % Undocumented 'start' feature.
                daterow1 = fts.data{3}(1);

                % Convert to serial dates.
                daterow2 = datenum(datepnts(colonidx+2:end));

            elseif colonidx(1)+1 == length(datepnts)
                % Undocumented 'end' feature.

                % Convert to serial dates.
                daterow1 = datenum(datepnts(1:colonidx-1));

                daterow2 = fts.data{3}(end);

            else
                % Convert to serial dates.
                daterow1 = datenum(datepnts(1:colonidx-1));

                % Convert to serial dates.
                daterow2 = datenum(datepnts(colonidx+2:end));
            end

            datepnt = daterow1:daterow2;
        end

    else
        % Convert to serial dates.
        datepnt = datenum(char(datearg{:}));
    end

elseif isnumeric(datearg)
    datepnt = datearg;
end

% -------------------------------------------------------------------------
function [outMethod, extrap] = methodabbrv(method)
% Generates the FILLMETHOD abbreviation.
%
% Inputs:
% method - FILLMETHOD abbreviation
% extrap - yes/no : 1/0
%
% Outputs:
% outMethod - abbreviation for the FILLMETHOD

% Default errors
msg.msg = '';
msg.id = '';

switch lower(strtrim(method))
    case {'linear', 'l'}
        outMethod = 'l';
        extrap = 0;

    case {'cubic', 'c'}
        outMethod = 'c';
        extrap = 0;

    case {'spline', 's'}
        outMethod = 's';
        extrap = 0;

    case {'nearest', 'n'}
        outMethod = 'n';
        extrap = 0;

    case {'pchip', 'p'}
        outMethod = 'p';
        extrap = 0;

    case {'linearExtrap', 'le'}
        outMethod = 'l';
        extrap = 1;

    case {'cubicExtrap', 'ce'}
        outMethod = 'c';
        extrap = 1;

    case {'splineExtrap', 'se'}
        outMethod = 's';
        extrap = 1;

    case {'nearestExtrap', 'ne'}
        outMethod = 'n';
        extrap = 1;

    case {'pchipExtrap', 'pe'}
        outMethod = 'p';
        extrap = 1;

    case {'zero', 'z'}
        outMethod = 'z';
        extrap = 0;

    otherwise
        outMethod = '';
        extrap = 0;
end

% [EOF]

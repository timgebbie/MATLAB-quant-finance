classdef hfts
    % HFTS class definition for High-Frequency Time-Series objects
    %
    % Allows both inhomogeneously sampled data as well as homogeneously
    % sampled data as set by the frequency property FREQ. For inhomogenous
    % data the frequency property is set to 'Unknown', this is the default
    % setting. The class allows the frequency to take on the value of
    % seconds or and minutes. The class allows resampling to uniform 
    % spacing that is not seconds or minutes and the frequency property 
    % takes on the value 'uniform'. The HFTS class allows frequencies 
    % lower than this; it is recommed that FINTS objects be used for 
    % frequencies lower than 1 minute. The class has a typecast method 
    % to FINTS objects. This type cast method will down-sampled the HFTS 
    % object to minutes and convert to a FINTS object.
    %
    % Table 1. Allowed FREQ values
    % +-------------+-----------------------+---------------------------+
    % | Frequency   | FREQ values           | Recommended Data class    |
    % +-------------+-----------------------+---------------------------+
    % | uniform     | 'uniform'             | HFTS (<1min) FINTS(>1min) |
    % | 1-second    | 's','Sec'             | HFTS                      | 
    % | 1-minute    | 'm','Min','1m','1Min' | *FINTS (see RESAMPLE/HFTS)|       
    % | 10-minute   | '10m','10Min'         | FINTS (see RESAMPLE/HFTS) | 
    % | 30-minute   | '30m','30Min'         | FINTS (see RESAMPLE/HFTS) | 
    % | 1-hour      | '1h','1Hour'          | FINTS (see RESAMPLE/HFTS) | 
    % | daily       | 'D','Daily'           | FINTS (see TODAILY)       | 
    % | weekly      | 'W','Weekly'          | FINTS (see TOWEEKLY)      | 
    % | monthly     | 'M','Monthly'         | FINTS (see TOMONTHLY)     | 
    % | quarterly   | 'Q','Quarterly'       | FINTS (see TOQUARTERLY)   | 
    % | semi-annual | 'S','Semi-annual'     | FINTS (see TOSEMI)        | 
    % | annual      | 'A','annual'          | FINTS (see TOANNUAL)      | 
    % | unknown     | 'U','unknown'         | HFTS(<1min),FINTS(>=1min) |
    % +-------------+-----------------------+---------------------------+
    % * FINTS decimates to 1-minute data by default.
    %
    % The object is constructed from ENTITIES and ITEMS. The object is
    % constructed so that each ENTITIES has uniquely enumerated ITEMS that
    % can be inhomogeneously sampled. Intitial ENTITIES are mapped into
    % SERIES in the object and the FIELDS of each SERIES are set to be the
    % ITEMS. When an object is merged, it is merge on the DATETIME field
    % over the ENTITIES. This then sets the ITEMS to be the SERIES and each
    % SERIES of a given ITEM with have the ENTITY names as the FIELDS. Each
    % SERIES is represented by a dataset object.
    % 
    %  
    % Table 2: MERGED and UN-MERGED HFTS objects
    % +--------------+----------------------------------------------------+
    % |UNMERGED @HFTS| ENTITY,ITEM ->@dataset of SERIES with fields FIELD |
    % +--------------+----------------------------------------------------+
    % | MERGED  @HFTS| ENTITY,ITEM ->@dataset of FIELD with fields SERIES |  
    % +--------------+----------------------------------------------------+
    % HFTS object aggregates datatset objects for SERIES with fields FIELD
    %
    % Data Management Sequence:
    % 1. Time-series Data Aggregation:
    %   1.1. Raw HFT data is loaded either from the FDS, TRTH or a .CSV file.
    %   1.2. The constructor converts each ticker to a DATASET object 
    %   1.3. AGGREGATE (hfts/aggregate) data to remove repeated simultaneous trades
    %
    % 2. Time-series Merging 
    %   2.1 MERGE (hfts/mergets) time-series into a single dataset object 
    %    per ITEM such as 'Price' and 'Volume'
    % 
    % 3. Time-series Downsampling (resampling)
    %   3.1. RESAMPLE time-series objects to a uniform resampling frequency. 
    %    After resampling the object is re-aggregated. Resampling is based
    %    on creating duplicate date-times in the object and the using the
    %    aggregation rules of AGGREGATE.
    %   3.2. RESAMPLE time-series objects to seconds and minutes.
    %   3.3. Type-cast time-series to a FINTS objects when the  minimum 
    %    sampling frequency is 1-minute. When type-cast a structure is 
    %    returned with a FINTS object for each SERIES in the object.
    %
    % Note 1: The HFTS class aggregates DATASET objects for each unique
    %   ticker when it is not a merged time-series. It aggregates DATASET
    %   objects for each unique field when it is an merged time-series.
    %   This changes the behaviour of RESAMPLE. One should RESAMPLE
    %   un-merged HFTS objects if one want to preserve FIELD uniques
    %   behaviour (for example sum 'volume' and decimate 'close').
    % Note 2: HFTS constructor expects fields 'RIC','DateL', and 'TimeL'.
    % 
    % References: This was based on the Chopper tools provided by Mathworks.
    %
    % See Also: FINTS, DATASET, HFTS/HFTS, MERGETS, AGGREGATE, RESAMPLE
    
    % Author: Tim Gebbie
    
    properties
        freq = 'unknown'; % can be unknown, seconds, minutes
    end
    properties (Access = private)
        spacing = NaN;
        hfdata = dataset;
    end   
    methods
        function ts = hfts(varargin)
            % hfts Constructor for hfts class
            %
            % HFTS = HFTS(DATA) DATA is a cell-array in relational format
            %   in the order of TICKERS,LOCALDATE,LOCALTIME,PRICE,VOLUME. 
            %   Expects the data to have a field for each STOCK where the 
            %   fieldname is the STOCK ticker. The fieldname does not have 
            %   to be the same as the populated ticker name in the data 
            %   cell-array.  
            %
            % HFTS = HFTS(DATA,ITEM) Only keep items in ITEMS. If ITEM is
            %   not set all avaliable unique ITEMS in DATA will be used.
            %   The order of ITEMS is preserved. All ITEMS should reflect
            %   in all the DATA sets.
            %
            % Example 1: Recommended constructor for 'Trade' data
            % >> ts = hfts(dataG,{'Price','Volume'}),
            % hfts
            %
            %  Properties:
            %   freq: 'unknown'
            %
            %  Methods
            %
            %	series : AGL, BIL
            %	fields : RIC, DateTime, Price, Volume
            %
            % Example 2: Default construction
            % >> ts
            % hfts
            %
            % Properties:
            %   freq: 'unknown'
            %
            % Methods
            %
            %	series : AGL, BIL
            %	fields : DateTime, MidPrice, Price, RIC, Type, Volume
            %
            % Note 1: The DATA structure can be prepared in two distinct
            %   ways. First, directly from the FDS, Second, using TRTH.
            % 
            % Method 1: From FDS using a valid database connection conn
            % 1.1. Bar Data
            %   >> data = fetchtrth(conn,{'AGLJ.J'},'Intraday 10Min',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);
            %
            %   data.AGL(1:5,:) =
            %
            %  Columns 1 through 10
            %    'RIC'       'DateL'         'TimeL'       'Type'              'Open'     'Last'     'No_Trades'    'VWAP'          'Volume'    'OpenBid'
            %    'AGLJ.J'    '2011-10-03'    '09:00:00'    'Intraday 10Min'    [27200]    [27300]    [       75]    [2.7203e+04]    [ 80748]    [  27800]
            %    'AGLJ.J'    '2011-10-03'    '09:10:00'    'Intraday 10Min'    [27300]    [27400]    [       80]    [2.7291e+04]    [ 41235]    [  27300]
            %    'AGLJ.J'    '2011-10-03'    '09:20:00'    'Intraday 10Min'    [27401]    [27370]    [       47]    [2.7413e+04]    [ 31591]    [  27384]
            %    'AGLJ.J'    '2011-10-03'    '09:30:00'    'Intraday 10Min'    [27370]    [27325]    [       82]    [2.7287e+04]    [101041]    [  27333]
            %
            %  Columns 11 through 17
            %    'CloseBid'    'No_Bids'    'OpenAsk'    'CloseAsk'    'No_Asks'    'High'    'Low'
            %    [   27300]    [   2388]    [  26999]    [   27349]    [   2388]    [ NaN]    [NaN]
            %    [   27383]    [   1046]    [  27349]    [   27445]    [   1046]    [ NaN]    [NaN]
            %    [   27333]    [   1033]    [  27445]    [   27370]    [   1033]    [ NaN]    [NaN]
            %    [   27290]    [   2151]    [  27370]    [   27325]    [   2151]    [ NaN]    [NaN]
            %
            % 1.2. Trade Data
            %   >> data = fetchtrth(conn,{'AGLJ.J','BILJ.J'},'Trade',[datenum('2-Oct-2011'), datenum('31-Jan-2012')])
            %
            %       AGL: {20278x7 cell}
            %       BIL: {18327x7 cell}
            %
            %   >> data.AGL =
            %
            %   'RIC'       'DateL'         'TimeL'       'Type'     'Price'    'Volume'    'MidPrice'
            %   'AGLJ.J'    '2011-12-15'    '09:00:28'    'Trade'    [29650]    [  4542]    [     NaN]
            %   'AGLJ.J'    '2011-12-15'    '09:00:31'    'Trade'    [29640]    [   300]    [     NaN]
            %   'AGLJ.J'    '2011-12-15'    '09:01:22'    'Trade'    [29650]    [     5]    [     NaN]
            %   'AGLJ.J'    '2011-12-15'    '09:01:31'    'Trade'    [29650]    [   378]    [     NaN]
            %
            % Method 2: Using TRTH using a valid TRTH connection r
            % 2.1. TRTH data
            %   >> data = trth2struct(r,'AGLJ.J',{'Price','Volume','Mid Price'},'2-Jan-2012','10-Jan-2012','TimeAndSales','Trade','JNB','EQU');
            %
            % Method 3: Using RMDS created real-time data
            % 3.1. RMDS data
            %   >> rconn = reuters(rc.session,rc.source,rc.id,[],1);
            %   >> [data,ts0] = fetchreuters(rconn,{'AGLJ.J','BILJ.J'},{'TRDPRC_1'});
            %   >> data = reuters2cell(ts0,{'TRDPRC_1','TRDVOL_1'},{'Price','Volume'});
            %   >> data = hfts(data).
            %  HFTS
            %   Properties:
            %   freq: 'unknown'
            %  METHOD
            %   series : AGL, BIL
            %   fields : DateTime, Price, RIC, Volume
            %   >> data.AGL
            %   ans = 
            %       DateTime      Price    RIC       Volume
            %       7.3497e+05    28352    AGLJ.J    45    
            %
            % Method 4: Create for TRTH CSV files (ensure that there is at
            %   least a 'DateTime' and 'Price' property)
            %  >> userpathstr = userpath;
            %  >> userpathstr(strfind(userpathstr,';'))=[];
            %  >> filename = fullfile(userpathstr,'Data','SFX','JTOPIALSIc1N34983617.csv');
            %  >> c = dataset('file',filename,'Delimiter',',');
            %  >> ts = hfts(c);
            %
            % See Also: HFTS/FINTS, HFTS.FREQ
            
            % Author: Tim Gebbie
            
            % Read file and create dataset
            % initial defaults 
            optargs = {{} {}};
            % now put these defaults into the valuesToUse cell array,
            optargs(1:nargin) = varargin;
            % Place optional args in memorable variable names
            [data, items0] = optargs{:};
            if ~isempty(items0)
                items = [{'RIC','DateTime'} items0];
            end
            % initialise frequency 
            ts.freq = 'unknown';
            if nargin==0
                % null constructor
            else
                switch class(data)
                    case 'struct'
                        tickers = fieldnames(data);
                        % find the unique items
                        if isempty(items0)
                            items = data.(tickers{1})(1,:);
                            for j=2:length(tickers)
                                items = unique([items data.(tickers{j})(1,:)]);
                            end
                            % remove 'DateL' and 'TimeL' and replace with
                            % 'DateTime' remove
                            items0 = setdiff(items,{'DateL','TimeL','Type'});
                            items = ['DateTime' items0];
                            % remove 'RIC' for series list
                            items0 = setdiff(items0,'RIC');
                        end
                        % fix names in anticipation of typecast to dataset
                        items = fixname(items);
                        items0 = fixname(items0);
                        % parse and typecast to dataset
                        for j=1:length(tickers)
                            data0 = data.(tickers{j});
                            % add dynamic property to object to aggregate tickers
                            tickersj0 = dataset({data0(2:end,:),data0{1,:}});
                            % Convert the ticker into a nominal array
                            tickersj0.RIC = nominal(tickersj0.RIC);
                            % get the field names
                            fieldsj0 = get(tickersj0,'VarNames');
                            % find the DateL and TimeL if they exists
                            [~,ia]=intersect({'DateL','TimeL'},fieldsj0);
                            % Convert the date/time fields into a numeric representation
                            if length(ia)==2
                                tickersj0.DateTime = datenum(tickersj0.DateL)+rem(datenum(tickersj0.TimeL),1);
                            elseif length(ia)==1
                                tickersj0.DateTime = datenum(tickersj0.DateL);
                            else
                                error('ftsdata:hfts','No instance of DateL or TimeL');
                            end
                            % Keep only the necessary fields
                            tickersj0 = tickersj0(:,items);
                            for i=1:length(items0)
                                % convert Prices to double matrices
                                tickersj0.(items0{i}) = cell2mat(tickersj0.(items0{i}));
                            end
                            % assign to data structure
                            data.(tickers{j})=tickersj0;
                        end
                        % assign property to object
                        ts.hfdata = data;
                    case 'dataset'
                         % sort by RIC 
                         s = get(data,'VarNames');
                         if any(ismember('x_RIC',s))
                             s{ismember(s,'x_RIC')} = 'RIC';
                         end
                         if any(ismember('Date_L_',s))
                             s{ismember(s,'Date_L_')} = 'DateL';
                         end
                         if any(ismember('Time_L_',s))
                             s{ismember(s,'Time_L_')} = 'TimeL';
                         end  
                         data = set(data,'VarNames',s);
                         % Add DateTime
                         if ~any(ismember('DateTime',s))
                             data.DateTime = datenum(data.DateL)+rem(datenum(data.TimeL),1);
                         end
                         series0 = data.RIC;
                         [series0,is] = sort(series0);
                         [series1,ia] = unique(series0,'last'); 
                         ia = [0;ia];
                         series = ric2tick(series1);
                         items = get(data,'VarNames');
                         % remove all the fields except the DateTime field
                         items0 = setdiff(items,{'DateL','TimeL','DateTime','Type','RIC'});
                         items = ['DateTime' items0];
                         data = data(:,items);
                         % sort the series names
                         for j=1:length(series)
                             data0.(series{j}) = data(is(ia(j)+1:ia(j+1)),:);
                         end          
                         % assign to data strucutre
                         ts.hfdata = data0;
                    otherwise
                        error('ftsdata:hfts','Incorrect Input Arguments or Empty data');
                end
            end
        end
        function ts = aggregate(ts)
            % AGGREGATE Remove duplicate time informatin and aggregate data
            %
            % See Also: HFTS/UNMERGEDAGGREGATE, HFTS/MERGEDAGGREGATE
            
            series = fieldnames(ts.hfdata);
            if isempty(intersect(series,{'Volume','Last','CloseBid','CloseAsk'}))
                ts = unmergedaggregate(ts);
            else
                ts = mergedaggregate(ts);
            end
                
        end % aggregate
        function ts = resample(varargin)
            % RESAMPLE Downsample the HFTS object
            %
            % TRD = RESAMPLE(TS,SPACING) SPACING in fractions of Hours.
            %   Reduces the time resolution of a time series, thereby 
            %   increasing the spacing between ticks. The spacing must be 
            %   specified in fractions of hours. Use this method with 
            %   AGGREGATE to aggregate all the resulting ticks that have 
            %   the same timestamp. The spacings times are by default
            %   FLOORED and set the resampled data to the START of the 
            %   spacing fractions.
            %
            % TRD = RESAMPLE(TS,SPACING,START) START is boolean TRUE to
            %   resample to start of bar, and FALSE to resample to the end 
            %   of the bar.
            %
            % TABLE 1: Resampling process
            % +---------------+--------------------------------------+ 
            % | Step          | Description                          |
            % +---------------+--------------------------------------+
            % | 1. Timestamp  | Compute new time-stamps at the new   | 
            % |               | spacings. All data within a given    | 
            % |               | given spacing is time-stamped at the | 
            % |               | START(END) of the the new spacings.  |
            % +---------------+--------------------------------------+
            % | 2. Aggregate  | The data is aggregated over the new  |
            % |               | time-stamps to produce data with     |
            % |               | unique time stamps.                  |
            % +---------------+--------------------------------------+
            % * This follows the TRTH convention. Modelling convention 
            % is to time-stamp at the Bar ends.
            %
            % Note 1: RESAMPLE on UN-MERGED time-series merges by field
            % type rules. RESAMPLE on MERGED time-series will decimate.
            %
            % Note 2: The prefered method is to set the frequency property.
            %
            % See Also: HFTS/HFTS, AGGREGATE, MERGETS
            
            % Author: Tim Gebbie
            
            ts = varargin{1};
             % initial defaults
            optargs = {ts 1/60 true};
            % now put these defaults into the valuesToUse cell array,
            optargs(1:nargin) = varargin;
            % place optional args in memorable variable names
            [ts, spacing0, barstart] = optargs{:};
            % find the series names
            series = fieldnames(ts.hfdata);
            for j=1:length(series)
                % Extract the components of the timestamp
                [y, m, d, H, M, S] = datevec(ts.hfdata.(series{j}).DateTime);
                % Calculate the fractional hour
                H = H + M/60 + S/3600;
                % Fix the hour to the nearest multiple of the spacing input
                if barstart
                  % start of the bar (For debugging( [H H1 M]) rename to H
                  H1 = floor((H+1000*eps)/spacing0)*spacing0;
                else
                  % end of the bar  
                  H1 = (ceil(((H-1000*eps)/spacing0)+1)-1)*spacing0; 
                end
                % Recompute the timestamps
                ts.hfdata.(series{j}).DateTime = datenum(y,m,d,H1,0,0);
            end
            % ensure that the resampled time-series has unique sample pts
            ts = aggregate(ts);
            % set the frequency property
            ts.freq = 'uniform';
            ts.spacing = spacing0;    
        end % resample
        function ts = mergets(ts)
            % MERGETS Merges all the HFT time-series in object on Time
            %
            % TS = MERGETS(TS) Combines all the HFT time-series onto the 
            %   same Date and Time range. The resulting time series has 
            %   timestamps that are the union of the timestamps of the 
            %   two original series. Any missing prices are represented 
            %   as NaN.
            %
            % This is part of the : 1. aggregate, 2. mergets approach.
            %
            % Note: To merge two HFTS objects see HFTS/MERGE
            %
            % See Also: HFTS/HFTS, AGGREGATE, RESAMPLE, MERGE
            
            % Author: Tim Gebbie
            
            series = fieldnames(ts.hfdata);
            % this can be modified using the union of get(ts.hfdata.(ticker),'VarNames')
            fields = {};
            for i=1:length(series)
                fields = unique([get(ts.hfdata.(series{i}),'VarNames') fields]);
            end
            % remove the DateTime as this is shared
            fields = setdiff(fields,'DateTime');
            % find all unique times in the object
            if ~isempty(series)
                alltimes = ts.hfdata.(series{1}).DateTime;
                if length(series)>1
                    for j=2:length(series)
                        % Find the union of time stamps
                        alltimes = union(alltimes,ts.hfdata.(series{j}).DateTime);
                    end
                    % extend all the time-series
                    ts = extend(ts, alltimes);
                    % merge the time-series
                    for j=1:length(series)
                        hfdata0j = ts.hfdata.(series{j});
                        seriesj = series{j};
                        for k=1:length(fields)
                            % slice the variable
                            fieldsk = fields{k};
                            % reduce set
                            hfdata0jk = hfdata0j(:,{'DateTime',fieldsk});
                            % Update the series names to be unique so that they can be merged
                            hfdata0jk = set(hfdata0jk,'VarNames',{'DateTime',seriesj});
                            % Use a Join function to combine datasets
                            if (j==1)
                                % initialise with reduced set 
                                hfdata1.(fieldsk) = hfdata0jk;
                            else
                                % merge on the dates
                                hfdata1.(fieldsk) = join(hfdata1.(fieldsk),hfdata0jk, 'DateTime');
                                hfdata1.(fieldsk) = sortrows(hfdata1.(fieldsk),'DateTime');
                            end
                        end
                    end
                end
            end
            % reset the object data with the homogenized merged data
            ts.hfdata = hfdata1;
        end % mergets
        function ts1=merge(ts1,ts2)
            % Merge Merge two HFTS objects if they are compatible
            %
            % TS = MERGE(TS1,TS2) Merge TS1 and TS2 both HFTS objects.
            %   This is full-outer join on shared series names with shared
            %   field names.
            %
            % Note: To merge time-series of an HFTS object use HFTS/MERGETS 
            %
            % See Also: MERGETS,DATASET/JOIN,DATASET/HORZCAT,DATASET/VERTCAT
            
            % Author: Tim Gebbie
            
            series1 = fieldnames(ts1.hfdata);
            series2 = fieldnames(ts2.hfdata); 
            % union of series1 and series2
            [series,~]=union(series1,series2);
            % intersection of series1 and series2
            [series12,~]=intersect(series1,series2);
            % intersection of union with intersection
            [~,s12] = intersect(series,series12);
            % series2 not in series1
            [~,ns21] = setdiff(series2,series1);
            for j=1:length(series)
                if any(s12==j)
                    % intersection in series names
                    fn1 = get(ts1.hfdata.(series{j}),'VarName');
                    fn2 = get(ts2.hfdata.(series{j}),'VarName');
                    % find the key names
                    [keynames,~] = intersect(fn1,fn2);
                    [~,i1] = setdiff(fn1,keynames);
                    [~,i2] = setdiff(fn2,keynames);
                    % use dataset full-outer join method
                    ts1.hfdata.(series{j}) = join(ts1.hfdata.(series{j})(:,[keynames fn1(i1)]), ...
                        ts2.hfdata.(series{j})(:,[keynames fn2(i2)]), ...
                        'key',keynames, ...
                        'Type','outer', ...
                        'MergeKeys',true);
                elseif any(ns21==j)
                    % no intersection (TBDL add missing colums to ts2)
                    ts1.hfdata.(series{j}) = ts2.hfdata.(series{j});
                else
                    % no intersection (TBDL add missing colums to ts1)
                    ts1.hfdata.(series{j}) = ts1.hfdata.(series{j});
                end
            end
        end % merge HFTS method
        function ts = extend(ts, newdates)
            % EXTENDTS fills in the missing times in a HF time-series
            %
            % See Also: HFTS
            
            % Author: Tim Gebbie
            
            series = fieldnames(ts.hfdata);
            % condition new dates
            newdates = newdates(:);
            % NaN data series list
            nanlist = {'Price','Last','Open','High','Low'};
            for j=1:length(series)
                % reference the data
                seriesj0 = ts.hfdata.(series{j});
                % Add missing dates using dataset object methods
                ts.hfdata.(series{j}).DateTime = [seriesj0.DateTime; setdiff(newdates, seriesj0.DateTime)];
                % Set the price for all times with 0 volume to NaN
                fieldsj = get(seriesj0,'VarName');
                if ~isempty(intersect(fieldsj,'Volume'))
                    ind = (ts.hfdata.(series{j}).Volume==0);
                    [~,bi(1,:)]=intersect(fieldsj,nanlist);
                    for k=bi
                        ts.hfdata.(series{j}).(fieldsj{k})(ind) = NaN;
                    end
                end
            end
        end
        function h=plot(ts, datetimes, window)
            % PLOT plots sections of a time series.
            %
            % H = PLOT(TS,DATETIMES,WINDOW) WINDOW is in fractional 
            %   units of days, DATETIME are date-times and TS is an HFTS
            %   object.
            %
            % It accepts a vector of dates that form the center of each
            % plot and a window of time duration around those dates. The
            % windows are centered at 12:00 PM local time for the data.
            %
            % See Also: DATETICK
            
            % Author: Tim Gebbie
            
            % aggregate HFTS object that is unmerged
            % Convert dates to a numeric representation
            datetimes0 = datenum(datetimes);
            % Lower and upper limits of the windows centred at noon
            ld = datetimes0 - (window/2) + 0.5;
            ud = datetimes0 + (window/2) + 0.5;
            n = length(datetimes0);
            series = fieldnames(ts.hfdata);
            h = zeros(n,1);
            for i=1:length(series)
                figure;
                for m = 1:n% for each specified date
                    h(m)=subplot(n, 1, m);
                    fields = get(ts.hfdata.(series{i}),'VarName');
                    % remove DateTime and data that is not double valued
                    fields = setdiff(fields,'DateTime');
                    % reset the value and seriesnames for the fints object
                    fieldtype = false(size(fields));
                    for j=1:length(fields)
                        fieldtype(j) = isa(ts.hfdata.(series{i}).(fields{j}),'double');
                    end % fields
                    datetimes0 = ts.hfdata.(series{i}).DateTime;
                    % get the date index
                    ind = (datetimes0>ld(m)) & (datetimes0<ud(m));
                    % pre-allocate for speed
                    value = nan(sum(ind),sum(fieldtype));
                    seriesname = cell(1,sum(fieldtype));
                    fieldtype = find(fieldtype);
                    if ~isempty(fieldtype)
                        % populate the double valued data
                        p = 0;
                        % single subscript reference
                        valuei0 = ts.hfdata.(series{i})(ind,:);
                        for k=fieldtype
                            p = p + 1;
                            value(:,p) =  valuei0.(fields{k});
                            seriesname(:,p) = fields(k);
                        end % allowed fields
                        datetimes = datetimes0(ind);
                        plot(datetimes,value); % Plot the subset of data
                        legend(seriesname,'Location','NorthWest');
                        title(series{i});
                        xlabel('Date-Times');
                        ylabel('Fields');
                        if window < 1
                            % times only
                            dateform = 13;
                        elseif window < 2
                            % days and times
                            dateform = 'ddd HH:MM';
                        elseif window < 5
                            % month and days
                            dateform = 'ddd HH:MM';
                        elseif window < 20
                            % months
                            dateform = 'dd HH:MM';
                        else
                            dateform = 'mmm.dd';
                        end
                        datetick('x',dateform,'keepticks'); % Show date ticks on the X - axis
                    end
                end % series
            end % dates
        end
        function f = subsref(ts,s)
            % HFTS.SUBSREF Subscript reference HFTS object
            %
            % The properties FREQ and SERIES can be subscript referenced.
            % The SERIES property is a dynamics property based on the state
            % of the object. If the object has been merged then the series
            % are the ITEMS in the orginal data, e.g. Price and Volume:
            % >> ts
            % hfts
            %
            %  Properties:
            %    freq: 'unknown'
            %
            %  Methods
            %
            %	series : Price, Volume
            %	fields : DateTime, AGL, BIL
            %
            % >> ts.Price(1:2,:)
            % ans =
            %   DateTime      AGL    BIL
            %   7.3485e+05    NaN    23949
            %   7.3485e+05    NaN    23902
            %
            % >> ts.Volume(1:2,:)
            % ans =
            %   DateTime      AGL    BIL
            %   7.3485e+05    0      4778
            %   7.3485e+05    0        50
            %
            % If the object has not been merged then SERIES are the ticker
            % names of the ENTITIES in the original data e.g.
            % >> ts
            % hfts
            %
            % Properties:
            %   freq: 'unknown'
            %
            % Methods
            %
            %   series : AGL, BIL
            %   fields : RIC, DateTime, Price, Volume
            %
            % >> ts.AGL(1:2,:)
            % ans =
            %  RIC       DateTime      Price    Volume
            %   AGLJ.J    7.3485e+05    29650    4542
            %   AGLJ.J    7.3485e+05    29640     300
            %
            % >> ts.AGL.DateTime(1:2,:)
            %   ans =
            %       1.0e+05 *
            %           7.3485
            %           7.3485
            %
            % See Also:
            
            % Author: Tim Gebbie
            
            switch s(1).type
                case '.'
                    % A reference to a variable or a property.  Could be any sort of subscript
                    % following that.  Row names for () and {} subscripting on variables are
                    % inherited from the dataset.
                    varName = s(1).subs;
                    switch varName
                        case 'freq'
                            f=ts.freq;
                        case 'series'
                            f=fieldnames(ts.hfdata);
                        otherwise
                            if size(s,2)>1
                                % new input string
                                s = s(2:end);
                                % pass to aggregated class
                                f = subsref(ts.hfdata.(varName),s);
                            else
                                f = ts.hfdata.(varName);
                            end
                    end
                otherwise
                    error('ftsdata:hfts:subsref','Incorrect reference');
            end
        end
        function ts = subsasgn(ts,s,b)
            % SUBSASGN Assign HFTS object properties
            %
            % FREQ can be assigned 's','m', or 'u'
            
            % Author: Tim Gebbie
            
            switch s(1).type
                case '.'
                    varName = s(1).subs;
                    switch varName
                        case 'freq'
                            ts.freq = b;
                            % resample based on freq
                            switch ts.freq
                                case {'unknown','u','U'}
                                    % do nothing
                                case {'seconds','s'}
                                    % compute spacing in fractions of hours
                                    ts = resample(ts,1/3600);
                                    ts.freq = 'seconds';
                                case {'minutes','m'}
                                    % compute spacing in fractions of hours
                                    ts = resample(ts,1/60);
                                    ts.freq = 'minutes';
                                otherwise
                                    error('ftsdata:hfts:subsasgn','Incorrect assignment');
                            end
                        otherwise
                            error('ftsdata:hfts:subsasgn','Incorrect assignment');
                    end
                otherwise
                    error('ftsdata:hfts:subsasgn','Incorrect assignment');
            end
        end
        function display(ts)
            % DISPLAY Display a High-Frequency Time-series object
            %
            % See Also: DISP, 
            
            % Author: Tim Gebbie
            
            disp(ts);
            if ~isempty(ts.hfdata)
                series = fieldnames(ts.hfdata);
                fprintf('\tseries : ');
                [m]=length(series);
                for j=1:m-1
                    fprintf('%s, ',series{j});
                end
                fprintf('%s\n',series{m});
                fprintf('\tfields : ');
                fields = get(ts.hfdata.(series{1}),'VarNames');
                for j=1:length(fields)-1
                    fprintf('%s, ',fields{j});
                end
                fprintf('%s\n',fields{j+1});
            end
        end
        function fts = fints(varargin)
            % FINTS Convert to FINTS object for intervals greater than 1-minute
            %
            % FTS = FINTS(TS) For TS of class HFTS. This will downsample to 
            %   minutes. It will not correctly aggregate the time-series. 
            %   To correctly aggregate first resample to 1-minute by 
            %   setting the FREQ property to 'minute' or RESAMPLE to 
            %   1/60 of an hour.
            %
            % FTS = FINTS(TS,SERIES) Only type-convert series SERIES.
            %   Here SERIES is
            % See Also: HFTS/HFTS
            
            % Author: Tim Gebbie
            
            ts = varargin{1};
            % default series to include
            series = fieldnames(ts.hfdata);
             % initial defaults
            optargs = {ts series};
            % now put these defaults into the valuesToUse cell array,
            optargs(1:nargin) = varargin;
            % place optional args in memorable variable names
            [ts, series] = optargs{:};
            % type-convert
            if ~any(ismember({'minutes','m'},ts.freq)),
                warning('ftsdata:hfts:fints','HFTS object freq is not MINUTES; may be incorrectly aggregated');
            end
            for i=1:length(series)
                fields = get(ts.hfdata.(series{i}),'VarName');
                % remove DateTime and data that is not double valued
                fields = setdiff(fields,'DateTime');
                % reset the value and seriesnames for the fints object
                fieldtype = false(size(fields));
                for j=1:length(fields)
                    fieldtype(j) = isa(ts.hfdata.(series{i}).(fields{j}),'double');
                end
                % get the datetime range
                datetimes = ts.hfdata.(series{i}).DateTime;
                % pre-allocate for speed
                value = nan(length(datetimes),sum(fieldtype));
                seriesname = cell(1,sum(fieldtype));
                fieldtype = find(fieldtype);
                % populate the double valued data
                p = 0;
                valuei0 = ts.hfdata.(series{i});
                if isempty(fieldtype);
                    fts.(series{i}) = fints;
                else
                    for k=fieldtype
                        p = p + 1;
                        value(:,p) =  valuei0.(fields{k});
                        seriesname(:,p) = fields(k);
                    end
                    fts.(series{i}) = fints(datetimes,value,seriesname,'U',series{i});
                end
            end
        end
        function ts = zero2nan(varargin)
            % ZERO2NAN Replace Zeros with NAN
            %
            % TS = ZERO2NAN(TS) All zeros in series replaced with NaN
            %
            % See Also: INF2NAN, FILLTS
            
            warnig('ftsdata:hfts','Untested TBDL');
            % initial varagin
            ts = varargin{1};
            % get all the series names
            series = fieldnames(ts.hfdata);
            for i=1:length(series)
                fields = get(ts.hfdata.(series{i}),'VarName');
                % remove DateTime and data that is not double valued
                fields = setdiff(fields,'DateTime');
                % reset the value and seriesnames for the fints object
                fieldtype = false(size(fields));
                for j=1:length(fields)
                    fieldtype(j) = isa(ts.hfdata.(series{i}).(fields{j}),'double');
                end
                fieldtype = find(fieldtype);
                % populate the double valued data
                valuei0 = ts.hfdata.(series{i});
                for k=fieldtype
                    % get the data
                    valueik =  valuei0.(fields{k});
                    % fill in the missing data
                    valueik(valueik==0) = NaN;
                    % can reassign data fields as length has not changed
                    ts.hfdata.(series{i}).(fields{k})=valueik;
                end % is double         
            end % for i   
        end
        function ts = fillts(varargin)
            % FILLTS Fill in missing data in HFTS object
            %
            % TS = FILLTS(TS) use INTERP1 fill types with default 'linear'
            %
            % TS = FILLTS(TS,TYPE) us fill type TYPE.
            %
            % See Also: INTERP1, ZEROORDERHOLD
            
            % Author: Tim Gebbie
            
            % initial varagin
            ts = varargin{1};
            % initial defaults
            optargs = {ts 'linear'};
            % now put these defaults into the valuesToUse cell array,
            optargs(1:nargin) = varargin;
            % Place optional args in memorable variable names
            [ts, type] = optargs{:};
            % get all the series names
            series = fieldnames(ts.hfdata);
            for i=1:length(series)
                fields = get(ts.hfdata.(series{i}),'VarName');
                % remove DateTime and data that is not double valued
                fields = setdiff(fields,'DateTime');
                % reset the value and seriesnames for the fints object
                fieldtype = false(size(fields));
                for j=1:length(fields)
                    fieldtype(j) = isa(ts.hfdata.(series{i}).(fields{j}),'double');
                end
                fieldtype = find(fieldtype);
                % get the datetime range
                datetime0 = ts.hfdata.(series{i}).DateTime;
                % populate the double valued data
                valuei0 = ts.hfdata.(series{i});
                for k=fieldtype
                    % get the data
                    valueik0 =  valuei0.(fields{k});
                    switch type
                        case 'z'
                            % zero-order hold
                            [n,~]=size(valueik0);
                            for zi = 1:n % row
                                if isnan(valueik0(zi,1)) & (zi ~= 1) %#ok
                                    % If NaNs populate the first elements, leave them alone.
                                    valueik0(zi,1) = valueik0(zi-1,1);
                                end
                            end
                            valueik = valueik0;
                        otherwise
                            % interpolate
                            id = isnan(valueik0);
                            if sum(id)<2
                                valueik = valueik0;
                            else
                                % only interpolate the data if not all data is missing
                                valueik = interp1(datetime0(id), valueik0(id), datetime0, type);
                            end
                    end
                    % can reassign data fields as length has not changed
                    ts.hfdata.(series{i}).(fields{k})=valueik;
                end % is double         
            end % for i
        end
        function f = fts2mat(ts)
            % FTS2MAT Time-series to Matrix
            %
            % M = FTS2MAT(TS) Type cast to data matrix. For N fields and M
            %   series and T datetimes. M will be a TxNxM double value
            %   matrix. The first column M(:,1,:) is the DateTime column.
            %
            % See Also: FINTS/FTS2MAT, DATASET/DOUBLE
            
            series = fieldnames(ts.hfdata);
            m = ones(length(series),1);
            n = ones(length(series),1);
            for i=1:length(series)
                [m(i),n(i)]=size(ts.hfdata.(series{i}));
            end
            f = nan(max(m),max(n),i);
            for i=1:length(series)
                f(1:m(i),1:n(i),i) = double(ts.hfdata.(series{i}));
            end
            if i==1
                f = squeeze(f);
            end
        end
        function cm = cellmat(ts)
            % CELLMAT Convert HF Time-series to Cell Matrix
            %
            % CM = CELLMAT(TS) Type cast to cell-matrix. For N fields and M
            %   series and T datetimes. M will be a (TxN)xM cell-mat. The 
            %   first column M(:,1,:) is the DateTime column.
            %
            % See Also: FINTS/FTS2MAT, DATASET/DOUBLE
            
            series = fieldnames(ts.hfdata);
            % get all the unique field names
            fields = {};
            for i=1:length(series)
               fields = unique([fields get(ts.hfdata.(series{i}),'VarNames')]);
            end
            for i=1:length(series)
                seriesi = ts.hfdata.(series{i});
                fieldsi = get(seriesi,'VarNames');
                cmi = cell(size(seriesi,1),size(seriesi,2));
                if ~isempty(intersect(fieldsi,fields))
                    for j=1:length(fields)
                        seriesij = seriesi.(fields{j});
                        switch class(seriesij)
                            case 'double'
                                cmi(:,j)=num2cell(seriesij);
                            case 'char'
                                % string
                                cmi(:,j)=cellstr(seriesij);
                            otherwise
                                cmi(:,j)= seriesij;
                        end
                    end % for j
                    cm.(series{i})=[fields ;cmi];
                end
            end % for i
        end
        function ts = nanfreets(ts)
            % NANFREETS Remove rows with missing data in each series
            %
            % See Also: HFTS/FILLTS
            
            % Author: Tim Gebbie
           
            series = fieldnames(ts.hfdata);
            for i=1:length(series)
                fields = get(ts.hfdata.(series{i}),'VarName');
                % remove DateTime and data that is not double valued
                fields = setdiff(fields,'DateTime');
                % reset the value and seriesnames for the fints object
                fieldtype = false(size(fields));
                for j=1:length(fields)
                    fieldtype(j) = isa(ts.hfdata.(series{i}).(fields{j}),'double');
                end
                % pre-allocate for speed
                value0 = nan(length(ts.hfdata.(series{i}).DateTime),sum(fieldtype));
                fieldtype = find(fieldtype);
                % populate the double valued data
                p = 0;
                valuei0 = ts.hfdata.(series{i});
                for k=fieldtype
                    p = p + 1;
                    value0(:,p) =  valuei0.(fields{k});
                end
                % removing all NaN rows
                ind = any(isnan(value0),2);
                if (sum(ind)==size(ind,1))
                    warning('ftsdata:hfts:removets','All rows are NaN valued for %s',series{i});
                end
                % re-assign the data
                ts.hfdata.(series{i})=valuei0(~ind,:);
            end % for i          
        end
        function ts = buysell(ts)
            % BUYSELL Create Buy-Sell variables from the price changes
            %
            % TS = BUYSELL(TS) Creates the variable BuySell indicator 
            %   function from the Price, Volume, Bid and Ask. The MidPrice 
            %   is computed from the Bid and Ask. If a new Price is above 
            %   the Mid-Price it is treated as a buy intiated transaction, 
            %   otherwise it is treated as Sell initiated transaction. The 
            %   volume is then sorted into either VolBuy or VolSell using 
            %   the indicator function. The HFTS object is converted to at
            %   least 1 minute bars if it has not already been typecast to
            %   uniformly sampled time. Three new fields are included:
            %   VolBuy, VolSell and BuySell.
            %
            % Note 1: this currently uses bar data 'CloseBid','CloseAsk'
            % this needs to be update to use live tick data.
            %
            % See Also: HFTS/VPIN
            
            % state of the class
            series = fieldnames(ts.hfdata);
            if isempty(intersect(series,{'Volume','Last','CloseBid','CloseAsk'}))
                % UNMERGED (per entity)
                for j=1:length(series)
                    % buysell indicator function for all trades bars or ticks
                    last = ts.hfdata.(series{j}).Last;
                    bid  = ts.hfdata.(series{j}).CloseBid;
                    ask  = ts.hfdata.(series{j}).CloseAsk;
                    vol  = ts.hfdata.(series{j}).Volume;
                    % create the indicator function
                    buysell = sign(last - 0.5 * (bid+ask));
                    sellvol = zeros(size(buysell));
                    buyvol = zeros(size(buysell));
                    % create the sequence of buy and sell volumes
                    xip = (buysell==1);
                    xim = (buysell==-1);
                    buyvol(xip) = vol(xip);
                    sellvol(xim) = vol(xim);
                    % create new dataset object
                    buysellj=mat2dataset([buysell(:),buyvol(:),sellvol(:)]);
                    % reset variable names
                    buysellj.Properties.VarNames = {'BuySell','BuyVol','SellVol'};
                    % add on a new field 
                    ts.hfdata.(series{j}) = horzcat(ts.hfdata.(series{j}),buysellj);
                end
            else
                % MERGED (per item)
                fields = get(ts.hfdata.(series{1}),'VarName');
                % remove DateTime and data that is not double valued
                fields = setdiff(fields,'DateTime');
                % the size of the new data sets
                [n,m]=size(ts.hfdata.('Last'));
                % creat the new variables
                buyvol = zeros(n,m-1);
                sellvol = zeros(n,m-1);
                buysell = zeros(n,m-1);
                for j=1:length(fields)
                    % buysell indicator function for all trades bars or ticks
                    last = ts.hfdata.('Last').(fields{j});
                    bid  = ts.hfdata.('CloseBid').(fields{j});
                    ask  = ts.hfdata.('CloseAsk').(fields{j});
                    vol  = ts.hfdata.('Volume').(fields{j});
                    % create the indicator function
                    buysell(:,j) = sign(last - 0.5 * (bid+ask));
                    % create the sequence of buy and sell volumes
                    xip = (buysell(:,j)==1);
                    xim = (buysell(:,j)==-1);
                    buyvol(xip,j) = vol(xip);
                    sellvol(xim,j) = vol(xim);
                end
                % add on the time fields
                buyvol = [ts.hfdata.('Last').DateTime,buyvol];
                sellvol = [ts.hfdata.('Last').DateTime,sellvol];
                buysell = [ts.hfdata.('Last').DateTime,buysell];
                % create the new fields
                ts.hfdata.('BuyVol')=mat2dataset(buyvol);
                ts.hfdata.BuyVol.Properties.VarNames = get(ts.hfdata.Last,'VarNames');
                ts.hfdata.('SellVol')=mat2dataset(sellvol);
                ts.hfdata.SellVol.Properties.VarNames = get(ts.hfdata.Last,'VarNames');
                ts.hfdata.('BuySell')=mat2dataset(buysell);
                ts.hfdata.BuySell.Properties.VarNames = get(ts.hfdata.Last,'VarNames');
            end % series-fields vs. fields-series
        end % buy-sell
        function vpin=vpin(varargin)
            % VPIN Value Synchronized Probability of Informed Trading (VSPIN)
            %
            % VPIN = VPIN(TS) For HFTS object TS. Provide VPIN as a
            %   sequence over 1 minute bars or to the nearest sampling
            %   frequency within the HFTS object. The method requires that
            %   the object has Volume, Price and DateTime. It is required
            %   that the object has been type cast to a uniformly sampled
            %   frequency.
            %
            % See Also: HFTS/BUYSELL
            
            % Flow Toxicity and Liquidity in a High Frequency World
            % (February 20, 2012) Easley, David, Lopez de Prado, Marcos
            % and O'Hara, Maureen, . Review of Financial Studies, Vol. 25,
            % No. 5, pp. 1457-1493, 2012.. Available at SSRN:
            % http://ssrn.com/abstract=1695596 or
            % http://dx.doi.org/10.2139/ssrn.1695596
            %
            % OPTIMAL EXECUTION HORIZON David Easle, Marcos M. López, Maureen O’Hara (2012)
            
            vpin = [];
            
        end % vpin
        function ts=tick2ret(varargin)
            % TICK2RET Compute returns for HFTS object
            %
            % TS = TICK2RET(TS)
            %
            % TS = TICK2RET(TS,TYPE)
            %
            % TS = TICK2RET(TS,TYPE,SCALING)
            %
            % Table 1: Return Types
            % +---------------+--------------------+------------------+
            % | TYPE          | METHOD             | DESCRIPTION      |
            % +---------------+--------------------+------------------+
            % |'Geometric'**  | DIFF(LN(P))        | LN(P(T)/P(T-1))  |
            % |'PriceRelative'| EXP(DIFF(LN(P))    | P(T)/P(T-1)      |
            % |'Arithmetic'   | EXP(DIFF(LN(P))-1) | (P(T)/P(T-1))-1  |
            % +---------------+--------------------+------------------+
            % Table 1: Scaling Types
            % +---------------+------------------------------------+
            % | SCALING       | DESCRIPTION                        |
            % +---------------+------------------------------------+
            % |'TickTime'*    | Rescaled by the time-change (tau)  |
            % |               | between ticks. This homogenises    |          
            % |               | returns in terms of the rate of    |
            % |               | trading.[Per Minutes (Ret/(24*60)] |
            % |'DataTime'**   | No rescaling. For uniform returns  |
            % |               | resample the data to Bar data      |
            % |               | first.                             |
            % +---------------+------------------------------------+
            % * P = P_0 EXP(RT) <=> P = P_0 EXP((R_0/TAU) T)
            % ** Default value
            %
            % See Also: NANFREETS, RESAMPLE, FILLTS
            
            % Author: Tim Gebbie
            
            % Note : UNTESTED / FIXME
            
            % initial varagin
            ts = varargin{1};
            % initial defaults
            optargs = {ts 'geometric' 'calendartime'};
            % now put these defaults into the valuesToUse cell array,
            optargs(1:nargin) = varargin;
            % assign the values
            [ts, type, scaling] = optargs{:};
            
            warning('ftsdata:hfts:tick2ret','Untested');
            series = fieldnames(ts.hfdata);
            for i=1:length(series)
                fields = get(ts.hfdata.(series{i}),'VarName');
                % remove DateTime and data that is not double valued
                fields = setdiff(fields,'DateTime');
                % reset the value and seriesnames for the fints object
                fieldtype = false(size(fields));
                for j=1:length(fields)
                    fieldtype(j) = isa(ts.hfdata.(series{i}).(fields{j}),'double');
                end
                % pre-allocate for speed
                fieldtype = find(fieldtype);
                % populate the double valued data
                p = 0;
                valuei0 = ts.hfdata.(series{i});
                for k=fieldtype
                    p = p + 1;
                    value0k =  valuei0.(fields{k});
                    % price fluctuations
                    value0k = [0; diff(log(value0k))];
                    switch lower(type)
                        case 'geometric'
                        case 'pricerelative'
                            value0k = exp(value0k);
                        case 'arithmetic'
                            value0k = exp(value0k)-1;
                        otherwise
                            error('ftsdata:hfts:tick2ret','Unrecognised scaling');
                    end
                    % price fluctuation scaling
                    switch lower(scaling)
                        case 'ticktime'
                            % time increments
                            deltat0k = diff(ts.hfdata.(series{i}).DateTime);
                            % rescale the returns by time difference
                            % (fraction of days)
                            value0k = (value0k ./ [1; deltat0k]);
                            % convert to per-minute (fraction of minutes)
                            value0k = value0k / (24*60);
                        case 'calendartime'
                        otherwise
                            error('ftsdata:hfts:tick2ret','Unrecognised scaling');
                    end
                    % update the values
                    valuei0.(fields{k}) = value0k;
                end
                % create the new fields
                ts.hfdata.([series{i} 'Return'])=valuei0;
                % remove the olds fields
                ts.hfdata = rmfield(ts.hfdata,series{i});
            end % for i
        end
    end % method
end % classdef
%% Utility functions / methods
function ts = unmergedaggregate(ts)
% UNMERGEDAGGREGATE Remove duplicate time information
%
% TS = UNMERGEDAGGREGATE(TS) TS is an un-merged HFTS object
%
% See Also: HFTS/HFTS, MERGETS, EXTEND, RESAMPLE

% Author: Tim Gebbie

% Aggregation list default
% Find all unique timestamps and their indices
series = fieldnames(ts.hfdata);
% only aggregate if class has not already been aggregated
for j=1:length(series)
    % sort the data first
    [~,is] = sort(ts.hfdata.(series{j}).DateTime);
    % #1: SORTED in ascending order
    % -------------------------------------------------------
    ts.hfdata.(series{j}) = ts.hfdata.(series{j})(is,:);
    % ------------------------------------------------------
    % [~,ia]= first IA (does not use 'stable')
    [dt0,ia] = unique(ts.hfdata.(series{j}).DateTime);
    % size
    [m0,~]=size(ts.hfdata.(series{j}).DateTime);
    % initialise variables
    volume0 = nan(size(dt0));
    field0 = nan(size(dt0));
    % the first count index
    inds = [ia;m0];
    % save the original dataset for aggregation
    series0j = ts.hfdata.(series{j});
    % #2: DECIMATE the dataset to last unique date-times
    % FIRST use [ia], LAST use [ia(2:end)-1;end]]
    % requires the DATETIME to be sorted (see above)
    % -------------------------------------------------------
    ts.hfdata.(series{j}) = ts.hfdata.(series{j})([ia(2:end)-1;end],:);
    % ------------------------------------------------------
    % get all the fields
    fieldsj = get(ts.hfdata.(series{j}),'VarNames');
    % #2: re-populate decimated fields if data-rule exists
    for k=1:length(fieldsj)
        fieldjk0 = field0;
        switch lower(fieldsj{k})
            case {'price','midprice','vwap','mtm_price','buysell'}
                if isempty(intersect(fieldsj,'Volume'))
                    % average if there is no volume present
                    for i = 1:length(ia) % Loop over each unique time index
                        ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                        fieldjk0(i) = nanmean(series0j.(fieldsj{k})(ind));
                    end
                else
                    % the volume weighted sum if there is Volume
                    for i = 1:length(ia) % Loop over each unique time index
                        ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                        volume0(i) = nansum(series0j.Volume(ind)); % may need to NaN --> 0
                        fieldjk0(i) = nansum(series0j.(fieldsj{k})(ind) .* series0j.Volume(ind))/volume0(i);
                    end
                end
                ts.hfdata.(series{j}).(fieldsj{k}) = fieldjk0;
            case {'volume','no_trades','no_bids','no_asks','buyvol','sellvol'}
                % sum over intervals
                for i = 1:length(ia) % Loop over each unique time index
                    ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                    fieldjk0(i) = sum(series0j.(fieldsj{k})(ind));
                end
                ts.hfdata.(series{j}).(fieldsj{k}) = fieldjk0;
            case {'openask','open','openbid'}
                % decimate at the beginning of the interval
                for i = 1:length(ia) % Loop over each unique time index
                    ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                    fieldjk0(i) = series0j.(fieldsj{k})(ind(1));
                end
                ts.hfdata.(series{j}).(fieldsj{k}) = fieldjk0;
            case {'high'}
                % find the maximum in the interval
                for i = 1:length(ia) % Loop over each unique time index
                    ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                    fieldjk0(i) = nanmax(series0j.(fieldsj{k})(ind));
                end
                ts.hfdata.(series{j}).(fieldsj{k}) = fieldjk0;
            case {'low'}
                % find the minimum in the interval
                for i = 1:length(ia) % Loop over each unique time index
                    ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                    fieldjk0(i) = nanmin(series0j.(fieldsj{k})(ind));
                end
                ts.hfdata.(series{j}).(fieldsj{k}) = fieldjk0;
            case {'closeask','close','closebid','last','theoask','theobid','theoprc'}
                % decimate at end of interval (can remove loop)
                for i = 1:length(ia) % Loop over each unique time index
                    ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                    fieldjk0(i) = series0j.(fieldsj{k})(ind(end));
                end
                ts.hfdata.(series{j}).(fieldsj{k}) = fieldjk0;
            otherwise
                % decimate (at end) align with datetime
        end
    end
end
end % unmerged aggregate
function ts = mergedaggregate(ts)
% MERGEDAGGREGATE Remove duplicate time information
%
% TS = MERGEDAGGREGATE(TS) TS is a merged HFTS object
%
% See Also: HFTS/HFTS, MERGETS, EXTEND, RESAMPLE

% Find all unique timestamps and their indices
series = fieldnames(ts.hfdata);
% only aggregate if class has not already been aggregated
for j=1:length(series)
    % sort the data first
    [~,is] = sort(ts.hfdata.(series{j}).DateTime);
    % #1: SORTED in ascending order
    % -------------------------------------------------------
    ts.hfdata.(series{j}) = ts.hfdata.(series{j})(is,:);
    % ------------------------------------------------------
    % [~,ia]= first IA (does not use 'stable')
    [~,ia] = unique(ts.hfdata.(series{j}).DateTime);
    % size
    [m0,~]=size(ts.hfdata.(series{j}).DateTime);
    % the first count index
    inds = [ia;m0];
    % save the original dataset for aggregation
    series0j = double(ts.hfdata.(series{j}));
    % #2: DECIMATE the dataset to last unique date-times
    % FIRST use [ia], LAST use [ia(2:end)-1;end]]
    % requires the DATETIME to be sorted (see above)
    % -------------------------------------------------------
    ts.hfdata.(series{j}) = ts.hfdata.(series{j})([ia(2:end)-1;end],:);
    % ------------------------------------------------------
    seriesjk0 = double(ts.hfdata.(series{j}));
    % remove time
    dt0 = seriesjk0(:,1);
    % keep the data
    seriesjk0 = seriesjk0(:,2:end); % target
    series0j = series0j(:,2:end); % source
    % #2: re-populate decimated fields if data-rule exists
    switch lower(series{j})
        case {'price','midprice','vwap','mtm_price','buysell'}
            if isempty(intersect(series,'Volume'))
                % average if there is no volume present
                for i = 1:length(ia) % Loop over each unique time index
                    ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                    seriesjk0(i,:) = nanmean(series0j(ind,:));
                end
            else
                % the volume weighted sum if there is Volume
                volume0 = double(ts.hfdata.Volume);
                for i = 1:length(ia) % Loop over each unique time index
                    ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                    volume0(i,:) = nansum(volume0(ind,:)); % may need to NaN --> 0
                    seriesjk0(i,:) = nansum(series0j(ind,:) .* volume0(ind,:))./volume0(i,:);
                end
            end
        case {'volume','no_trades','no_bids','no_asks','volbuy','volsell'}
            % sum over intervals
            for i = 1:length(ia) % Loop over each unique time index
                ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                seriesjk0(i,:) = nansum(series0j(ind,:));
            end
        case {'openask','open','openbid'}
            % decimate at the beginning of the interval
            for i = 1:length(ia) % Loop over each unique time index
                ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                seriesjk0(i,:) = series0j(ind(1),:);
            end
        case {'high'}
            % find the maximum in the interval
            for i = 1:length(ia) % Loop over each unique time index
                ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                seriesjk0(i,:) = nanmax(series0j(ind,:));
            end
        case {'low'}
            % find the minimum in the interval
            for i = 1:length(ia) % Loop over each unique time index
                ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                seriesjk0(i,:) = nanmin(series0j(ind,:));
            end
        case {'closeask','close','closebid','last','theoask','theobid','theoprc'}
            % decimate at end of interval (can remove loop)
            for i = 1:length(ia) % Loop over each unique time index
                ind = inds(i):max(inds(i),inds(i+1)-1); % Indices of all trades sharing that timestamp
                seriesjk0(i,:) = series0j(ind(end),:);
            end
        otherwise
            % decimate (at end) align with datetime
    end
    seriesjk0 = mat2dataset([dt0, seriesjk0]);
    seriesjk0.Properties.VarNames = get(ts.hfdata.(series{j}),'VarNames');
    ts.hfdata.(series{j}) = seriesjk0;
end
end % merged aggregate
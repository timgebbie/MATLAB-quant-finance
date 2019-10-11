%% High-Frequency Time-Series (HFTS) objects
%
% Convert Chopper use of dataset to a HFTS data object

%% Create the test data from FDS
dbstruct.username = '';
dbstruct.password = '';
dbstruct.database = '';
dbstruct.driver   = '';
dbstruct.databaseurl = '';
conn = database(dbstruct.database,dbstruct.username,dbstruct.password,dbstruct.driver,dbstruct.databaseurl);
% 10-min Bar data
dataA = fetchtrth(conn,{'AGLJ'},'Intraday 10Min',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);
dataB = fetchtrth(conn,{'BILJ'},'Intraday 10Min',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);
% 1-min Bar data
dataC = fetchtrth(conn,{'AGLJ'},'Intraday 1Min',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);
dataD = fetchtrth(conn,{'BILJ'},'Intraday 1Min',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);
% Combined 1-min bar data
dataE = fetchtrth(conn,{'AGLJ','BILJ'},'Intraday 1Min',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);
% Trade-Sales data
dataF = fetchtrth(conn,{'AGLJ'},'Trade',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);
dataG = fetchtrth(conn,{'BILJ'},'Trade',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);
% Combined Tick Data
dataH = fetchtrth(conn,{'AGLJ','BILJ','SBKJ'},'Trade',[datenum('2-Oct-2011'), datenum('31-Jan-2012')]);

%% Create test data directly from TRTH
try
    %  connection objects
    r = rdth('','');
    % The reduced basket RIC codes and request type
    Tickers = {'AGL,BIL,SBK'};
    Tickers = tick2tick(commalist2cell(Tickers{:}),'RIC','JSE');
    for i=1:length(Tickers),
        Exchange{i} = 'JNB';
        Domain{i} = 'EQU';
    end;
    reqtype = 'TimeAndSales';
    messtype = 'Trade';
    tradefields = {'Price','Volume','Mid Price'};
    edate = busdays(today-10,today,1); % load data for 2 days prior
    sdate = edate(end-1);
    edate = edate(end-1);
    dataI = trth2struct(r,Tickers,tradefields,sdate,edate,reqtype,messtype,Exchange,Domain);
catch
end

%% Create HFTS from .CSV file

%% Class constructor and methods for Tick Data
tsH = hfts(dataH),
tsH = aggregate(tsH);
tsH.AGL(1:4,:),
size(tsH.AGL),
size(tsH.BIL),
tsH.series,
tsH0 = hfts(dataH,{'Price','Volume'}),
tsH0 = aggregate(tsH);
tsH1 = mergets(tsH),
tsH1.Price(1:2,:),
tsH2 = resample(tsH,1/3600),
tsH3 = tsH,
tsH3.freq = 's',

%% convert to FINTS objects
f1 = fints(tsH);
f2 = fints(tsH1);

%% Merge HFTS objects 
tsAM = merge(tsH,tsM);

%% Test TRTH DATA
try
tsI = hfts(dataI,{'Price','Volume'}),
catch
end

%% Class constructor and methods for Bar-Data (already aggregated)
tsE = hfts(dataE),

%% Plot function
plot(tsH,'25-Jan-2012',1.5);
plot(tsH,'25-Jan-2012',10);

%% fill in missing data
% linear interpolation
tsHf=fillts(tsH);
% zero-order hold
tsHfz=fillts(tsH,'z');

%% remove overlapping missing data
stH1r=nanfreets(tsH1);
display(stH1r);

%% compute returns
% covert to tick-to-tick returns
stH1ret = tick2ret(tsH1);
% convert to inhomogenously sampled per-minutes returns
stH1rets = tick2ret(tsH1,'geometric','ticktime');
display(stH1rets);

%% plot the price fluctuations
plot(stH1rets,'25-Jan-2012',10);

%% Documentation
help hfts
help hfts/aggregate
help hfts/extend
help hfts/fints
help hfts/mergets
help hfts/plot
help hfts/subsasgn
help hfts/tick2ret
help hfts/display
help hfts/fillts
help hfts/hfts
help hfts/nanfreets
help hfts/resample
help hfts/subsref
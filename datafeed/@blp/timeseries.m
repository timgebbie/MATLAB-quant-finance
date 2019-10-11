function d = timeseries(b,s,daterange,intv,fld,varargin)
%TIMESERIES Bloomberg V3 intraday tick data.
%   D = TIMESERIES(C,S,T) returns the raw tick data for the security S for
%   the date T.  
%
%   D = TIMESERIES(C,S,{STARTDATE,ENDDATE}) returns the raw tick data
%   for the security S for the date range defined by STARTDATE and ENDDATE.
%
%   D = TIMESERIES(C,S,T,B,F) returns the tick data for the security S for
%   the date T in intervals of B minutes for the field, F.  Intraday tick 
%   data requested with an interval is returned with the columns 
%   representing Time, Open, High, Low, Last Price, Volume of the ticks,   
%   number of ticks and total value of the ticks in the bar.  
%
%   Examples:
%
%   D = TIMESERIES(C,'ABC US Equity',FLOOR(NOW)) returns today's time series
%   for the given security.  The timestamp and tick value are returned.
%
%   D = TIMESERIES(C,'ABC US Equity',FLOOR(NOW),5,'Trade') returns today's Trade tick series
%   for the given security aggregated into 5 minute intervals.  
%
%   D = TIMESERIES(C,'ABC US Equity',{'12/08/2008 00:00:00','12/10/2008 23:59:59.99'},5,'Trade') 
%   returns the Trade tick series for 12/08/2008 and 12/10/2008 for the given 
%   security aggregated into 5 minute intervals.  
%
%   See also BLP, GETDATA, HISTORY, REALTIME.

%   Copyright 1999-2010 The MathWorks, Inc.
%   $Revision: 1.1.4.6.2.4 $   $Date: 2010/07/27 15:33:08 $

%imports
import com.bloomberglp.blpapi.*;
import java.util.Calendar;

%get bloomberg service, set request type
refDataService = b.session.getService('//blp/refdata');
if nargin > 3 && ~isempty(intv)
  request = refDataService.createRequest('IntradayBarRequest');
else
  request = refDataService.createRequest('IntradayTickRequest');
end

%set security
request.set('security', s);

%parse interval value, set default tick type to TRADE
if nargin > 3 && ~isempty(intv)
    request.set('interval', int32(intv));
    request.set('gapFillInitialBar', false);
else
  eventTypes = request.getElement('eventTypes');
end

%parse field input
if nargin > 4
  %Convert field list to cell array
  if ischar(fld)   
    fld = cellstr(fld);
  end
  if ~iscell(fld) || ~ischar(fld{1})
    error('datafeed:blpTimeSeries:fieldInputError','Field list must be cell array of strings.')
  end
elseif nargin == 4
  request.set('eventType','TRADE');
else
  eventTypes.appendValue('TRADE');
end

%set field request
if nargin > 4 && ~isempty(intv)
  request.set('eventType', upper(fld{1}));
elseif nargin > 4
  for i = 1:length(fld)
    eventTypes.appendValue(upper(fld{i}));
  end
end

%create Date object for timezone offset as fraction of day
currentdt = java.util.Date;
tzOffset = currentdt.getTimezoneOffset / (24*60);

%parse date range and account for timezone
if ~iscell(daterange)
  daterange = {daterange};
end
if length(daterange) > 1
  sd = datevec(datenum(daterange{1}) + tzOffset);
  ed = datevec(datenum(daterange{2}) + tzOffset);
else
  %If single date input given, make end of range end of that date
  sd = datevec(datenum(daterange{1}) + tzOffset);
  ed = datevec(datenum(daterange{1})+1 + tzOffset);
end

%convert input dates to Datetime object
startDateTime = Datetime(sd(1),sd(2),sd(3),sd(4),sd(5),sd(6),0);
endDateTime = Datetime(ed(1),ed(2),ed(3),ed(4),ed(5),ed(6),0);
request.set('startDateTime', startDateTime);
request.set('endDateTime', endDateTime);

%set other parameters, reference BLP API doc for names and settings
if nargin > 5
  numin = length(varargin);
  if mod(numin,2)
    error('datafeed:blpTimeSeries:parameterMismatch','Please enter value for each request setting.')
  end
  if iscell(varargin{1})
    for i = 1:length(varargin{1})
      request.set(varargin{1}{i},varargin{2}{i})
    end
  else
    request.set(varargin{1},varargin{2})
  end
end

%send request
b.session.sendRequest(request, []);

%initialize variables
done = false;
d = [];

%process event messages and types
while ~done
            
  event = b.session.nextEvent();
  if (strcmp(char(event.eventType),'PARTIAL_RESPONSE')) 
    d = [d;processResponseEvent(event)];   %#ok
  elseif (strcmp(char(event.eventType),'RESPONSE')) 
    d = [d;processResponseEvent(event)];   %#ok
    done = true;
  else
    msgIter = event.messageIterator();
    while (msgIter.hasNext()) 
      msg = msgIter.next();
      if (strcmp(char(event.eventType),'SESSION_STATUS'))
        if (msg.messageType().equals('SessionTerminated')) 							
          done = true;
        end
      end
    end
  end
end


function d = processResponseEvent(event)
%PROCESSRESPONSEEVENT Process events

%imports
import com.bloomberglp.blpapi.*;
import java.util.Calendar;

%initialize response error
RESPONSE_ERROR = Name('responseError');

%Process messages
msgIter = event.messageIterator();
while (msgIter.hasNext()) 
  msg = msgIter.next();
  if (msg.hasElement(RESPONSE_ERROR)) 
    error('datafeed:blp:timeseriesFailure',['REQUEST FAILED: ', char(msg.getElement(RESPONSE_ERROR))]);
  end
  d = processMessage(msg);
end

function d = processMessage(msg)
%PROCESSMESSAGE Process event messages and data

%imports
import com.bloomberglp.blpapi.*;
import java.util.Calendar;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

%initialize date formatting
d_dateFormat = SimpleDateFormat();
d_dateFormat.applyPattern('MM/dd/yyyy k:mm');
d_decimalFormat = DecimalFormat();
d_decimalFormat.setMaximumFractionDigits(3);
  
%get message type
sMessageType = char(msg.messageType);

%base date used in date conversions
baseDate = datenum('01/01/1970');
  
if strcmp(sMessageType,'IntradayTickResponse')
  
  %intraday tick responses, raw tick data
  
  %create data type flags
  TICK_DATA = Name('tickData');
  SIZE = Name('size');
  TIME = Name('time');
  TYPE = Name('type');
  VALUE = Name('value');
  CONDITION = Name('conditionCodes');
  EXCHANGE = Name('exchangeCode');
   
  %get data object and number of ticks
  data = msg.getElement(TICK_DATA).getElement(TICK_DATA);
  numItems = data.numValues();
  
  %preallocate output
  d = cell(numItems,4);
  
  %parse data
  for i = 0:numItems-1
    item = data.getValueAsElement(i);
    d{i+1,1} = item.getElementAsString(TYPE).toCharArray';
    d{i+1,2} = item.getElementAsDate(TIME).toString.toCharArray';
    d{i+1,3} = item.getElementAsFloat64(VALUE);
    d{i+1,4} = item.getElementAsInt32(SIZE);
    try
      d{i+1,5} = item.getElementAsString(CONDITION).toCharArray';
    catch %#ok
      %Every record needs to be checked for a condition code
    end
    try
      d{i+1,6} = item.getElementAsString(EXCHANGE).toCharArray';
    catch %#ok
      %Every record needs to be checked for a exchange code
    end
    
  end

  if isempty(d)
    return
  end
  
  %convert dates to datenumbers and account for timezone
  tmp = datenum(d(:,2),'yyyy-mm-ddTHH:MM:SS');
  for i = 1:numItems
    tzdate = java.util.Date((tmp(i)-baseDate)*86400000);
    tzOffset = tzdate.getTimezoneOffset / (24*60);
    d{i,2} = tmp(i) - tzOffset;
  end
  
elseif strcmp(sMessageType,'IntradayBarResponse')
  
  %intraday tick responses, raw tick data
  BAR_DATA = Name('barData');
  BAR_TICK_DATA = Name('barTickData');
  OPEN = Name('open');
  HIGH = Name('high');
  LOW = Name('low');
  CLOSE = Name('close');
  VOLUME = Name('volume');
  NUM_EVENTS = Name('numEvents');
  TIME = Name('time');
  TVALUE = Name('value');
  
  %get data object from message
  data = msg.getElement(BAR_DATA).getElement(BAR_TICK_DATA);
  numBars = data.numValues();

  %preallocate output
  d = nan(numBars,8);
  tmpDates = cell(numBars,1);

  %parse data
  for i = 0:numBars-1
    bar = data.getValueAsElement(i);
    tmpDates{i+1} = bar.getElementAsDate(TIME).toString.toCharArray';
    d(i+1,2) = bar.getElementAsFloat64(OPEN);
    d(i+1,3) = bar.getElementAsFloat64(HIGH);
    d(i+1,4) = bar.getElementAsFloat64(LOW);
    d(i+1,5) = bar.getElementAsFloat64(CLOSE);
    d(i+1,6) = bar.getElementAsInt64(VOLUME);
    d(i+1,7) = bar.getElementAsInt32(NUM_EVENTS);
    d(i+1,8) = bar.getElementAsFloat64(TVALUE);
  end
  
  %Convert dates
  if ~isempty(d)
    d(:,1) = datenum(tmpDates,'yyyy-mm-ddTHH:MM:SS');
    for i = 1:numBars
      tzdate = java.util.Date((d(i,1)-baseDate)*86400000);
      tzOffset = tzdate.getTimezoneOffset / (24*60);
      d(i,1) = d(i,1) - tzOffset;
    end
  end
end
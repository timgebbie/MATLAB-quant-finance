function [d,sec] = getdata(b,s,f,o,ov,varargin)
%GETDATA Current Bloomberg V3 data.
%   [D,SEC] = GETDATA(B,S,F) returns the data for the fields F for the 
%   security list S.  SEC is the security list that maps the order of the 
%   return data.   Note that the data is not necessarily returned in the 
%   same order as the input security list, S.
%
%   [D,SEC] = GETDATA(B,S,F,O,OV) returns the data for the fields F for the 
%   security list S using the override fields O with corresponding override
%   values.
%
%   [D,SEC] = GETDATA(B,S,F,O,OV,NAME,VALUE,...) returns the data for the fields F for the 
%   security list S using the override fields O with corresponding override
%   values.  NAME/VALUE pairs are used for additional Bloomberg request settings.
%
%   Examples:
%
%   [D,SEC] = GETDATA(C,'ABC US Equity',{'LAST_PRICE';'OPEN'}) returns
%   today's current and open price of the given security.
%
%   [D,SEC] = GETDATA(C,'3358ABCD4 Corp',...
%   {'YLD_YTM_ASK','ASK','OAS_SPREAD_ASK','OAS_VOL_ASK'},...
%   {'ASK','OAS_VOL_ASK'},{'99.125000','14.000000'})
%   returns the requested fields given override fields and values.
%
%   See also BLP, HISTORY, REALTIME, TIMESERIES.

%   Copyright 1999-2010 The MathWorks, Inc.
%   $Revision: 1.1.4.19.2.1 $   $Date: 2010/06/02 13:52:50 $

%imports
import com.bloomberglp.blpapi.*;

%Validate security list.  Security list should be cell array string
if ischar(s)   
  s = cellstr(s);
end
if ~iscell(s) || ~ischar(s{1})
  error('datafeed:blpGetData:securityInputError','Security list must be cell array of strings.')
end

%Convert field list to cell array
if ischar(f)   
  f = cellstr(f);
end
if ~iscell(f) || ~ischar(f{1})
  error('datafeed:blpGetData:fieldInputError','Field list must be cell array of strings.')
end

%Convert overrides and values to cell array
if exist('o','var')
  if ischar(o)
    o = cellstr(o);
  elseif ~iscell(o) || ~ischar(o{1})
    error('datafeed:blpGetData:overrideFieldInputError','Override field list must be cell array of strings.')
  end
end

if exist('ov','var')
  if ischar(ov)
    ov = cellstr(ov);
  elseif ~iscell(ov) || ~ischar(ov{1})
    error('datafeed:blpGetData:overrideValueInputError','Override value list must be cell array of strings.')
  end
end

%get bloomberg service, set request type
refDataService = b.session.getService('//blp/refdata');
request = refDataService.createRequest('ReferenceDataRequest');

%add securities to request
securities = request.getElement('securities');
for i = 1:length(s)
  securities.appendValue(s{i});
end

%add fields to request, max fields is 400
fields = request.getElement('fields');
for i = 1:length(f)
  fields.appendValue(f{i});
end

%add overrides to request if given
if nargin > 3
  
  if ~exist('ov','var') || (length(o) ~= length(ov))
    error('datafeed:blp:overrideMismatch',...
      'Number of override values must equal number of override fields');
  end
  
  overrides = request.getElement('overrides');

  for i = 1:length(o)
    override = overrides.appendElement;
    override.setElement('fieldId', o{i});
    override.setElement('value', ov{i});
  end
  
end

%set other parameters, reference BLP API doc for names and settings
if nargin > 5
  numin = length(varargin);
  if mod(numin,2)
    error('datafeed:blpGetData:parameterMismatch','Please enter value for each request setting.')
  end
  for i = 1:2:length(varargin)
    request.set(varargin{i},varargin{i+1})
  end
end

%send request
d_cid = b.session.sendRequest(request,[]);

%process event messages and types
done = false;
k = 1;
sec = [];
while ~done
             
  event = b.session.nextEvent();
  msgIter = event.messageIterator();
  while (msgIter.hasNext)
    
    msg = msgIter.next();
    
    %trap event error
    if msg.hasElement(Name('responseError'));
      error('datafeed:blpGetData:eventError',char(msg.getElement('responseError').getElementAsString('message')))
    end
    
    if (msg.correlationID() == d_cid)
      [tmp{k},newflds,tmpsec] = processMessage(msg);   %#ok
      sec = [sec;tmpsec];                              %#ok
      k = k + 1;
    end
            
    if (event.eventType().toString == java.lang.String('RESPONSE')) 
      done = true;
    end
  end
end

% Build output structure
if ~exist('tmp','var')
  d = [];
  return
end

%if multiple messages, need to concatenate structures
nummessages = length(tmp);

if nummessages == 1

  %single message
  d = tmp{1};   

else
  %multiple messages
  
  flds = {};
  %get union of fields from messages
  for i = 1:nummessages
    if ~isempty(tmp{i})
      flds = union(flds,fieldnames(tmp{i}));
    end
  end
  
  %concatenate structures, trapping unique fields in messages
  %Need to trap all return types and compare to any structure elements to
  %make rest of structure is populated correctly
  for i = 1:nummessages
    for j = 1:length(flds)
      if isfield(tmp{i},flds{j})
        if exist('d','var') && isfield(d,flds{j})
          if iscell(d.(flds{j})) && isa(tmp{i}.(flds{j}),'double')
            d.(flds{j}) = nan(size(d.(flds{j})));
            d.(flds{j})(end+1:end+length(tmp{i}.(flds{j})),1) = tmp{i}.(flds{j});
          elseif isa(d.(flds{j}),'double') && iscell(tmp{i}.(flds{j}))
            d.(flds{j})(end+1:end+length(tmp{i}.(flds{j})),1) = nan(length(tmp{i}.(flds{j})),1);
          else
            d.(flds{j})(end+1:end+length(tmp{i}.(flds{j})),1) = tmp{i}.(flds{j});
          end
        else
          d.(flds{j}) = tmp{i}.(flds{j})(:);
        end
      end
    end
  end
end

%Fill in valid fields that returned events
if ~exist('d','var')
  d = [];
  return
end
if isempty(d)
  mFields = f;
else
  retFields = fieldnames(d);
  mFields = setdiff(newflds,retFields);
end

%Create empty return value for each requested security for fields with no
%events
numRecords = length(s);
tmpString = {[]};
emptyRecords = tmpString(ones(numRecords,1),:);
emptyNumbers = nan(numRecords,1);
sdArray = msg.getElement('securityData');
sd = sdArray.getValueAsElement(0);
fd = sd.getElement('fieldData');
for i = 1:length(mFields)
  switch char(fd.getElement(mFields{i}).datatype)
    case {'DATE','FLOAT32','FLOAT64','INT32'}
      try
        d.(mFields{i}) = emptyNumbers;
      catch  %#ok
        d.(['n' mFields{i}]) = emptyNumbers;
      end
    otherwise
      try
        d.(mFields{i}) = emptyRecords;
      catch  %#ok
        d.(['n' mFields{i}]) = emptyRecords;
      end
  end
end

%Pad fields with no data at end of fields
allFields = fieldnames(d);
for i = 1:length(allFields)
  if length(d.(allFields{i})) < numRecords
    if iscell(d.(allFields{i}))
      d.(allFields{i}){numRecords} = [];
    else
      numPts = length(d.(allFields{i}));
      d.(allFields{i})(numPts+1:numRecords,1) = NaN;
    end
  end
end

function [d,f,sec] = processMessage(msg)
%PROCESSRESPONSEEVENT Process events

%imports
import com.bloomberglp.blpapi.*;

%%create data type flags
f = [];
SECURITY_DATA = Name('securityData');
FIELD_DATA = Name('fieldData');
FIELD_EXCEPTIONS = Name('fieldExceptions');
ERROR_INFO = Name('errorInfo');

%get data from message
securityDataArray = msg.getElement(SECURITY_DATA);
numSecurities = securityDataArray.numValues();

%parse return data into structure
if numSecurities
  sec = cell(numSecurities,1);
else
  sec = [];
end
for i = 0:numSecurities-1
  securityData = securityDataArray.getValueAsElement(i);
  sec{i+1} = char(securityData.getElementAsString('security'));
  fieldData = securityData.getElement(FIELD_DATA);
  for j = 0:fieldData.numElements()-1;
    field = fieldData.getElement(j);
    if (field.isNull()) && ~exist('d','var')
      %No data
      d = [];
    else
      
      fldname = char(field.name);
      
      %If fldname cannot be used a structure field name, prepend "n"
      try
        fldTest.(fldname) = NaN;
        f{j+1} = fldname; %#ok
      catch %#ok
        fldTest.(['n' fldname]) = NaN;
        fldname = ['n' fldname];  %#ok
        f{j+1} = fldname;  %#ok
      end
      clear fldTest
      
      %Build output structure based on field datatype
      switch char(field.datatype)
        case {'FLOAT64','FLOAT32','INT32'}
          if exist('d','var') && isfield(d,fldname)
            try
              d.(fldname)(i+1,1) = field.getValueAsFloat64(0);
            catch exception %#ok
              d.(fldname) = nan(length(d.(fldname)),1);
              d.(fldname)(i+1,1) = field.getValueAsFloat64(0);
            end
          else
            d.(fldname) = nan(numSecurities,1);
            d.(fldname)(i+1,1) = field.getValueAsFloat64(0);
          end
        case {'DATE'}
          if exist('d','var') && isfield(d,fldname)
            try
              d.(fldname)(i+1,1) = datenum(char(field.getValueAsString(0)));
            catch exception %#ok
              d.(fldname) = nan(length(d.(fldname)),1);
              d.(fldname)(i+1,1) = datenum(char(field.getValueAsString(0)));
            end
          else
            d.(fldname) = nan(numSecurities,1);
            d.(fldname)(i+1,1) = datenum(char(field.getValueAsString(0)));
          end
        case {'SEQUENCE'}
          %Bulk data creates cell array
          numEls = field.numValues;
          bulkdata = cell(numEls,1);
          for k = 0:numEls - 1;
            numSubEls = field.getValueAsElement(k).numElements;
            for m = 0:numSubEls-1
              switch char(field.getValueAsElement(k).getElement(m).datatype)
                case 'DATE'
                  tmpdate = char(field.getValueAsElement(k).getElement(m).getValueAsString(0));
                  if isempty(tmpdate)
                    bulkdata{k+1,m+1} = NaN;
                  else
                    bulkdata{k+1,m+1} = datenum(tmpdate);
                  end
                case {'FLOAT64','FLOAT32','INT32'}
                  bulkdata{k+1,m+1} = field.getValueAsElement(k).getElement(m).getValueAsFloat64(0);
                otherwise
                  bulkdata{k+1,m+1} = char(field.getValueAsElement(k).getElement(m).getValueAsString(0));
              end
            end
          end
          d.(fldname){i+1,1} = bulkdata;
        otherwise
          if exist('d','var') && isfield(d,fldname)
            d.(fldname){i+1,1} = char(field.getValueAsString(0));
          else
            d.(fldname) = cell(numSecurities,1);
            d.(fldname){i+1,1} = char(field.getValueAsString(0));
          end
      end    
    end
  end
  
  %process field exceptions, errors
  fieldExceptionArray = securityData.getElement(FIELD_EXCEPTIONS);
  for k = 0:fieldExceptionArray.numValues()-1
    fieldException = fieldExceptionArray.getValueAsElement(k);
    try
      d.(char(fieldException.getElementAsString('fieldId'))){i+1,1} = char(fieldException.getElement(ERROR_INFO).getElementAsString('subcategory'));
    catch exception %#ok
      d.(char(fieldException.getElementAsString('fieldId')))(i+1,1) = NaN;  
    end
    f = [];
  end
end

if ~exist('d','var')
  d = [];
end
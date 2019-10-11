function [exdata,colnames] = slice(varargin),
% @FINTS/SLICE Slice a FINTS object at a DATE
%
% [EXD,COLS] = SLICE(FTS) Slice the FINTS object FTS at most recent date.
% The output EXD is a cell-array. The column names are COLS.
%
% [EXD,COLS] = SLICE(FTS,DATE) Slice the FINTS object FTS at date DATE. If
% the date DATE is not in the objects range the data return would be
% the date closest to DATE. If the date is within the date range but
% not in the object. The data return will be the interpolate data.
% The default interpolate method will be zero-order hold.
%
% [EXD,COLS] = SLICE(FTS,DATE,METHOD) METHOD is the interpolation method if 
% interpolation is required. This can be zero-order hold 'z', linear
% interpolation, 'l' or any other type allowed by INTERP1. 
%
% See Also: INTERP1, FILLTS, INSERT

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/03 16:04:53 $ $Author: Tim Gebbie $

switch nargin
    case 1
        fts    = varargin{1};
        method = 'z';
    case 2
        fts    = varargin{1};
        xi     = datenum(varargin{2});
        method = 'z';
    case 3
        fts    = varargin{1};
        xi     = datenum(varargin{2});
        method = varargin{3};
    otherwise
        error('Incorrect Input Arguments');
end


% get the datanames
datanames = fieldnames(fts,1);
% condition the datanames
datanames = transpose(datanames(:));
% switch depending on if date is provided or not
if nargin==1,
    % get the data point at the end point in the date axis
    fts = subsref(fts,substruct('()',{size(fts,1)}));
    % get the required date
    xi  = subsref(fts,substruct('.','dates'));
else
    if any(subsref(fts,substruct('.','dates'))==xi),
        % get the data point at the end point in the date axis
        fts = subsref(fts,substruct('()',{datestr(xi)}));
    else
        % add an additional day
        fts = fillts(fts,method,xi); 
        % get the data at the right date
        fts = subsref(fts,substruct('()',{datestr(xi)}));
    end;
end;

% get the data
yi = fts2mat(fts);
% create the data slice structure
cell_Attr     = cellstr(reshape(datanames,length(datanames),1));
cell_Value    = num2cell(reshape(yi,length(yi),1));
% Concatenate data into rows for database table
exdata = [cell_Attr cell_Value];
% Specify column names
colnames = {'Attr', char(subsref(fts,substruct('.','desc')))};
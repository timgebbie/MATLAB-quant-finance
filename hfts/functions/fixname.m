function tickers = fixname(varargin)
% FIXNAME Fix the ticker name string for use with FINTS objects
%
% NAMES = FIXNAME(NAMES) FIX the names in NAMES. Trims off ':' and replaces 
% '.' with '_' and removes other strings that are not legal FINTS names. 
%
% NAMES = FIXNAME(NAMES,FLAG) FIX the names in NAMES. By Default FLAG is 
% 1, FLAG=1 to trim off everything proceeding the first ':'. 
% FLAG=-1 trims of everything following the last ':'. FLAG=0 merely 
% removes ':', and FLAG=2 removes everything.
%
% Legal characters are:   lowercase latin alphabet, 'a' to 'z'
%                         uppercase latin alphabet, 'A' to 'Z'
%                         underscore, '_'
%
% Example 1:
%       fixname('Capital Asset Pricing Model')
%       ans = 'CapitalAssetPricingModel'
% Example 2:
%       fixname('A.B:K',-1)
%       ans = 'A_B'
% Example 3: [not the recommended default]
%       fixname('R:AGLJ')
%       ans = RAGLJ
%
% See Also: FINTS/PRIVATE/ISLEGALNAME, FINTS

% Author: Tim Gebbie 01-01-2005

% $Id: fixname.m 395 2011-11-18 12:33:59Z tgebbie $

fixflag = 0;
switch nargin
    case 1
        tickers = varargin{1};
    case 2
        tickers = varargin{1};
        fixflag = varargin{2};
    otherwise
        error('Incorrect Input Arguments');
end
% check type of fixflag
if islogical(fixflag),
    error('ftsdata:fixname','Incorrect Input type');
end;
tickers = cellstr(tickers);
for i=1:length(tickers),
    % remove the white space
    tickers{i} = tickers{i}(~isspace(tickers{i}));
    if abs(fixflag)==1
        cidx = find(ismember(tickers{i},':'));
        if ~(fixflag==1) && ~isempty(cidx)
            % remove everything proceeding ':'
            tickers{i} = tickers{i}(1:cidx(1));
        elseif ~isempty(cidx)
            % remove everything following ':'
            tickers{i} = tickers{i}(cidx(end):end);
        end
    end
    % remove ':' in the name for modified data
    tickers{i} = tickers{i}(~ismember(tickers{i},':'));
    if fixflag==2
        tickers{i} = tickers{i}(~ismember(tickers{i},'/'));
    end
    % find all '.' and '/'
    tick_ind = ismember(tickers{i},['&','$','/','.','@','*','\','=']);
    % replace '.' and '/' with '_'
    tickers{i}(tick_ind) = '_';
end; % for i
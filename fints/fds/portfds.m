function f = portfds(varargin)
% PORTFDS Select a portfolio from the FDS and return as FTS
%
% [FDS] = PORTFDS(NAME) To get the portfolio as the physical portfolio
%
% Example 1: Load portfolio constitents and Market Cap.
% >> p1 = portfds('TFMC01');
%
% NB: If the named portfolio is in the list of funds by creator 'FG_GIPS' 
% it will be automatically loaded as CREATOR 'FG_GIPS' and TREETYPE
% 'FG_GIPS_Port_Holding' as it will then be assumed that the end-user is 
% try to load an existing physical portfolio by current holdings.
%
% [FDS] = PORTFDS(NAME,ITEM)
%
% [FDS] = PORTFDS(NAME,ITEM,CREATOR) The creator of the tree is CREATOR 
% for FTSE classifications one should use 'INET_FTSE' while for physical
% portfolio one should use 'FG_GIPS'. The default creator is 'INET_FTSE'.
%
% [FDS] = PORTFDS(NAME,ITEM,CREATOR,DATES) The DATES is the date 
% string required e.g. {'10-Oct-2004', '11-Oct-2004','12-Oct-2004'}. 
% Date numbers are not accepted. 
%
% [FDS] = PORTFDS(NAME,ITEM,CREATOR,DATES,TREETYPE) The TREETYPE is the 
% type of portfolio tree to be used. The DATES can be empty if all the
% avaliable data is required. The default TREETYPE is 'FTSE_Const_Data', 
% but other type are also supported as in Table 1 below.
% 
% Table 1. Examples of Tree Types by Creator
% +---------------+----------------------------------+
% | Creator       | TreeType                         |
% +---------------+----------------------------------+
% | 'INET_FTSE'   | 'FTSE_DATA      '                |
% | 'INET_CONN'   | 'INET_CONSENSUS Portfolio'       |
% | 'INET_FTSE'   | 'Classification'                 |
% | 'INET_FTSE'   | 'Portfolio'                      |
% | 'BESA'        | 'Classification'                 |
% | 'BESA'        | 'Portfolio'                      |
% |               |                                  |
% +---------------+----------------------------------+
%
% Example 2: Load index constiteunts and Market Cap.
% >> p2 = portfds('J203','Mkt_Cap_Net','INET_FTSE','11-Sep-2003::02-Jan-2004');
%
% Example 3: Load index classification
% >> p3 = portfds('J203','Validity','INET_FTSE','','Classification');
%
% Example 4: Load INET CONSENSUS portfolio members
% >> p4 = portfds('INET_CONN','Validity','FG_QED_CONN','30-Dec-2005::31-Jan-2006','Portfolio');
%
% Example 5: Load BESA GOVI membership from the classification matrix
% >> p5 = fints(portfds('GOVI_1','Validity','BESA','','Classification')); 
%
% Example 6: Load BESA nominal weights for the ALBI index
% >> p6 = fints(portfds('ALBI','Nominal','BESA','','Portfolio'));
%
% Example 7: Load benchmark weights of stocks in CAPI (J303) index
% >> p7 = portfds('J303','Weight','INET_FTSE','31-Jan-2003:31-Mar-2003');
%
% Example 8: Weight of stocks in J510 subsector of J203
% >> p8 = portfds('J510','Weight','INET_FTSE');
%
% Note 1: This only allows a single level of Parent and Child. If more 
% levels are required use the @UNIVERSE object. The requirement fulfilled
% here is to satisfy the requirement for loading simple portfolios and
% their controls to and from the FDS.
%
% Note 2: Avoid using dates of the form '01-Jan-2004' and not '1-Jan-2004'.
%
% Note 3: Classification trees are used to encapsulate the hierarchy of 
% membership e.g. {J203,J000,J150,AGL} while a Portfolio tree is used to 
% encapsulate the direct instrument membership {J203,AGL}, {J000,AGL}, 
% {J150,AGL}. These are unique, necessary and different data structures.
% Almost all trees in this structure are portfolio trees as the are not
% explicitly used to encapsulate the classification of hierarchical 
% sectors that stocks may fall in. It is recommended that the portfolio
% classifications be retrieved using CLASSFDS
%
% See Also: @PORTFOLIO/INSERT @FDS/SELECT PORTFDS2FTS CLASSFDS

% Author : Tim Gebbie

% $Revision: 1.4 $ $Date: 2006/10/27 08:57:15 $ $Author: tgebbie $

%% initialize the fds object
f = set(fds,'database_object','view_PortfolioData');
% the default full list of attributes
attributes  = {'ParentNode', ...
               'ChildNode', ...
               'Name', ...
               'Creator', ...
               'ValidityDate', ...
               'TreeType', ...
               'ValueType', ...
               'Value'};
% the default Creator
creator     = {'INET_FTSE','FG_GIPS'};
% the default item type (This is the adjusted market capitalization
% appropriate for adjusted indices such as SWIX, CAPI, VALUE and GROWTH
% indices while been sufficient for the other indices - 
% Mkt_Cap_Net, Mkt_Cap_Adj, Mkt_Cap_Gro
item        = 'Mkt_Cap_Net';
% the default tree type is the portfolio tree types
treetype    = {'FTSE_Const_Data','FG_GIPS_Port_Holding','Portfolio'};

%% Input Arguments
switch nargin
    case 1       
        if ismember(varargin{1},searchfunds),
            f=portfds(varargin{1},item,creator{2},'',treetype{2});
            return;
        else
            f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType','TreeType'});
            f = set(f  ,'range',{varargin{1},cellstr(creator{1}),varargin{1},item,treetype{1}});
        end;
        
    case 2
        if ~isempty(varargin{2}),
            f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType','TreeType'});
            f = set(f  ,'range',{varargin{1},cellstr(creator{1}),varargin{1},cellstr(varargin{2}),treetype{1}});
        else
            f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType','TreeType','ValidityDate'});
            f = set(f  ,'range',{varargin{1},cellstr(creator{1}),varargin{1},cellstr(varargin{2}),treetype{1}},varargin{2});
        end;
    case 3
        if ~isempty(varargin{3}),
            if isempty(varargin{2}), varargin{2} = item; end;
  
            % find if there is a know creator with known tree type
            j = ismember(treetype,varargin{3});
            if any(j),  
                f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType','TreeType'});
                f = set(f  ,'range',{varargin{1},cellstr(creator{j}),varargin{1},cellstr(varargin{2}),treetype{j}});
            else
                % else load for all avaliable tree types
                f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType'});
                f = set(f  ,'range',{varargin{1},varargin{3},varargin{1},cellstr(varargin{2})});
            end;
            
        else
            f = portfds(varargin{1},varargin{2});
            return;
        end;
    case 4
        if ~isempty(varargin{4}),
            f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType','ValidityDate','TreeType'});
            if isempty(varargin{2}), varargin{2} = item; end;
            if isempty(varargin{3}), varargin{3} = creator; end;   
            f = set(f  ,'range',{varargin{1},varargin{3},varargin{1},cellstr(varargin{2}),varargin{4},treetype});
            
            % find if there is a know creator with known tree type
            j = ismember(treetype,creator);
            if any(j),
                f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType','TreeType'});
                f = set(f  ,'range',{varargin{1},cellstr(creator),varargin{1},cellstr(varargin{2}),treetype{j}});
            else
                % else load for all avaliable tree types
                f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType'});
                f = set(f  ,'range',{varargin{1},varargin{3},varargin{1},cellstr(varargin{2})});
            end    
            
        else
            f = portfds(varargin{1},varargin{2},varargin{3});
            return;
        end;
    case 5
        
        % This can be re-written in the future so the attributes that have
        % empty ranges are removed from the object at selection.
        if isempty(varargin{4}),
            % If there is no date range required
            f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType','TreeType'});
            if isempty(varargin{2}), varargin{2} = item; end;
            if isempty(varargin{3}), varargin{3} = creator; end;   
            f = set(f  ,'range',{varargin{1},varargin{3},varargin{1},cellstr(varargin{2}),varargin{5}});
        else
            f = set(f  ,'attr',{'ParentNode','Creator','Name','ValueType','TreeType','ValidityDate'});
            if isempty(varargin{2}), varargin{2} = item; end;
            if isempty(varargin{3}), varargin{3} = creator; end;        
            f = set(f  ,'range',{varargin{1},varargin{3},varargin{1},cellstr(varargin{2}),varargin{5},varargin{4}});
        end; 
        
    otherwise
        error('Incorrect Input Arguments');
end

%% get the data using the FDS objects
f = select(f);


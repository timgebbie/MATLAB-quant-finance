function t = tablesfds(varargin),
% TABLESFDS Get database table names.
%
%    T = TABLESFDS returns all tables and table types for all schemas of the
%    given catalog. The default catalogue is 'FDS'. 
% 
%    See also FDS, tables

% Author: Tim Gebbie 

% $Revision: 1.0 $ $Date: 2006/03/29 12:26:34 $ $Author: tgebbie $

% construct the meta objects
meta = dmd(fds);
% find the tables
t=tables(meta,'FDS')
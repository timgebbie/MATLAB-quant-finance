function C = cell2commalist(clist)
% CELL2COMMALIST Convert cell string into comma separated list
%
% See also: commalist2cell

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: tgebbie

% get the size
[n,m]=size(clist);
% if it is an array of cells recursively call cell2commalist
if iscell(clist) & isallcells(clist) & (m==1 & n>1),
    for i=1:n, C{i}=cell2commalist(clist{i}); end; C = C(:);

else

    % condition array correctly
    clist = transpose(clist(:));

    % check argument
    if iscellstr(clist),
        if length(clist) == 1,
            C = char(clist);
        
        else
            % shape and place commas
            C = clist(:);
            C = [char(C) repmat(',',size(C,1),1)]';
            C = C(1:end-1);
            % remove extra spaces
            ic = findstr(C,' ');
            Ic = ones(size(C));
            Ic(ic) = 0;
            C = C(find(Ic));
        end;
    
    elseif ischar(clist),
        C = clist;
    
    else
        error('argument must be a cellstring or char array');
        
    end;

end;

% HELPER FUNCTIONS
function p=isallcells(c)
% check that all of the cells in a cellarray are cells
p=logical(0); j=0;
% check that they are cells
for i=1:length(c), j(i)=iscell(c{i}); end;
% get the unique set
j=unique(j);
% get the size
[m,n]=size(j);
% output the logical vector
if (m==1) & (j==1), p=logical(1); end;

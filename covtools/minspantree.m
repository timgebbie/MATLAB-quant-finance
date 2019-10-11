function [mst, nMST, t]=minspantree(E)
% MINSPANTREE Compute minimal spanning tree from adjacency matrix
%
% [MST, NMST, T] = MINSPANTREE(E) solve the minimal spanning tree problem 
% for a connected graph. E is the edges of graph and their weight as an 
% adjacency matrix: 1st and 2nd elements of each row is numbers of 
% vertexes, 3rd elements of each row is weight of edges. E has dimension 
% Mx3 for M edges. NMST(N-1,1) is the list of the N-1 edges included in 
% the minimal (weighted) spanning tree in the including order. MST is the 
% minimal spanning tree adjacency matrix. T is the logical adjacency 
% matrix with T(i,j)=0 for no vertex and T(i,j) is non-zero for a vertex.
% The non-zero entries in T(i,j) are the distances between the vertices.
%
% Example 1:
%   >> x= randn(10,100);
%   >> d = pdist(x);
%   >> a = adjacency(d);
%   >> [mst,nmst,t]=minspantree(a);
%   >> spy(t);
% 
% See Also: ADJACENCY, MSTCOORDS, MSTPLOT

% Based on grMinSpanTree.m by Author: Sergiy Iglin re-written to wrap the
% interface to return adjacency matrix t of the MST as per the interface 
% used by Fonkwe Edwin & Fouda Cedric in their function kruskal.m - this
% version is easier to use with mstcoords.m and mstplot.m to visualise an
% MST which high visibility as the requirement. NB: This is different from 
% the matlab implementation in the biomath toolbox - its primary use has
% been with the visualisation of correlation matrix relationships.

% $Revision: 1.1 $ $Date: 2009/04/28 06:55:12 $ $Author: Tim Gebbie $

% Input data validation 
n = max(max(E(:,1))); % number of vertices
m = size(E,1); % number of edges

% The data preparation 
En=[(1:m)',E]; % we add the numbers
En(:,2:3)=sort(En(:,2:3)')'; % edges on increase order
ln=find(En(:,2)==En(:,3)); % the loops numbers
En=En(setdiff([1:size(En,1)]',ln),:); % we delete the loops
[w,iw]=sort(En(:,4)); % sort by weight
Ens=En(iw,:); % sorted edges

% Build the minimal spanning tree by the greedy algorithm 
Emst=Ens(1,:); % 1st edge include to minimal spanning tree
Ens=Ens(2:end,:); % rested edges
while (size(Emst,1)<n-1)&(~isempty(Ens)),
  Emst=[Emst;Ens(1,:)]; % we add next edge to spanning tree
  Ens=Ens(2:end,:); % rested edges
  if any((Emst(end,2)==Emst(1:end-1,2))& (Emst(end,3)==Emst(1:end-1,3))) | iscycle(Emst(:,2:3)), % the multiple edge or cycle
    Emst=Emst(1:end-1,:); % we delete the last added edge
  end
end
nMST=Emst(:,1); % numbers of edges

% Output arguments
mst = E(nMST,:,:);
t = sparse(zeros(size(mst,1)+1));
for i=1:length(t)-1
    t(mst(i,1),mst(i,2)) = mst(i,3);
    t(mst(i,2),mst(i,1)) = mst(i,3);
end
return

% Helper functions
function ic=iscycle(E); % true, if graph E have cycle
% This is the version implemented by : Sergiy Iglin which is pretty
% similar to that of Fonkwe Edwin & Fouda Cedric, kruskal.m
% 
n=max(max(E)); % number of vertexes
A=zeros(n);
A((E(:,1)-1)*n+E(:,2))=1;
A=A+A'; % the connectivity matrix
p=sum(A); % the vertexes power
ic=false;
while any(p<=1), % we delete all tails
  nc=find(p>1); % rested vertexes
  if isempty(nc),
    return
  end
  A=A(nc,nc); % new connectivity matrix
  p=sum(A); % new powers
end
ic=true;
return
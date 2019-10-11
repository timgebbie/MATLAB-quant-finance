function A = ground(A)
% A = GROUND(A) Reset and store the ground state configuration variables
%
% See Also: CFSWEEP, CFMERGE, CFSPLIT, ENERGY, CFUDPATES, CFRESET

% Author: Tim Gebbie, Bongani Bambiso 2006

% 1.2 2009/02/06 13:11:50 Tim Gebbie

% Update the ground state variables
% the current the best configuration
A.gs.a       = A.a;
% internal correlations
A.gs.c       = A.c;
% number of ground state elements per cluster cluster
A.gs.n       = A.n;
% internal cluster energies
A.gs.e       = A.e;
% inverse temperature
A.gs.b       = A.b;
% configuration index membership matrix
A.gs.I       = A.I;
% number of annealing / temperature clycles
A.gs.cycle   = A.cycle; 

A.gs.updates = A.updates;  
A.gs.merges  = A.merges; 
A.gs.splits  = A.splits; 
A.gs.t       = A.t; 
A.gs.s       = A.s;


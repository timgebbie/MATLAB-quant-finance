function [A] = configuration(varargin)
% [A] = CONFIGURATION(VARARGIN)Initialize the configuration matrix.
%
% [A] = CONFIGURATION(C,A, SWEEP_TYPE) This function intializes the 
% configuration of clusters in the data, Randomly, from the similarity or 
% correlation matrix, C, of the data. SWEEP_TYPE takes values 'random' or 
% 'sequential'. Its default value is
%
% [A] = CONFIGURATION(C, A) The default value for SWEEP_TYPE is 
% 'random'. [A] is the configuration of clusters, and it is data 
% structure with a format described ANNEALING (See Example below).
%
%
% Example 1:
%       A.C = [[1  0  0];
%             [0  1  0];
%             [0  0  1]];
%
% then, initial configuration paramters are:-
% A.a       = [1,2,3];  - configuration
% A.c       = [1,1,1];  - internal correlations
% A.n       = [1,1,1];      - no. of objects per cluster
% A.I       = [1,2,3]   - cluster index
% A.e       = [0,0,0];  - internal energies
% A.updates = 0         - no. of spin updates
% A.b       = ib        - inverse temperature = initial beta
% A.splits  = 0         - number of splits,
%
%
% Example 2:
%     A.I = [1  8 5 9 0 0 0];
%           [0 0 0 0 0 0 0 ];
%           [6  7 0 0 0 0 0];
%           [0 0 0 0 0 0 0 ];
%           [4  2 0 0 0 0 0];
%           [0 0 0 0 0 0 0 ];
%           [0 0 0 0 0 0 0 ];
%           [3 10 0 0 0 0 0];
%           [0 0 0 0 0 0 0 ];
%           [0 0 0 0 0 0 0 ];
%
%   A.a   = [1 5 8 5 1 3 3 1 1 8];
%   A.a(5)= 1, means that the 5-th object is in the 1st cluster.
%
%   A.nc  = 4; There are 4 non-empty clusters in the configuration
%
%   A.nec = [1 3 5 8]; An array index of non-empty clusters

% Author: Tim Gebbie, Bongani Bambiso 2006

% 1.2 2009/02/06 13:11:50 Tim Gebbie


switch nargin
  case 2
    C = varargin{1};
    initial_type = 'random';
  case 3
    C = varargin{1};
    initial_type = varargin{3};
  otherwise
    error('Incorrect Input Arguments');
end

A = varargin{2};
% find the size of the correlation matrix
[p,q]=size(C);

% rescale the correlation matrix for use of
% it upper triangular form
for i=1:p-1,
  for j=i+1:p,
    C(i,j)=2 * C(i,j);
    C(j,i)=C(i,j);
  end;
    C(i,i)=1;
end;
% ensure that the diagonals are normalized correctly
C(p,p)=1;

% initialize from correlation matrix
switch initial_type,
    case 'random'
        for j=1:p,
            a(j) = floor(rand(1)*p)+1; 
        end
                
    case 'sequential', 
        for j=1:p,
            a(j) = j; 
        end

    otherwise
        error('Incorrect Sweep Type');    
end;

% initial configuration variables
n = ones(p,1);
c = ones(p,1);
e = zeros(p,1);
I = zeros(p,p);

% Initial Configuration Index
A.n = n; % number of cluster objects
A.n_new = A.n;
for i = 1:p,         % clusters
    for j = 1:A.n(i),     % objects per cluster
        I(i,j) = a(i);
    end;
end;

% Configuration variables
A.a     = a;           % configuration
A.I     = I;           % configuration index
A.c     = c;           % control parameter    
A.e     = e;           % energy
A.nec   = a;           % Index array of Non-empty clusters        
A.nc    = length(A.a); % no. of non-empty clusters in the configuration
A.C     = C;           % Correlation matrix

% simulated annealing variables
A.updates = 0; % number of spin updates, per spin, per sweep
A.merges  = 0; % number of merges, per sweep
A.splits  = 0; % number of splits, per sweep
A.cycle   = 0; % number of annealing / temperature clycles
A.t       = 0; % time, counts the number of steps.
A.s       = 1; % spin sign flag is +1 for increasing and -1 for decreasing
% ground state data
A.gs.a       = A.a;
A.gs.nc      = length(A.a); % number of non-empty clusters 
A.gs.nec     = A.nec;       % index array of non-empty clusters
A.gs.I       = A.I; 
A.gs.n       = A.n;
A.gs.c       = A.c;
A.gs.C       = A.C;
A.gs.e       = A.e;
A.gs.b       = A.b;
A.gs.updates = 0;  
A.gs.merges  = 0; 
A.gs.splits  = 0; 
A.gs.cycle   = A.cycle; 
A.gs.t       = 0; 
A.gs.s       = A.s; 


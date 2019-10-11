function [A] = annealing(varargin)
% ANNEALING Find the maximum likelihood cluster configuration
%
% [A] = ANNEALING(VARARGIN) Find the Maximum likelihood configuration, 
% using the Metropolis Scheme or Simulated annealing method and 
% the J.D. Noh's Model. The algorithm finds the ground state,which is the 
% best configuration at the end of the algorithm simulation.
%
% [A] = ANNEALING(DATA,IB,FB,T_STEPS,N_CYCLES,CF,CORR_M )  Uses the data
% to compute the correlation matrix, which is used to find the maximum 
% likelihood configuration of the data. CORR_M specifies the method used 
% to compute correlation matrix. It takes values 1, 2, and 3, which 
% represent 'Pearson', 'Kendal' and 'Spearman', respectively. All the other 
% variables are annealing variables and they are described below.
%
% [A] = ANNEALING(C,IB,FB,T_STEPS,N_CYCLES,CF)  Takes the correlation 
% matrix, and use it to find the maximum likelihood configuration of 
% the data. Other variables are Annealing input varaibles (see below).
%
% A is the configuration data structure and has structure described below.
% A(i)=j gives that the i-th object is in the j-th cluster. 
% The configuration index I, where I(i,j)=k gives k object as the
% j-th element of the i-th cluster. E(i) is the likelihood
% per element of the i-th cluster. C is the similarity the correlation 
% matrix. Here it can be taken as the Pearson matrix or Kendal's 
% Coefficient. This is taken to be a square matrix of the size of the 
% number of objects. 
%
% ANNEALING VARIABLES:
% IB       - initial beta
% FB       - final beta
% T_STEPS  - Steps of Temperature changes
% CF       - factor for change in temperature
%
%
% DATA STRUTURE OF THE CONFIGURATION [A]
%
% Status of the system during the annealing process: 
% These variables keep track of the current solution of the maximum 
% likelihood problem.
% A.N       - Original data size
% A.a       - the current solution configuration
% A.nc      - number of (non-empty) clusters in the current configuration
% A.nec     - Index array of Non-empty clusters
% A.b       - current inverse temperature (beta).
% A.c       - internal correlations
% A.C       - Correlation matrix
% A.e       - energy (minus log of likelihood), which is being minimized.
% A.n       - number of elements per cluster
% A.I       - configuration index
% A.t       - time, counts the number of steps.
% A.cf      - cooling factor for delta_temperature
% A.updates - no. of spin updates per sweep
% A.merges  - number of merges per sweep  
% A.splits  - number of splits per sweep
% A.t_steps - number of sweeps between changes in temperature
% A.cycle   - number of annealing/ temperature clycles
% A.n_cycles- maximum number of annealing/ temperature clycles
%
% Ground state parameters:
% These paramters represent the final solution, the best configuration that
% gives the best maximum likelihood.
% A.gs.a       - the best configuration
% A.gs.nc      - number of clusters in the final solution configuration
% A.gs.nec     - Index array of Non-empty clusters
% A.gs.b       - Ground state energy (per spin).
% A.gs.c       - internal correlations
% A.gs.C       - Correlation matrix
% A.gs.e       - energy (minus log of likelihood),which is being minimized.
% A.gs.I       - configuration index
% A.gs.n       - number of ground state elements per cluster cluster
% A.gs.t       - time, counts the number of steps.
% A.gs.updates - no. of spin updates, per spin, per sweep, or
%                the no. of times a better configuration was found in
%                the same temperature or cooling schedule
% A.gs.merges  - number of mergings, per sweep
% A.gs.splits  - number of splitting, per sweep
% A.gs.cycle   - number of annealing / temperature clycles
%
%
% See Also : PEARSON, KENDALL, SPEARMAN, LIKELIHOOD, AVERAGE
%            CHANGE, ENERGY.
%
% References:
%
% 1) J. D. Noh  (2000)
% 2) Marsili M. (2002)
% 3) L. Giada & Marsili M (2005)
% 4) Metropolis, N., Rosenbluth. A. W. (1953)
%

% Authors: Bongani Mbambiso, Tim Gebbie 

% 1.2 2009/02/06 13:11:50 Tim Gebbie

% Input annealing variables
ib = varargin{2};           % the initial beta /inverse temperature
fb = varargin{3};           % the final beta
t_steps = varargin{4};      % No. of sweeps between changes in temperature
n_cycles = varargin{5};     % Max. number of annealing cycles  
cf = varargin{6};           % the cooling factor

switch nargin,
    case 6,
        % get the correlation matrix
        C = varargin{1};
        % find the matrix rank
        [m,n]= size(C); 
      
    case 7,
        % get the input data          
        data = varargin{1,1};
        % Get the correlation matrix
        if varargin{7} == 1,  
            % using Pearson's Coefficient
            C = pearson(data);
        elseif varargin{7} == 2,
            % using Kendall's rank correlation coefficient
            C = kendall(data);
        elseif varargin{7} == 3,
            % using Spearman Rank order correlation matrix 
            C = spearman(data);
        else
            error('Incorrect Correlation method');
        end;
        % Get the size of the correlation matrix
        [m,n]=size(C);
    otherwise
        error('Incorrect number of input arguments');
end;

% initialize configuration parameters
A.N       = m;        % no. of objects in the data
A.cf      = cf;       % cooling schedule factor
A.ib      = ib;       % initial beta
A.fb      = fb;       % final beta
A.b       = ib;       % current beta takes the initial value
A.t_steps = t_steps;  % Max. no. sweep iterations per  constant temperature
A.n_cycles= n_cycles; % max. number of annealing cycles   
% more initial configuration parameters
A = configuration(C,A,'sequential');

%-------- TEMPERATURE CYCLE / ANNEALING CYLCE ---------------
% cycle is not complete
complete = false;
h = waitbar(0,'Annealing cycle');
while ~complete;
    waitbar(A.cycle/A.n_cycles,h);
    %%%%%%%%%%%% SWEEPING CYCLE THROUGH THE LATTICE %%%%%%%%%%%%%%%%%%%% 
    A = change(A);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % invert cooling schedule factor
    A.cf = 1 / A.cf;  
    % swaps the initial with final
    b_i  = A.ib;
    A.ib = A.fb; 
    A.fb = b_i;
    A.b  = A.ib;     % the current cooling schedule
    
    % EXIT CONDITIONS
    % Up(1) and Down(-1) through the cooling schedule range is a full cycle
    if (A.s==-1); % downwards direction on the cooling schedule
        if (A.cycle == A.n_cycles),
            complete = true;
        else,
            A.cycle = A.cycle + 1;
        end;
    else,
        % continue with the cycle in an opposite temperature direction
        complete = false;
        % Invert temperature direction
        A.s = - A.s;
    end;    
end; % while not complete
close(h); 

% Number of clusters (non-empty clusters) in the currrent configuration
A.nc = 0;
% Index Array of Non-empty clusters
A.nec = [];
j = 0;
for s = 1:A.N,                    % loop through clusters
    if(A.n(s)>0);             % if cluster s is not empty
        j = j + 1;
        A.nc = A.nc + 1;  % number of non_empty clusters
        A.nec(j) = s;         % index array of non-empty clusters
    end; % if cluster s is not empty
end;  % for loop through clusters


%------------END OF THE ANNEALING CYCLE ------------------


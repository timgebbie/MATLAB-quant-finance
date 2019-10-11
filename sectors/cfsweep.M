function A = cfsweep(A, sweep_type)
% CFSWEEP Randomly or sequential sweep through the lattice.
%
% [A] = CFSWEEP(A, SWEEP_TYPE) This function sweeps through the lattice by
% randomly swapping elements or spins between pairs of clusters, check if 
% that new pair of clusters improves the energy of the system i.e dE <=0. 
% If the formation of a new pair improves the system energy, the new
% configuration is kept as a  new solution configuration. If dE > 0, it 
% takes a solution with a probability p = exp(-dE/bT)
% (Boltzmann probability) as new solution. b - is the inverse temperature. 
% In this way, the function tries to find a new configuration with a better
% energy level, at the same constant temperature (Metropolis scheme), then
% then recomputes the configuration variables. SWEEP TYPE can be either
% 'sequential' or 'random'.
%
% [A] is a new configuration with changed pairs of spins or elements.
% This  function also counts, with A.UPDATES, how many spin interactions 
% were broken or how many new configurations resulted in an improvement in
% the energy of the entire system.
%
% See Also: ENERGY, CFUDPATES, CFRESET

% Author: Tim Gebbie, Bongani Bambiso 2006

% $Revision: 1.2 $ $Date: 2009/03/31 06:46:33 $ $Author: Tim Gebbie $

% set the number of sweeps to zero
A.updates = 0;

% loop through all objects in clusters/ in data 
for m = 1:A.N,
    % initial cluster  
    switch sweep_type, 
        case 'random' 
            % choose an initial/ 1st object randomly from the lattice
            i = floor(A.N*rand(1)) + 1;
        case 'sequential'
            i = m;
        otherwise
            error('Unknown Sweep Type');
    end; % switch
    
    a_i = A.a(i); % object i is in initial cluster a_i   
   % final/ 2nd random cluster
    a_f = floor(A.N*rand(1))+1;
    % second cluster must not be initial nor a relabelling
    while (a_f==a_i) | (A.n(a_f)==0 & A.n(a_i)==1); 
        a_f = floor(A.N * rand(1)) +1;
    end; % while
    
    % Temporal Cluster Configuration Index matrix  
    I_new = A.I;
    
    % REASIGNING CONFIGURATION: Swapping elements between pairs of clusters
    % Remove object i from inittial cluster a_i 
    if (A.n(a_i)==1);        
        % cluster with one element
        n_i_new = 0;
        c_i_new = 0;
        e_i_new = 0;
        % Empty up the cluster a_i in the temporal membership matrix
        I_new(a_i,:) = 0;
    else,
        % initial internal correlations of this new cluster cluster
        c_i_new = A.c(a_i);  
        % new internal correlations of this new cluster cluster
        for j = 1:A.n(a_i),                
            x = A.I(a_i,j);
            c_i_new = c_i_new - A.C(i,x);  
        end;
        % new no. of objects in cluster a_i
        n_i_new = A.n(a_i) - 1; 
        % new initial cluster energy
        e_i_new = energy(n_i_new,c_i_new);
        
        % Updating the temporal cluster membership matrix
        for k=1:A.n(a_i), % loop through objects of cluster a_i
            % Cluster a_i 's k-th element is the object x of the data
            x = A.I(a_i,k); 
            % removing the object or the spin on the Index matrix
            if (x == i); % searching for the object i, to remove from a_i                
                for j = k:n_i_new,
                    % shift cluster elements by one element up/to the left
                    I_new(a_i,j) = I_new(a_i,j+1);
                end;
                % Empty up the last object space
                I_new(a_i,A.n(a_i)) = 0;                                
                % after finding i in a_i, stop the "for k" loop 
                k = A.n(a_i); 
            end;% if x==i             
        end; % for k                  
    end; % if (A.n(i)==1);
    
    
    % the number of elements in the new cluster
    n_f_new = A.n(a_f) + 1;
    % Add object i into final cluster a_f
    % ....add the object on the Index matrix as the last object
    I_new(a_f,n_f_new) = i; 
    % new internal correlations of this final cluster cluster
    c_f_new = A.c(a_f);
    for j = 1:A.n(a_f),                
        x = A.I(a_f,j);
        c_f_new = c_f_new + A.C(i,x); 
    end; 
    c_f_new = c_f_new + 1;
    % final cluster energy 
    e_f_new = energy(n_f_new,c_f_new);        
    % change in energy
    de = e_i_new + e_f_new - (A.e(a_i) + A.e(a_f));
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % METROPOLIS ALGORITHM %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    index_update = false;  % index update flag
    gs_update    = false;  % ground state update flag
    if (de<0);
        % accepting the improving case 
        index_update=true;
        gs_update=true;
    elseif (rand(1)<exp(-A.b * de)); 
        % accepting the non-improving case
        index_update=true;
    else,
        % don't accept the new configuration
    end; % if energy change is negative 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % UPDATING the configuration matix (remove i from cluster a(i) )
    % and add the new index to another cluster.
    if index_update;
        % update configuration structure         
        % cluster with 1 element less than before
        A.n(a_i) = n_i_new;
        A.c(a_i) = c_i_new; 
        A.e(a_i) = e_i_new;
        % cluster with 1 element more than before
        A.n(a_f) = n_f_new;
        A.c(a_f) = c_f_new;
        A.e(a_f) = e_f_new;
        % update Potts variable
        A.a(i) = a_f;               
        % Updating the index matrix
        A.I = I_new; 
        % sweep update index        
        A.updates = A.updates + 1;
    end;
    
    % if an improving case was accepted, update the ground state
    if gs_update; 
        A = ground(A); 
    end; 
    
end; % end for m, the loop through all clusters 

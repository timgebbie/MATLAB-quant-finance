function A = cfmerge(A)
% CFMERGE Two clusters are merged.
%
% [A] = CFMERGE(A) Merge two randomly chosen clusters that have at least 2
% elements. Checks if energy permits configuration change, and then 
% recomputes or updates the configuration variables. It also updates the 
% ground state variables, only if the merge improves the energy of the 
% configuration.
%
% [A] is a new configuration of clusters, with two previous clusters joint
% to form a new cluster. This means that, the previous number of clusters
% drops by 1, i.e A.n_new = A.n -1. (See ANNEALING for the data 
% structure format of the configuration A).
%
% See Also: ENERGY, CFUDPATES, CFRESET

% Author: Tim Gebbie, Bongani Bambiso 2006

% $Revision: 1.1 $ $Date: 2009/02/06 13:11:59 $ $Author: Tim Gebbie $


% assume that there are no, at leaset, 2 clusters with 2 elements
can_merge = false;
% no. of objects with more than 2 elements
nm = 0;
% objects with atleast 2 elements
om = [];
% number of merges
A.merges = 0;
% find at least 2 cluster with 2 elements
for i=1:A.N,
    if (A.n(i) >= 2);
        nm = nm + 1;            
        om(nm) = i; % cluster i has atleast 2 elements 
    end;
end; % loop through N clusters

if nm >= 2;  
    can_merge = true;
end;

if can_merge;
    % Size of the array of clusters that can be merged
    [mm,nn] = size(om);
    % The initial cluster to be merged is chosen randomly from 
    %  "om[]", the array of clusters that can be merged
    % Pick at random 2 cluster with at least 2 elements from "om"
    z1 = floor(nn*rand(1))+1; 
    z2 = floor(nn*rand(1))+1;
    % 2nd randomly picked cluster must differ from 1st one
    while (z1==z2); % cluster indices on "om" must not be the same 
        z2 = floor(nn*rand(1))+1; 
    end;
    a_i = om(z1);  % 1st randomly picked cluster              
    a_f = om(z2);  % 2nd randomly picked cluster  
   
    % Create a temporal cluster configuration index matrix  
    I_new = A.I;        
    % New parameters of cluster a_i, empty up cluster a_i    
    I_new(a_i,:) = 0;
    n_i_new = 0;
    c_i_new = 0;
    e_i_new = 0; 

    % Find the new cluster parameters for cluster a_f 
    % new number of clusters for the new configuration
    n_f_new = A.n(a_f) + A.n(a_i);
    % reset the new configuration membership index   
    for k=1:A.n(a_i), 
        % combining clusters a_f & a_i, inside cluster a_f
        I_new(a_f, A.n(a_f)+ k) = A.I(a_i,k);        
    end;
    % reset the new configuration control parameters
    c_f_new = A.c(a_f);
    for k = A.n(a_f)+1: n_f_new, 
        for j = 1:k, 
            x = I_new(a_f,k);
            y = I_new(a_f,j);               
            c_f_new = c_f_new + A.C(x,y);  
        end;
    end;        
    % new configuration energy
    e_f_new = energy(n_f_new,c_f_new);
    % Change in energy
    de = e_f_new - (A.e(a_i) + A.e(a_f));        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % METROPOLIS ALGORITHM %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    index_update = false;  % index update flag
    gs_update    = false;  % ground state update flag
    % check if energy permits configuration change 
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
    
    if (index_update);
        % update configuration structure
        % Updating the index matrix
        A.I = I_new;                 
        % The empty cluster
        A.n(a_i) = n_i_new;
        A.c(a_i) = c_i_new;
        A.e(a_i) = e_i_new;
        % Merged cluster
        A.n(a_f) = n_f_new;
        A.c(a_f) = c_f_new;
        A.e(a_f) = e_f_new;                
        % Update the Potts variables
        for s = 1:A.N,           % loop through all clusters
            for si = 1:A.n(s),   % loop through objects of cluster s
                A.a(I_new(s,si)) = s;      % object 'x' is in cluster 's'
            end;
        end;        
        % sweep update index
        A.merges = A.merges + 1;    
    end;% if energy permits configuration change
    
    % if an improving case was accepted, update the ground state
    if gs_update; 
        A = ground(A); 
    end; 
    
else,
    % cannot merge two clusters in the configuration
    return;
end; % if 'can_merge' statement


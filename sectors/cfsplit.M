function A = cfsplit(A)
% CFSPLIT Split a randomly chosen cluster from configuration A.
%
% [A] = CFSPLIT(A) Split a cluster with atleast four elements into two
% cluster of  different nubmer of elements, depending on the correlation 
% distances between the elements in that. 

% If there is not cluster with four elements in the configuration,
% the configuration is left as it is, no splitting will occur. If the 
% splitting does not improve the temperature of the system, the 
% configuration remains the same.
% 
% See Also: ENERGY, CFUDPATES, CFRESET

% Author: Tim Gebbie, Bongani Bambiso 2006

% $Revision: 1.1 $ $Date: 2009/02/06 13:11:59 $ $Author: Tim Gebbie $


% assume that there is no cluster with more than 3 elements
can_split = false;
% An array of clusters to be split
SC = [];
% find cluster with more than 3 elements
kk = 0;
for i=1:A.N, 
    if (A.n(i)>3); 
        kk = kk + 1;
        % An array of clusters to be split
        SC(kk) = i;             % cluster i has elements > 3
    end; 
end;

% find 2 emtpy clusters
aff = [];                       % an array of emtpy clusters 
ec = 0;                         % counter for empty clusters
for i=1:A.N,
    if (A.n(i)==0);
        ec = ec + 1;
        aff(ec) = i;            % cluster i is an empty cluster        
    end;
    if ec >= 2; i=A.N; end;     % sto the loop, and conitune
end; 

% there must be at least 2 empty clusters & 1 cluster with > 3 elements 
if(ec >= 2 & kk >= 1);
    can_split = true;
end;

% split one cluster
if can_split;
    % Temporal Cluster membership matrix  
    I_new = A.I;
    % declaring empty cluster index variable
    ii  = zeros(2,1);
    % Size of the array of clusters that can be split
    [mm,nn] = size(SC);
    % The initial cluster to be split is chosen randomly from 
    %  SC, the array of clusters with more than 3 elements
    z = floor(nn*rand(1)) + 1; 
    % The initial cluster 
    a_i = SC(z); 
    
    %Find the FIRST PAIR of two elements to be removed from a_i 
    % Pick the 2 most distant elements based on correlations, inside the
    % cluster with more than 3 elements, cluster a_i
    c_max = 2 ;           % Initialize the longest correlation distance
    for i=1:A.n(a_i)-1,
        for j=i+1:A.n(a_i),
            % max correlations distance
            if (c_max > A.C(A.I(a_i,i),A.I(a_i,j)));
                 c_max = A.C(A.I(a_i,i),A.I(a_i,j));
                 % Elements that resulted in a max correlation distance
                 % Put or index these elements on the 1st & 2nd empty
                 %      clusters 
                 I_new(aff(1),1) = A.I(a_i,i);  % 1st element
                 ii(1) = A.I(a_i,i);              % Store 1st elemt
                 % index position of 1st element
                 i_indx = i;            
                 I_new(aff(2),1) = A.I(a_i,j);  % 2nd element
                 ii(2) = A.I(a_i,j);              % Store 2nd elemt
                 % index position of 2nd element
                 j_indx = j;                  
            end; % if correlations distance is max
        end; % j
    end; % i
    
    % Remove the elemts from a_i, (the cluster with more than 3 elements)
    I_new(a_i,i_indx) = 0;   % Remove the 1st element  
    I_new(a_i,j_indx) = 0;   % Remove the 2nd element
    
    % Shuffle the elements
    if i_indx < j_indx;   %  1st element is closer than the 2nd element
        for si = j_indx : A.n(a_i)-1,
            % shift cluster elements by one element up/to the left
            I_new(a_i, si) = I_new(a_i, si+1);
        end;        
        for si = i_indx : A.n(a_i)-1,
            % shift cluster elements by one element up/to the left
            I_new(a_i, si) = I_new(a_i, si+1);
        end;  
    else,                 %  2nd element is closer than the 1st element
        for si = i_indx:A.n(a_i)-1,
            % shift cluster elements by one element up/to the left
            I_new(a_i, si) = I_new(a_i, si+1);
        end;        
        for si = j_indx : A.n(a_i)-1,
            % shift cluster elements by one element up/to the left
            I_new(a_i, si) = I_new(a_i, si+1);
        end;  
    end;            
    I_new(a_i,A.n(a_i)) = 0;   % the last element becomes zero
    I_new(a_i,A.n(a_i)-1) = 0; % the 2nd last element becomes zero
    
    % no. of elements in each former empty cluster   
    nff(1) = 1;
    nff(2) = 1;
    % control parameters or internal correlations
    cff(1) = 1;
    cff(2) = 1;
    
    % Remove the rest of the elements from a_i to clusters aff(1) & aff(2)
    % Divide elements in a_i according to the correlation distance A.C(i,j)
    for i=1:A.n(a_i)-2,  
        % Loop through elemens of cluster a_i
        j = I_new(a_i,i);
        % if first correlation is larger than the second
        if (A.C(ii(1),j) > A.C(ii(2),j)); 
            % increment the no. of objects in the 1st former empty cluster
            nff(1) = nff(1) + 1;          
            % add the element removed from cluster a_i to cluster aff(1)
            I_new(aff(1), nff(1)) = j;                          
            % control parameters or internal correlations
            for k=1:nff(1), 
                x = I_new(aff(1),k);
                cff(1) = cff(1) + A.C(x,j);
            end % k
        else,   % first correlation is not larger than the second                  
            % increment the no. of objects in the 2st former empty cluster
            nff(2) = nff(2) + 1;          
            % add the element removed from cluster a_i to cluster aff(2)
            I_new(aff(2), nff(2)) = j;                          
            % control parameters or internal correlations
            for k=1:nff(2),
                x = I_new(aff(2),k);
                cff(2) = cff(2) + A.C(x,j);
            end; % for k         
        end;
    end; % for i 
        
    % configuration parameters
    n_i_new = 0;
    c_i_new = 0;
    e_i_new = 0;
    % empty up cluster a_i     
    I_new(a_i,:) = 0;
    
    % find the energies
    for i=1:2, 
        eff(i)=energy(nff(i),cff(i)); 
    end;
    % change in energy
    de = eff(1) + eff(2) - A.e(a_i);
    
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
    
    if index_update;
        % update configuration structure                     
        % update the cluster variables
        A.n(a_i) = n_i_new;
        A.c(a_i) = c_i_new;
        A.e(a_i) = e_i_new;
        for i=1:2,
            A.n(aff(i)) = nff(i);
            A.c(aff(i)) = cff(i);
            A.e(aff(i)) = eff(i);
        end; 
        % Updating the index matrix
        A.I = I_new; 
        % Update the Potts variables
        for s = 1:A.N,           % loop through all clusters
            for si = 1:A.n(s),   % loop through objects of cluster s
                x = I_new(s,si);
                A.a(x) = s;      % object 'x' is in cluster 's'
            end;
        end;
        % the split counters
        A.splits = A.splits+1;
        % update the ground state if necessary
        if (gs_update); 
            A = ground(A); 
        end;
    end; % energy conditions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
else,
    % cannot split the configuration
    return;
end; % if can split






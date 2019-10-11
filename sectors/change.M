function A = change(A)
% CHANGE Find a new configuration. 
%
% [A] = CHANGE(A) Change the configuration A by cycling through the current 
% cluster configuration, with a constant temperature, find a new 
% configuration A, with a better clustering solution.
%
% This function rearranges a lattice configuration A, and finds a 
% configuration which increased energy, at a constant temperation or 
% cooling schedule. Configuration
% membership index, INDEX, initial internal energies, E, at
% a given inverse temperature BETA. NR is the number of
% configuration changes. At time T.
%
% First a random lattice configuration change is attempted
% by swapping two elements between different clusters via a
% lattice sweep. A random cluster merge is attempted. A 
% random cluster split is attempted. 
% 
% See Also: CFSWEEP, CFMERGE, CFSPLIT

% Author: Tim Gebbie, Bongani Bambiso 2006

% 1.2 2009/02/06 13:11:50 Tim Gebbie


% keep on going in the same cooling temperature direction
invert_temperature = false;
% while moving in the same temperature direrction
while ~invert_temperature;  
    % the number of sweeps per tempeature
    A.t = 0;
    % max. no. of sweeps has not been reached
    while(A.t < A.t_steps);
        % random lattice sweep
        A = cfsweep(A, 'random');
        % random lattice merge               
        A = cfmerge(A); 
        % random lattice split          
        A = cfsplit(A); 
        % Increment counter of sweeps per temperature    
        A.t = A.t + 1; 
    end; 
   
    % Conditions to change Temperature direction 
    if (A.s==1);                        % for increasing Temperature
        % if the final beta has been reached in an increasing temperature
        % direction
        if (A.b >= A.fb);             
            invert_temperature = true;  % change temperature direction                                    
        end;
    end; % increasing temperature
    if (A.s==-1);                       % for decreasing Temperature
        % if the final beta has been reached in decreasing temp. direction
        if (A.b <= A.fb);     
            invert_temperature = true;  % change temperature direction 
        end;
    end; % decreasing temperature
    
    %Go to the next beta value 
    A.b = A.b/A.cf;  
end; % while invert_temp

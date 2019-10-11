function A=sweep(A),
% A=SWEEP(A) Randomize lattice
% 
% Randomly sweep through the lattice and randomize by 
% swapping pairs of elements between pairs of clusters

% $Revision: 1.1 $ $Date: 2008/07/01 14:51:29 $ $Author: Tim Gebbie $

% initialize
sweep_type = 'random';

% the number of objects
[p,q]=size(A.a);

% set the number of sweeps to zero
A.updates = 0;

% loop through all objects
for m=1:p,
  % initial cluster and object
  switch sweep_type,
    case 'random'
      i = round(p * rand(1)) + 1;
    case 'sequential'
      i = m;
    otherwise
      error('unknown type');
  end
  % final object
  a_i = A.a(i);
  a_f = a_i;
  % second object must not be initial nor a relabelling
  while ((a_f==a_i) & (A.c(a_f)==0 & A.c(a_i)==1)), 
    a_f = floor(p * rand(1)) +1;
  end
  % reassign configuration
  % FIRST CONFIGURATION CHANGE
  if (A.n(i)==1),
    % cluster with one element
    n_i_new = 0;
    c_i_new = 0;
    e_i_new = 0;
  else
    % cluster with more than one element
    c_i_new = A.c(i);
    for k=1:A.n(i),
      % the initial clusters k-th element 
      % is the k-th object
      j=A.i(a_i,k);
      c_i_new=c_i_new-A.C(i,j);
    end % for k
    % number of elements in initial cluster
    n_i_new = A.n(a_i)-1;
    % new initial cluster energy
    e_i_new = energy(n_i_new,c_i_new);
  end % if not only one cluster
  % SECOND CONFIGURATION CHANGE
  % the number of elements in the cluster
  n_f_new = A.n(a_f) + 1;
  d_c_f   = 0;
  for k=1:A.n(a_f),
    j=A.i(a_f,k);
    d_c_f=d_c_f+A.C(i,j);
  end % for k
  % new final cluster control
  c_f_new = A.c(a_f) + 1 + d_c_f;
  % new final cluster energy
  e_f_new = energy(n_f_new,c_f_new);
  % change in energy
  de=e_i_new + e_f_new - (A.e(a_i) + A.e(a_f));
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % METROPOLIS ALGORITHM %%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     index_update = false;
     gs_update    = false;
  if (de<0),
     index_update = true;
     gs_update = true;
  else (rand(1)<exp(-A.b(1) * de)),
     index_update = true;
  end % if energy change is negative
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove i from cluster a(i)
% and add the new index to another cluster.
if index_update,
   for k=1:n(a_i)-1,
      if (A.i(a_i,k)==i), % is first object
        A.i(a_i,k)= A.i(a_i,A.n(a_i));  
      end;
    end;
      % add the new index
      A.i(a_f,n_f_new)=i;
      % update cluster
      A.n(a_i) = n_i_new;
      A.c(a_i) = c_i_new;
      A.e(a_i) = e_i_new;
      A.n(a_f) = n_f_new;
      A.c(a_f) = c_f_new;
      A.e(a_f) = e_f_new;   
      % update Potts variable
      A.a(i) = a_f;
      % sweep update index
      A.updates = A.updates + 1;
end;
% update the ground state
if gs_update, A = ground(A); end;

end % end loop through all clusters
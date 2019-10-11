function A = merge(A)
% A = MERGE(A) 2 clusters are merged
%
% Randomly merge two clusters that have at least 2
% elements. Recompute the configuration variables.

% $Revision: 1.1 $ $Date: 2008/07/01 14:51:29 $ $Author: Tim Gebbie $

A.merge =0 ;

% the number of objects
[p,q]=size(A.a);

% assume that there are not at leaset 2 clusters with 2 elements
can_merge = false;
% find at least 2 cluster with 2 elements
for i=1:p,
  if (A.n(i)>2),
    A.merge = A.merge +1;
    if A.merge==2, can_merge = true; end;
  end,
end; % p look through objects

if can_merge,
  % pick at random 2 cluster with at least 2 elements
  a_i = floor(p*rand(1))+1;
  % the first cluster with 2 elements
  while (A.n(a_i)<2), a_i = floor(p*rand(1))+1; end;
  a_f = floor(p*rand(1))+1;
  % the second cluster with 2 elements that is not the first cluster
  while ((A.n(a_f)<2) | (A.n(a_f)==A.n(a_i))), a_f = floor(p*rand(1))+1; end;
  
  % new cluster parameters
  n_i_new = 0;
  c_i_new = 0;
  e_i_new = 0;
  
  % find the new configuration number of clusters
  n_f_new = A.n(a_f) + A.n(a_i);
  % reset the new configuration membership index
  for k=1:A.n(a_i), A.i(a_f,A.n(a_f)+k)=A.i(a_i,k); end;
  % reset the new configuration control parameters
  c_f_new = A.c(a_f);
  for k=A.n(a_f)+1:n_f_new, 
    for j=1:k,
      c_f_new = c_f_new + A.C(A.i(a_f,k),A.i(A_f,j);
    end;
  end;
  % new configuration energy
  e_f_new=energy(n_f_new,c_f_new);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % METROPOLIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  de = e_f_new - (A.e(a_i) + A.e(a_f));
  if (rand(1)<exp(-A.b(1)*de),
    % update the Potts variables
    for k=1:A.n(a_i), A.a(A.i(a_i,k))=a_f; end;
    % update the cluster variables
    A.n(a_i)=n_i_new;
    A.c(a_i)=c_i_new;
    A.e(a_i)=e_i_new;
    A.n(a_f)=n_f_new;
    A.c(a_f)=n_f_new;
    A.e(a_f)=e_f_new;
    % update the merge counter
    A.merge = A.merge +1;
    % update the ground state if necessary
    if (de<0), A=ground(A); end;
  end % if energy permits configuration change
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
  % cannot merge two clusters in the configuration
  return;
end
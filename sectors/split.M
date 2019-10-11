function A = split(A),
% A=split(A) Randomly split the configuration
%
%
%

% get the number of objects
[p,q]=size(A.a);
% assume that there is no cluster with more than 3 elements
can_split = false;
% find a cluster with more than 3 elements
for i=1:p, if (A.n(i)>3), can_split=true; end; end;

if can_split,
  % initial cluster
  while (A.n(a_i)<4), a_i = floor(p * rand(1)) +1; end;
  % find the empty clusters
  k=1;
  for i=1:p,
     if (A.n(i)==0),
       ff(k)=i;
       k=k+1;
     end
  end % loop through objects
  % pick the 2 most distant elements based on correlations
  % initialize the correlation distance
  c_max=2;
  for i=1:A.n(a_i)-1,
    for j=i+1:A.n(a_i),
      if (c_max>C(A.i(a_i,i),A.i(a_i,j))),
        c_max = A.C(A.i(a_i,i),A.i(a_i,j));
        ii(1) = A.i(a_i,i);
        ii(2) = A.i(a_i,j);
        nff(1)= 1;
        nff(2)= 1;
      end % if correlations distance
    end % j
  end % i
  % control
  cff(1) = 1;
  cff(2) = 1;
  % divide the cluster according to the correlation distance
  for i=1:A.n(a_i),
    j = A.i(a_i,i);
    % if object is not the i-th nor j-th element of a_i cluster 
    if (j~=ii(1)) & ( j~=ii(2)),
      % if first correlation is larger than the second
      if (A.C(ii(1),j) > (A.C(ii(2),j),
        nff(1)=nff(1)+1; 
        A.i(aff(1),nff(1))=j;
        for k=1:nff(1), 
          cff(1)=cff(1)+ A.C(A.i(aff(1),k),j);
        end % k
      % second correlation is not larger than the second  
      else  
        nff(2)=nff(2)+1;
        A.i(nff(2),nff(2))=j;
        for k=1:nff(2),
          cff(2)=cff(2)+A.C(A.i(aff(2),k),j);
        end;
      end % end correlation gt/lt condition
    end % end if j is the i,j-th element of a_i condition
  end % i
  % configuration parameters
  n_i_new = 0;
  c_i_new = 0;
  e_i_new = 0;
  % find the energies
  for i=1:2, eff(i)=energy(nff(i),cff(i)); end;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % METROPOLIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  de = eff(1) + eff(2) - A.e(a_i);
  if (rand(1)<exp(-A.b(1) * de),
    % update Potts variable
    for i=1:2,
      for k=1,nff(i),
        A.a(A.i(aff(i),k))=aff(i);
      end
    end
    % update the cluster variables
    A.n(a_i)=n_i_new;
    A.c(a_i)=c_i_new;
    A.e(a_i)=e_i_new;
    for i=1:2,
      A.n(aff(i))=nff(i);
      A.c(aff(i))=cff(i);
      A.e(aff(i))=eff(i);
    end
    % the split counters
    A.splits=A.splits+1;
    % update the ground state if necessary
    if (de<0), A=ground(A); end;
  end % energy conditions
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
  % cannot split the configuration
  return;
end



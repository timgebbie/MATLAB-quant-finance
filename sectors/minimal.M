eitherfunction [e0,c0,n0,ij,de] = minimal(e,c,n)
% MINIMAL Find the next deterministic minimal combination of clusters 
%
% [E0, C0, NO, IJ, DE] = MINIMAL(E,C,N) This function computes, E0 the
% energy of the new configuration, C0 the new pearson coefficient, N0 the
% new number of objects in a given cluster, IJ the merged and minimal
% cluster index, and DE the change in energy of the configuration.
% I is the cluster configuration index. DE is the change in energy of the
% configuration. C is the new pearson coefficient. N is the new number of 
% objects in a given cluster.
%
% NOTES: In IJ, I and J are the merged clusters, the j-th cluster is eliminated
% from the set of clusters after being merged with the i-th cluster,
% reducing the previous number of cluster by 1. Brute force search.
%
% See Also : ENERGY

% Authors: Bongani Mbambiso, Tim Gebbie 

% 1.2 2009/02/06 13:11:50 Tim Gebbie


% Minimum number of clusters to be:
% - merged
i_min = 1;
% - eliminated
j_min = 1;

% Initial / Minimum pearson coefficient to the current one 
c_min = 0;

% Minimum number of objects per cluster in any configuration
n_min = length(n) ;


% brute force search
m = length(n);
% get all the combinations of clusters
e_min = 1e4;

%---- Find the next minimal combination of clusters ------
for i = 1 : m -1 ,
  if n(i)>0,
    for j = i+1 : m, 
               
        % find the merged pearson coefficient
        c_new  = c(i,i) + 2 * c(i,j) + c(j,j);   
        % find the merged number of clusters 
        n_new = n(i) + n(j);    
        % calculate the combined energies of the i-th and j-th clusters.
        e_new = energy(n_new,c_new);      
        % the potential change in energy 
        de = e_new - (e(i) + e(j));
        
        % if the energy decreases reset the parameters and 
        % merge the i-th and j-th clusters into the i-th cluser      
        if de < e_min,
            c_min = c_new;
            e_min = de;
            n_min = n_new;
            % ij is the merged clusters with the smallest energy change
            i_min = i;
            j_min = j; 
        end
    end
  end
end
  
  % update the configuration index
  ij = [i_min; j_min];
    
  % update the combined internal correlations
  c(i_min,:) = 2 * c(i_min,:) + 2 * c(j_min,:);
    
  % get the symmetric part of the control matrix replaced
  c(:,i_min) = transpose(c(i_min,:));
    
  % update the pearson co-efficients
  c(i_min,i_min) = c_min;
     
  % update the number of clusters
  n(i_min)=n_min;
      
  % update the energy of the configurations
  e(i_min)=e_new;
  
  % reset the configuration parameters by removing j-th elements
  indx = find(1:m~=j_min);
  
  for i=1:m-1,
      n0(i)=n(indx(i));
      e0(i)=e(indx(i));
      
      for j=1:m-1,
          c0(i,j)=c(indx(i),indx(j));
      end,
  end,


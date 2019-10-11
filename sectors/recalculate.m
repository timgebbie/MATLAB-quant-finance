function A=recalculate(A)
% A = RECALCULATE(A) Recalculate the configuration parameters
%
% Using the current configuration solution A and the correlation matrix
% in upper triangular form A.C the followin are updated:
%
% 1. the internal correlations (control)  : A.c
% 2. The energies                         : A.e
%

% 1.2 2009/02/06 13:11:50 Tim Gebbie

% size of the membership index matrix: cls-clusters, obj-objects
[cls,obj]= size(A.I);

% find the configuration control parameters
for s=1:A.N,                     % loop through clusters
    A.c(s)=0;
    if (A.n(s)==0),              % empty cluster s
        A.c(s)=0; 
    end; 
    if (A.n(s)==1),              % one element in cluster s
        A.c(s)=1; 
    end; 
    if (A.n(s)>1),               % more than one element in cluster s      
        for si=1:A.n(s),         % objects of cluster s  
            for sj=si:A.n(s),    % upper triangular part              
                % add up the internal correlations
                x = A.I(s,si);
                y = A.I(s,sj);
                if(x>0 & y>0),           
                    A.c(s)=A.c(s)+A.C(x,y);           
                end;
            end;
        end;
    end;
end; 

% find the energies
for i=1:A.N,
    A.e(i)=energy(A.n(i),A.c(i));
end 

    
  
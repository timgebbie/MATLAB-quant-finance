function c = clusters(Z,codes,string,nc)
% C = CLUSTERS(Z,CODES,NC)
%
% CODES, Z is the linkaged and NC the number of clusters.
%

ci = cluster(Z,string,nc);
for i=1:max(ci),
    c{i}=codes(ci==i); 
end
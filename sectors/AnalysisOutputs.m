
function A=AnalysisOutputs(A)
% ANALYSISOUTPUTS Calculate, store, and output analysis variables.
%
% [A] = ANALYSISOUTPUTS(A) Output the ground state's total energy and 
% output the configuration characteristic. 
% The function desplays the coniguration in terms of clusters
% and their elements.

% $Revision: 1.1 $ $Date: 2009/02/06 13:12:06 $ $Author: Tim Gebbie $


% Total Energy
E = sum(A.gs.e);
sprintf('\nThe ground state has %d clusters, with energy = %f.',A.gs.nc,E)
for j = 1:A.gs.nc,
    Elements = [];
    s = A.gs.nec(j);
    y = A.gs.n(s);
    engy = A.gs.e(s);
    sprintf('\nCluster %d has an energy of %f & %d element(s) listed below:-',j,engy,y)
    for i= 1:y,
        Elements(s,i) = A.gs.I(s,i);
    end;
    sprintf('\n%d',Elements(s,:))
end;


function extract = extractData(data,beta)
% EXTRACTDATA extracts exponentially distributed data from an evenly spaced
% time series
%
% EXTRACT = EXTRACTDATA(data,beta)
%
% data    - [1:N,1:S] is a number of series with size N
% beta    - exponential mean used to extract data
% 
% EXTRACTDATA(data,beta) extract exponentially distributed data with an
% exponential mean of beta form the process data
%
% $Revision: 1.1 $ $Date: 2005-06-13 15:11:11+02 $ $Author: user $
%
% $Author Chanel Malherbe

%get the size of the series
[N,S] = size(data);
%get exponentially distributed sample points
for i=2:S
    m = 1;n = 1;
    while (n < N)
        extractTemp(i-1,1).data(m,1) = data(n,1);
        extractTemp(i-1,1).data(m,2) = data(n,i);
        m = m+1;
        %get index of next point
        n = n + round(exprnd(beta));
    end
end

[uniqueDates] = unique([extractTemp(1,1).data(:,1);extractTemp(2,1).data(:,1)]);
[extract] = zeros(size(uniqueDates,1),S);
extract(:,1) = uniqueDates;
[idAsset1Prices] = ismember(uniqueDates, extractTemp(1,1).data(:,1));
[idAsset2Prices] = ismember(uniqueDates, extractTemp(2,1).data(:,1));
% extract(idAsset1Prices==1,2) = extractTemp(1,1).data(idAsset1Prices==1,2);
% extract(idAsset2Prices==1,3) = extractTemp(2,1).data(idAsset2Prices==1,2);
m = 1;n = 1;
for i=1:size(uniqueDates,1)
    if idAsset1Prices(i,1)==1
        extract(i,2) = extractTemp(1,1).data(m,2);
        m = m+1;
    end
    
    if idAsset2Prices(i,1)==1
        extract(i,3) = extractTemp(2,1).data(n,2);
        n = n+1;
    end
end
    

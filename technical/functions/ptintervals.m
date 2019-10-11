function intervals = ptintervals(upVec, downVec)
% PTINTERVALS Intervals between peaks and trought in data
%
% INT = PTINTERVALS(UP,DOWN) Returns a vector containing the number of 
% periods between a "1" in one of the vectors UP, and the next "1" in 
% the other vector DOWN.
%
% See Also: HM

% $Revision: 1.1 $ $Date: 2008/07/23 05:24:39 $ $Author: Tim Gebbie $

% Author        - Daniel Polakow and Anthony Seymour
%                 Quantitative and Derivative Analyst
%                 Peregrine Securities
% Email address - danielp@peregrine.co.za 
% Website       - http://www.peregrine.co.za/
% Created       - 03 November 2006  
% Last revision - 09 November 2006

upOnesIndices = find(upVec > 0);
downOnesIndices = find(downVec > 0);

if((length(upOnesIndices) < 1) || (length(downOnesIndices) < 1))
    error('One of the vectors has no ones');
end

if(upOnesIndices(1) < downOnesIndices(1) )
    vecForMin = downOnesIndices;
    vecForMax = upOnesIndices;
else
    vecForMin = upOnesIndices;
    vecForMax = downOnesIndices;
end

PeakTroughPairs = [];
FoundEnd = 0;
while(FoundEnd < 1)
    NewPair = zeros(1,2);
    minIndices = find(vecForMax < min(vecForMin));
    NewPair(1,1) = max(vecForMax(minIndices));
    NewPair(1,2) = min(vecForMin);
    PeakTroughPairs = [PeakTroughPairs; NewPair];
    
    LastIndex = find(vecForMax == max(vecForMax(minIndices)));
    
    if(LastIndex < length(vecForMax))
        % Truncate vecForMax
        vecForMax = vecForMax(LastIndex + 1: end);
        
        % Swap vecForMax and vecForMin
        temp = vecForMax;
        vecForMax = vecForMin;
        vecForMin = temp;
    else
        FoundEnd = 1;
    end
end

intervals = PeakTroughPairs(:,2) - PeakTroughPairs(:,1);
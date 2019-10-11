function [datenums] = convertdatevecstodatenums(datevecs)
    for i=1:size(datevecs,1)
        currentDateVec = datevecs(i,:);
        datenums(i,1) = datenum(currentDateVec(1),currentDateVec(2),currentDateVec(3),currentDateVec(4),currentDateVec(5),0);
    end
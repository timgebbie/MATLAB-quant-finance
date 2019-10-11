function [nn nnInd] = fn(data,curWind,psell)

data(end,:)=[];
sD=size(data);
sC=size(curWind);
remainder=rem(sD(1),psell);
count=0;

for s=psell+remainder:psell:sD(1)
    count=count+1;
    linIndex=s-psell+1:s;
    segment=data(linIndex,:);
    dist=inf*ones(psell,1);
    for i=sC(1):size(segment,1)
        pastWind=segment(i-sC(1)+1:i,:);
        dist(i) = norm(curWind-pastWind);
    end
    [nnTemp nnIndTemp] = min(dist,[],1);
    nn(count)=nnTemp;
    nnInd(count)=linIndex(nnIndTemp);
end






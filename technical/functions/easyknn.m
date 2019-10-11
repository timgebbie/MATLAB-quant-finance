function [nn nnInd] = easyknn(data,curWind)
% KNN k-nearest neighbours
%
% [NN, Index] = KNN(Z,K) Program to find the k - nearest neighbors (kNN) 
% within a set of points. Given a data matrix with each row corresponding 
% to a vector, the program outputs the indexes of the k-NNs for every 
% vector in the matrix. It also outputs the corresponding Euclidean distances.
%
%

sD=size(data);
sC=size(curWind);
dist=inf*ones(sD(1),1);
for i=sC(1):sD(1)-1
    pastWind=data(i-sC(1)+1:i,:);
    dist(i) = norm(curWind-pastWind);
end
[nn nnInd] = sort(dist,'ascend');
nn(end-sC(1)+1:end,:)=[];
nnInd(end-sC(1)+1:end,:)=[];





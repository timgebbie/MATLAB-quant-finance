
clear all; clc;
load('iroquKinar');
x = [iroquKinar;iroquKinar(end,:)];
[m0,n0]=size(x);
% Optimization options
warning off;
options = optimset('fmincon');
options = optimset(options,'Display','off');
b0(1,:) = (1/n0)*ones(1,n0);
b = (1/n0) * ones(m0,n0);
% constraints
Aeq = ones(1,n0);
beq = 1;
ub = ones(1,n0);
lb = zeros(1,n0);
% initial controls
K = 5;
L = 10;
% unform distribution to weight the experts
startRow=53;
weightsTemp=zeros(K,L,n0);
wealthTemp=zeros(K,L);
weightFinal=zeros(m0,n0);
weights=ones(K*L,n0,m0)/n0;
SH = ones(K*L,m0);
qH = (1/(K*L)) * ones(K*L,m0);
qKL = (1/(K*L)) * ones(K*L,1);
wh = waitbar(0/m0,'fnn estimation in progress ...');
for n=startRow:m0-1
    waitbar(n/m0,wh,sprintf('fnn estimation in progress ... %d %%',round(100*n/m0)));
    weightsTemp=zeros(K*L,n0);
    for k=1:K
        xnk=x(n-k+1:n,:);
        for l=1:L
            sl=2+50*(l-1)/(L-1);
            psell=floor(n/sl);
            if(n>k+sl+1 && sl > k)
                [nn nnInd] = fn(x(1:n,:),xnk,psell);
                x_s=x(nnInd+1,:);
                [KLrow] = sub2ind([K,L],k,l);
                w = patternsearch(@(b0)logOptimalRet(b0,x_s),b0,[],[],Aeq,beq,lb,ub,[],options);
            end
            weightsTemp(sub2ind([K,L],k,l),:)=w;
            SH(KLrow,n+1) = SH(KLrow,n) * weightsTemp(KLrow,:) * x(n+1,:)';
        end
    end
    % 7.a. Create the expert mixture weights
    weights(:,:,n+1)=weightsTemp;
    qH(:,n) = qKL .* SH(:,n);
    % 7.b. construct the final weights and create the performance weighted 
    %  combination of experts.
    b(n,:) = sum(qH(:,n) * ones(1,n0) .* weights(:,:,n)) ./ sum(qH(:,n));
end
close(wh);

upr = sum(b.*(x(1:end,:)),2);
% compute thenominal returns
npr=[cumprod(upr(startRow:end,:)) cumprod(x(startRow:end,:))];
% Plot controls and returns
h1 = semilogy(npr);
ylabel('Nominal');
legend(h1,{'fnn','stock1','stock2'});
title(sprintf('fnn Strategy: %2.2f%',npr(end)));

% EOF

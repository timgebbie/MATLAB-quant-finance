%% Gyorfi et al Optimization
%
% See Also: CUMRET

%% The Data
clear all
load gyorfiData
sD=size(ibmCokeData);

%% Initialise optimization parameters
w0=[0.5 0.5];
Aeq = [1,1];
beq = 1;
lb = zeros(size(Aeq)); 
ub = ones(size(Aeq));

%% Optimization loop
warnings off;
options = psoptimset('Display','off');
tic
for k=1:sD(1)
    thisData=ibmCokeData(1:k,:);
    [w,fval,exitflag] = patternsearch(@(w)cumRet(w,thisData),w0,[],[],Aeq,beq,lb,ub,[],options);
end
toc

%% Alternative optimization
% Objective function
objfn = inline('-prod(transpose(transpose(w * transpose(x))))','w','x');
% Optimization
warnings off;
options = optimset('fmincon');
options = optimset(options,'Display','off');
tic
for k=1:sD(1)
    xd=ibmCokeData(1:k,:);
    [w1,fval,exitflag] = fmincon(@(w1)objfn(w1,xd),w0,[],[],Aeq,beq,lb,ub);
end
toc

%% Check the objective fucntion
x = randn(10,6);
w = [0.5 0.4 0 0 0 0.1];
objfn(w,x)
cumRet(w,x)
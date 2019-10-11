function [cir,icir,tt]=cirprc(y0,n,t,kappa,eta,lambda),

% initialize
rand('state',sum(100*clock));
randn('state',sum(100*clock));
% the grid
cir(1) = y0;
dt = t / n;
tt = [0:dt:t];
% CIR
for s = 1:n,
    Z = normrnd(0,1);
    cir(s+1) = abs( cir(s) + (kappa*(eta-cir(s)) - lambda^2/4) * dt + lambda * cir(s)^(1/2) * dt^(1/2) * Z +lambda^2*dt * Z^2/4);
end;  

% Integrate CIR
icir(1)=0;
for s=1:n,
    icir(s+1) = icir(s) + (cir(s) + cir(s+1))/2 * dt;
end


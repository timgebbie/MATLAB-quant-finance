function [VR,Zk,Zhk]=vrtest_003(x,k)
% 
% Syntax: [vr,zk,zhk]=vrtest_003(x,k)
%
% Calculates the Variance Ratio Test (VR Test) of a time series x, with
% and without the heteroskedasticity assumption.
% input  : x is a vector of time series 
%          k is a scalar  
% output : VR is the value of the VRTest
%          Zk is the homoscedastic statistic of the variance ratio
%          Zhk is the heteroscedastic statistic of the variance ratio
% *****************************************************************
% Reference:
% Lo A, MacKinley AC (1989): "The size and power of the variance ratio
% test in finite samples". Journal of Econometrics 40:203-238.
%
% Elaborated by : BEN HASSEN Anis 
% "Institut Supérieur de Gestion de Tunis" (ISG Tunis)
% University of Tunis
% 41, rue de la Liberté - Cité Bouchoucha - C.P. : 2000 Le Bardo
% Tunisia
% University e-mail: http:\\www.isg.rnu.tn\
% Personal e-mail: benhassenanis@yahoo.com
% _________________________________________________________________
% January 01, 2006.
%

rt1=diff(log(x)); % one period rate of return

T=length(rt1);
i=1:T-k+1;
M=zeros(T-k+1,k);
for j=1:k,
    M(:,j)=i+j-1;
end
rtk=sum(rt1(M'));  % k period rate of return

moy=mean(rt1);
v=var(rt1);
m=k*(T-k+1)*(1-k/T);
VR=1/m*sum((rtk-k*moy).^2)/v; % Variance ratio statistic

Zk=sqrt(T)*(VR-1)*(2*(2*k-1)*(k-1)/(3*k))^(-.5); % homoscedastic statistic

j=1:k-1;
vec1=(2/k*(k-j)).^2;
rst=(rt1-moy).^2;
aux=zeros(1,k-1);
for i=1:k-1,
   aux(i)=rst(i+1:T)'*rst(1:T-i);
end
vec2=aux/((T-1)*v)^2;
Zhk=(VR-1)*(vec1*vec2')^(-.5); % heteroscedastic statistic
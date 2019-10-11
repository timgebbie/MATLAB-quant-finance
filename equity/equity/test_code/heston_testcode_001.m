%% Active Equity Models

%% Heston 

%% Phi_1 vs Phi_2 in numerical implementations of Heston model
% Why complex analysis is so important in finance
[x,y] = meshgrid(-1:.1:1, -1:.1:1);
z = imag(log(x+y*i));
surf(x,y,z);
shading interp;


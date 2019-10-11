%% Test script for posdef 
x = rand(5);
c = x' * x;
[v,d]=eig(c);
d(1,1)=-0.01;
c2 = v * d * v';
c3 = posdef(c2);

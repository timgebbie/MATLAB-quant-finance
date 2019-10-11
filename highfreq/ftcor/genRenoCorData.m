function p = genRenoCorData(N,rho)
 theta1 = 0.035;
 omega1 = 0.636;
 lambda1 = 0.296;
 theta2 = 0.054;
 omega2 = 0.476;
 lambda2 = 0.480;
 dt = 1/86400;
 sigsqr1(1) = 0.01;
 sigsqr2(1) = 0.01;
 for i = 1:N-1
     sigsqr1(i+1) = sigsqr1(i) + lambda1*(omega1 - sigsqr1(i))*dt + sigsqr1(i)*randn*sqrt(2*lambda1*theta1*dt);
     sigsqr2(i+1) = sigsqr2(i) + lambda2*(omega2 - sigsqr2(i))*dt + sigsqr2(i)*randn*sqrt(2*lambda2*theta2*dt);
 end
 p1(1) = 100;
 p2(1) = 100;
 for i = 1:N-1
     p1(i+1) = p1(i) + sqrt(sigsqr1(i))*randn*sqrt(dt);
     p2(i+1) = p2(i) + sqrt(sigsqr1(i))*(rho*randn + randn*sqrt(1-rho^2))*sqrt(dt);
 end
 T = [0:1/N:1];
 p = [T(1:N);p1;p2]';
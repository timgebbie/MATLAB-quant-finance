% SCRIPT FILE TESTING EWMAROBUSTFIT

% $Revision$ $Date$ $Author$

%CREATE FACTOR DATA
n = 30;
% factor bias
mu   = [0.01, 0]; 
% factor correlations
cr   = [[1,-0.3];[-0.3,1]]; 
% factor standard deviations
sd   = [0.15,0.05];
% factor covariance
cv   = corr2cov(sd,cr);
% factor time-series
factors = mvnrnd(mu,cv,n); 
%CREATE MODEL DATA
m = 3;
% bias
ai   = randn(m,1); 
% factor loadings
bi   = randn(m,2); 
% residual variance <- RESIDUAL VARIANCE
ci   = 0.05 * rand(m,1); 
%generate randomly distributed noise
e1   = randn(n,m); 
% simulated share time-series
shares  = ones(n,1) * ai' + factors * bi' + e1 .* (ones(n,1) * sqrt(ci)'); 
% repackaged the input and output data
X  = factors;
y  = shares(:,1);
X0 = X(1:end-1,:);
y0 = y(1:end-1);
X1 = X(end,:);
y1 = y(end);
% 1. to test adaptive robust fitting
[b0,Q0,stats0]      = ewmarobustfit(X0,y0,0.99);
[b1,Q1,stats1]      = ewmarobustfit(X,y,0.99);
% 2. to test recursive adaptive fitting
[b2,Q2,stats2]      = ewmarobustfit(X1,y1,b0,Q0);
[b21,Q21,stats21]   = ewmarobustfit(X1,y1,0.99,b0,Q0);
% 3. to test adaptive recursive robust fitting
[b3,Q3,stats3]      = ewmarobustfit(X1,y1,0.99,b0,Q0,stats0);
% display the coefficients
[b0,b1,b2,b3]
%%  Test code for GAUSSFILT
%
% Authors: Tim Gebbie, Raphael Nkomo

% $Revision: 1.1 $ $Date: 2008/09/30 15:44:26 $ $Author: Tim Gebbie $

%% Generate test data
p = cumsum(randn(50,5)* 0.10);

%% Generate filter co-efficients
for nk=1:4
    d = [];
    for period=2:2:40
        omega = 2 * pi / period;
        beta  = (1-cos(omega)) / (sqrt(2)^(2/nk) - 1);
        alpha = - beta+ sqrt(beta^2 + 2* beta);
        b = alpha^nk;
        a = 1;
        % n-th order co-efficient for the k-th delay
        for k=1:nk,
            a(k+1)=nchoosek(nk,k) * (1-alpha)^(k) * (-1)^k;
        end
        d = [d; [num2cell(period) num2cell(b) num2cell(a)]];
    end
    d
end

%% Help files
help gaussfilt

%% Run without plot
[f] = gaussfilt(p,4,3);

%% Run with plots
gaussfilt(p,4,3);
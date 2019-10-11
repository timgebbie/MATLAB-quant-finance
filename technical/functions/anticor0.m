function [portfolioReturns,weights,stockReturns] = anticor0(stockReturns,window)
%ANTICOR Select portfolios based on the ANTICOR algorithm
%   [PortfolioReturns,Weights] = ANTICOR(StockReturns,Window) calculates
%   the ANTICOR weighting strategy and resulting portfolio returns, for a
%   given set of stock returns and a specified window size. StockReturns is
%   an numObservations x numStocks matrix of simple stock returns (where
%   return[t] = price[t]/price[t-1]). The resulting PortfolioReturns is a
%   numObservations x 1 vector of portfolio returns and Weights is a
%   numObservations x numStocks weighting matrix.
%
%   Examples:
%   ret = tick2ret(stockprice([100,100,100,100],0.1,0.1,1/252,252*10))+1;
%   window = 15;
%   [portfolioReturns,weights] = anticor(ret,window);
%   
%   Reference:
%   Can We Learn to Beat the Best Stock
%   A. Borodin, R El-Yaniv and V Gogan
%   Journal of Artificaial Intelligence Research 21 (2004) 589-594

%   Author: Raphael Nkomo

% Preallocate
numObservations = size(stockReturns,1);
numStocks = size(stockReturns,2);
portfolioReturns = zeros(numObservations,1);
weights = zeros(numObservations,numStocks);

% Assume weights are initially uniformly distributed
weights(1,:) = 1/numStocks * ones(1,numStocks);
% Calculate initial portfolio return
portfolioReturns(1) = stockReturns(1,:) * weights(1,:)';
for t = 1:numObservations

    if t < 2*window
        weights(t+1,:) = weights(t,:);
    else
        % renormalize weights based on returns if fully-invested
        weights(t+1,:) = (weights(t,:) .* (1+stockReturns(t,:))) ./ nansum(weights(t,:) .* (1+stockReturns(t,:)));    
        LX1 = stockReturns(t-2*window+1:t-window,:);
        mu1 = mean(LX1);
        sigma1 = std(LX1);
        LX2 = stockReturns(t-window+1:t,:);
        mu2 = mean(LX2);
        sigma2 = std(LX2);
        LX1noMean = LX1 - repmat(mu1,window,1);
        LX2noMean = LX2 - repmat(mu2,window,1);
        Mcov = epsclean(1/(window-1) * LX1noMean' * LX2noMean);
        sigma1sigma2 = epsclean(sigma1'*sigma2);
        Mcor = Mcov./sigma1sigma2;
        % Deal with the case where an element in sigma1 or sigma2 is 0
        Mcor(isinf(abs(Mcor))) = 0;
        Mcor = epsclean(Mcor);
        % Calculate the claims
        claim = zeros(numStocks,numStocks);
        for i = 1:numStocks
            for j = 1:numStocks
                if i ~= j
                    if mu2(i) > mu2(j) && Mcor(i,j)>0
                        %max(-Mcor(i,i),0) is the same as abs(Mcor(i,i))
                        %when Mcor is negative otherwise 0
                        claim(i,j) = Mcor(i,j) + max(-Mcor(i,i),0) + max(-Mcor(j,j),0); 
                    end
                end
            end
        end
        % Calculate the transfers
        transfer = zeros(numStocks,numStocks);
        for i = 1:numStocks
            for j = 1:numStocks
                if i ~= j && claim(i,j) ~= 0
                        transfer(i,j) = weights(t+1,i) * claim(i,j)/sum(claim(i,:));
                end
            end
        end
        for i = 1:numStocks
            weights(t+1,i) = weights(t+1,i) + sum(transfer(:,i)) - sum(transfer(i,:));
        end
    end
end
for t=1:numObservations-1
    portfolioReturns(t+1) = stockReturns(t+1,:) * weights(t+1,:)';
end
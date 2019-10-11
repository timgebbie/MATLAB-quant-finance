function [s,i] = svdsector(p)
% SVDSECTOR Use SVD to construct sectors on stocks based on correlations
%
% [S,I] = SVDSECTORS(P,N) For price matrix P computes N mutually
% exclusive sectors for M stocks with at least 2 stocks in a given
% sector.
%
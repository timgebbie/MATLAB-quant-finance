function [p,s]=poissonpdf(c,s,m),
% POISSONPDF The Poisson probabillity distribution
%
% [P,S] = POISSONPDF(A,B,C,S),
%
% P(S) = a s^c exp ( -b (s+m)^2 )
%
%         Gamma((c+2)/2)^(c+1)  
% a = 2 * ---------------------
%         Gamma((c+1)/2)^(c+2)
%        
%      Gamma((c+2)/2)^2
% b =  ---------------- 
%      Gamma((c+1)/2)^2
%

% $ Author Diane Wilcox / Tim Gebbie

% find alpha
a = 2* ( ( gamma((c+2)./2) ).^(c+1)) ./ ((gamma((c+1)./2) ).^(c+2)) ; 
% find beta
b = gamma((c+2)./2).^2 ./ (gamma((c+1)./2) ).^2 ; 
% find the pdf
p = a.*s.^c.*exp(-b.*(s+m).^2));



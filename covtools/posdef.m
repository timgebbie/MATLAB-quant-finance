function [pd,eps0] = posdef(varargin)
% POSDEF returns positive semi-definite matrix 
%        
% [PD] = POSDEF(C) Here C is a symmetric matrix that is not necessarily
% positive semi-definite. The trace is not preserved.
%
% [PD] = POSDEF(C,EPS0) User defined acceptance threshold. Default value
% is 1e3.
%
% [PD] = POSDEF(C,EPSO,TRACE) TRACE is TRUE (FALSE) to preserve (ignore)
% standard deviations of the original covariance matrix. Default value is
% FALSE.
%
% Example 1:
%       x = rand(5);
%       c1 = x' * x;
%       [v,d]=eig(c1);
%       d(1,1)=-0.01;
%       c2 = v * d * v';
%       c3 = posdef(c2);
%
% c2 = 0.9106    1.2070    1.4312    0.7141    0.9676
%      1.2070    2.4331    2.4320    1.4474    2.0679
%      1.4312    2.4320    2.8159    1.5305    1.9953
%      0.7141    1.4474    1.5305    1.0384    1.2206
%      0.9676    2.0679    1.9953    1.2206    1.7702
%
% c3 = 0.9106    1.2069    1.4312    0.7141    0.9677
%      1.2069    2.4341    2.4319    1.4474    2.0669
%      1.4312    2.4319    2.8159    1.5305    1.9955
%      0.7141    1.4474    1.5305    1.0384    1.2206
%      0.9677    2.0669    1.9955    1.2206    1.7712
%
% Example 2:
%       [s4,c4] = cov2corr(c2);
%       c5 = posdef(c4);
%
% c4 = 1.0000    0.9272    0.9594    0.6246    0.8381
%      0.9272    1.0000    0.8227    0.5162    0.5980
%      0.9594    0.8227    1.0000    0.5014    0.8005
%      0.6246    0.5162    0.5014    1.0000    0.6436
%      0.8381    0.5980    0.8005    0.6436    1.0000
%
% c5 = 1.0073    0.9239    0.9567    0.6242    0.8364
%      0.9239    1.0015    0.8239    0.5164    0.5988
%      0.9567    0.8239    1.0010    0.5016    0.8011
%      0.6242    0.5164    0.5016    1.0000    0.6437
%      0.8364    0.5988    0.8011    0.6437    1.0004
%
% Example 3:
%      c6 = posdef(c4,[],true);
% 
% c6 = 1.0000    0.9199    0.9527    0.6219    0.8332
%      0.9199    1.0000    0.8229    0.5160    0.5982
%      0.9527    0.8229    1.0000    0.5013    0.8006
%      0.6219    0.5160    0.5013    1.0000    0.6436
%      0.8332    0.5982    0.8006    0.6436    1.0000
%
% See Also: EPSCLEAN

% $ Author Diane Wilcox

% Developer Notes: Chanel Malherbe alternative version under-development

switch nargin
    case 1
        c = varargin{1};
        eps0 = 1e3;
        flag = false;
    case 2
        c = varargin{1};
        eps0 = varargin{2};
        flag = false;
    case 3
        c = varargin{1};
        eps0 = varargin{2};
        if isempty(eps0), eps0 = 1e3; end;
        flag = varargin{3};
    otherwise
        error('Incorrect Input Arguments');
end;

if flag, [s,c] = cov2corr(c); end;
%% POSITIVE SEMI
[m,n]=size(c);
% comment ?
p=c'*c;
% comment ?
q=eye(m);
% comment ?
[up,sp]= schur(p);
% comment ?
qq=sqrt(sp)*up'*q*up*sqrt(sp);
% comment ? 
qq = epsclean(qq,1e3);
% comment ?
[uq,sq]= schur(qq);
% comment ?
x = up*inv(sqrt(sp))*uq*sqrt(sq)*uq'*inv(sqrt(sp))*up';
% output covariance matrix
pd=inv(x);
    
%% preserve the trace
if flag, 
    [s2,r]=cov2corr(pd); 
    pd = corr2cov(s,r);
end;

%% if not positive semi-definite change EPS0
try
    chol(pd);
catch
    warning(sprintf('First iteration failed at EPS0 = %2.3f',eps0));
    x = posdef(c,eps0 * 10);
end;


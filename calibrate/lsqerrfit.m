function [p1,p2,e,s_tc,s_beta,s_w]=lsqerrfit(lp,pr,ns)
% LSQERRFIT Least-square error fitting of log-periodic precursor
%
% See Also

% Author : Uli Kirchner

% 1.1 2008/07/01 14:45:33 Tim Gebbie

% 

% Loop through parameter space

e       = zeros(ns);
s_tc    = [pr(1,1):(pr(1,2)-pr(1,1))/(ns(1)-1):pr(1,2)];
s_beta  = [pr(2,1):(pr(2,2)-pr(2,1))/(ns(2)-1):pr(2,2)];
s_w     = [pr(3,1):(pr(3,2)-pr(3,1))/(ns(3)-1):pr(3,2)];;

%time values
t=[-numel(lp):-1]';

le=inf;

b_tc=0;
b_beta=0;
b_w=0;
b_A=0;
b_B=0;
b_C=0;
b_D=0;
tic
for c_tc=0:ns(1)-1
    tc=s_tc(c_tc+1);
    %pr(1,1)+c_tc*(pr(1,2)-pr(1,1))/(ns(1)-1);

    %for beta=pr(2,1):.1:pr(2,2)
    for c_beta=0:ns(2)-1
        beta=s_beta(c_beta+1);
        %beta=pr(2,1)+c_beta*(pr(2,2)-pr(2,1))/(ns(2)-1);

        tf=(tc-t).^beta;
        lt=log(tc-t);
        
        %for w=pr(3,1):1:pr(3,2)
        for c_w=0:ns(3)-1
            w=s_w(c_w+1);

            %w=pr(3,1)+c_w*(pr(3,2)-pr(3,1))/(ns(3)-1);
            

                %find the least square solutions for A,B,C

                af1=cos(w*lt);
                af2=sin(w*lt);
                %RC=regress(lp,[ones(numel(lp),1) tf tf.*af1 tf.*af2]);
                RC=[ones(numel(lp),1) tf tf.*af1 tf.*af2]\lp;

                A=RC(1);
                B=RC(2);
                C=RC(3);
                D=RC(4);


                ie=A+B*tf+C.*tf.*af1+D.*tf.*af2-lp;
                ce=ie'*ie;
                if ce<le
                    b_tc=tc;
                    b_beta=beta;
                    b_w=w;
                    b_A=A;
                    b_B=B;
                    b_C=C;
                    b_D=D;
                    
                    le=ce;
                end
                e(c_tc+1,c_beta+1,c_w+1)=ce;
        end
    end
    toc
    disp(tc);
end

p1=[b_tc,b_beta,b_w];
p2=[b_A,b_B,b_C,b_D];
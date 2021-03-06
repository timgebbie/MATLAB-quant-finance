%% Script to run two gamconfig 
clear all;
clc;
spinmodel_gamgconfig_LSE;
clear all;
clc;
spinmodel_gamgconfig_JSE;
clear all;
clc;

%% load the data
load workspace_gamgconfig_JSE_D;
load workspace_gamgconfig_LSE_D;
save workspace_gamgconfig_LSEJSE;

%% compute ns and s over entire test set
j = 1;
t0 = 60;
tend = size(cx_lse,1); % 
for ti = t0:tend,
    nmax =max(cx_lse(ti,:));
    for i=1:nmax,
       ss(j)=sum(cx_lse(ti,:)==i);
       j = j + 1;
    end
end
smax = max(ss);
nn_lse = [];
ss_lse = [];
for i=1:smax,
    if sum(ss==i)>0
        nn_lse = [nn_lse; sum(ss==i)];
        ss_lse = [ss_lse; i];
    end
end

%% compute ns and s over entire test set
j = 1;
t0 = 60;
clear ss;
tend = size(cx_jse,1); % 
for ti = t0:tend,
    nmax =max(cx_jse(ti,:));
    for i=1:nmax,
       ss(j)=sum(cx_jse(ti,:)==i);
       j = j + 1;
    end
end
nn_jse = [];
ss_jse = [];
for i=1:smax,
    if sum(ss==i)>0
        nn_jse = [nn_jse; sum(ss==i)];
        ss_jse = [ss_jse; i];
    end
end

%% plot
figure;
h(1)=plot(ss_lse,nn_lse);
set(gca,'YScale','log','XScale','log');
set(h(1),'Marker','o');
title('Log-Log Plot LSE');
xlabel('log s');
ylabel('log N(s)');

%% plot
hold on;
h(2)=plot(ss_jse,nn_jse);
set(gca,'YScale','log','XScale','log');
set(h(2),'Marker','+','Color','r');
title('Log-Log Number vs. Size Plot JSE');
xlabel('log s');
ylabel('log N(s)');
legend([h(1),h(2)],'LSE: 31 Jan 2008 - 31 Jan 2009','JSE: 31 Jan 2008 - 31 Jan 2009');

%% fit line
bstats=regstats(log(nn_jse(2:end-1)),log(ss_jse(2:end-1)),'linear');
b = bstats.tstat.beta;
yhat = b(1) + b(2) * log(ss_jse(1:end));
h(3)=line(ss_jse(1:end),exp(yhat),'Color','r','LineWidth',1);
text(10,1000,['\fontsize{10} HIST : \alpha^{{JSE}}_{\infty} = ' sprintf('%2.2f',-b(2)) ' \pm ' sprintf('%2.2f',bstats.tstat.se(2))],'Color','r');
% finite size effects
bstats=regstats(log(nn_jse(2:end-1)),[log(ss_jse(2:end-1)),ss_jse(2:end-1)],'linear');
b = bstats.tstat.beta;
yhat = b(1) + b(2) * log(ss_jse(1:end)) + b(3) * ss_jse(1:end);
h(4)=line(ss_jse(1:end),exp(yhat),'Color','r','LineWidth',1,'Linestyle',':');
text(10,400,['HIST : \alpha^{{JSE}}_f = ' sprintf('%2.2f',-b(2)) ' \pm ' sprintf('%2.2f',bstats.tstat.se(2))],'Color','r');
text(10,200,['         \lambda^{{JSE}}_f = ' sprintf('%2.2f',-b(3)) ' \pm ' sprintf('%2.2f',bstats.tstat.se(3))],'Color','r');
% finite size effects
% bstats=regstats(log(nn_lse(2:end-1)),[log(ss_lse(2:end-1)),ss_lse(2:end-1)],'linear');
% b = bstats.tstat.beta;
% yhat = b(1) + b(2) * log(ss_lse(1:end)) + b(3) * ss_lse(1:end);
% h(5)=line(ss_jse(1:end),exp(yhat),'Color','b','LineWidth',1,'Linestyle',':');
% text(10,200,['\alpha^{{LSE}}_f = ' sprintf('%2.2f',b(2)) ' \pm ' sprintf('%2.2f',bstats.tstat.se(2))],'Color','b');
% text(10,100,['\lambda^{{LSE}}_f = ' sprintf('%2.2f',b(3)) ' \pm ' sprintf('%2.2f',bstats.tstat.se(3))],'Color','b');
% b=regress(log(nn_lse(3:end-1)),[ones(size(ss_lse(3:end-1),1),1) log(ss_lse(3:end-1))]);
% yhat = b(1) + b(2) * log(ss_lse(2:end));
% h(3)=line(ss_lse(2:end),exp(yhat),'Color','k','LineWidth',1.5);
% text(10,800,sprintf('a = %2.2f',b(2)),'Color','k');

%% Clauset-Shalizi-Newman JSE
%
%$$p(x) = {\alpha - 1) \over(x_{min}} \left( {x \over x_{min}} \right)^{\alpha} $$
% 
% Estimator:
%
% $$\hat alpha = 1 + N \left[ {\sum_{i=1}^N \ln{x_i \over x_{min}}} \right] ~\pm (\alpha -1 ) \over \sqrt{N}$$ 
%
nXi=ns_jse(:);
nXi(nXi==0)=[];
Nx = size(nXi,1);
xmin = 3;
hatalpha = 1 + (Nx / (sum(log(nXi/xmin))));
hatsigma = (hatalpha-1)/sqrt(Nx);
[alpha1, xmin1,L1]=plfit(nXi);
var1 = plvar(nXi);
std1 = round(100*sqrt(var1))/100;
text(10,70,['\alpha^{{JSE}}_{CSN} = ' sprintf('%2.2f',alpha1) ' \pm ' sprintf('%2.2f',std1) ' s_{min} = ' sprintf('%d',xmin1)],'Color','r');


%% Clauset-Shalizi-Newman LSE
%
%$$p(x) = {\alpha - 1) \over(x_{min}} \left( {x \over x_{min}} \right)^{\alpha} $$
% 
% Estimator:
%
% $$\hat alpha = 1 + N \left[ {\sum_{i=1}^N \ln{x_i \over x_{min}}} \right] ~\pm (\alpha -1 ) \over \sqrt{N}$$ 
%
nXi=ns_lse(:);
nXi(nXi==0)=[];
Nx = size(nXi,1);
xmin = 3;
hatalpha = 1 + (Nx / (sum(log(nXi/xmin))));
hatsigma = (hatalpha-1)/sqrt(Nx);
[alpha2, xmin2,L2]=plfit(nXi);
var2 = plvar(nXi);
std2 = round(100*sqrt(var2))/100;
text(10,30,['\alpha^{{LSE}}_{CSN} = ' sprintf('%2.2f',alpha2)  ' \pm ' sprintf('%2.2f',std2) ' s_{min} = ' sprintf('%d',xmin2)],'Color','b');
 
%% compute ns and s over each 30 day windows
ttt = 0;
t0 = 60;
tend = size(cx_lse,1); %
clear sst;
for tt = t0:30:tend-29
    ttt = ttt + 1;
    j = 1;
    for ti = tt:tt+29,
        nmax =max(cx_lse(ti,:));
        for i=1:nmax,
            sst(ttt,j)=sum(cx_lse(ti,:)==i);
            j = j + 1;
        end
    end
end
tt = 0;
nnt_lse = [];
sst_lse = [];
for ttt=1:size(sst,1),
    smax = max(sst(ttt,:));
    for i=1:smax,
        nnt_lse(ttt,i) = sum(sst(ttt,:)==i);
        sst_lse(ttt,i) = i;
    end
end

%% plot
figure;
i =1;
color = {'b','g','r','c','m','k','y'};
zi = (nnt_lse(i,:)>0);
h=plot(sst_lse(i,zi),nnt_lse(i,zi),color{1});
set(gca,'YScale','log','XScale','log');
set(h,'Color',color{1});
set(h,'Marker','o');
title('Log-Log Number vs. Size Plot LSE');
ylabel('log N_s');
xlabel('log s');
for i=2:size(sst,1)
     zi = (nnt_lse(i,:)>0);
     h=line(sst_lse(i,zi),nnt_lse(i,zi),'Marker','o','Color',color{i});
end
legend(h(2:end),'#1 Jul-Aug','#2 Aug-Sep','#3 Sep-Oct','#4 Oct-Nov','#5 Nov-Dec','#6 Dec-Jan');

%% compute ns and s over each 30 day windows
gs_jse(gs_jse==Inf)=0;
ttt = 0;
t0 = 60;
tend = size(cx_jse,1); %
clear sst;
for tt = t0:30:tend-29
    ttt = ttt + 1;
    j = 1;
    for ti = tt:tt+29,
        nmax =max(cx_jse(ti,:));
        for i=1:nmax,
            indexs = (cx_jse(ti,:)==i);
            sst(ttt,j)=sum(indexs);
            % gst(ttt,j)=sum(gs_jse(ti,indexs));
            j = j + 1;
        end
    end
end
tt = 0;
nnt_jse = [];
sst_jse = [];
for ttt=1:size(sst,1),
    smax = max(sst(ttt,:));
    for i=1:smax,
        indexs = (sst(ttt,:)==i);
        nnt_jse(ttt,i) = sum(indexs);
        sst_jse(ttt,i) = i;
    end
end

%% plot
figure;
i = 1;
color = {'b','g','r','c','m','k','y'};
zi = (nnt_jse(i,:)>0);
h(1)=plot(sst_jse(i,zi),nnt_jse(i,zi),color{1},'Linestyle','none');
set(gca,'YScale','log','XScale','log','Xlim',[1,20]);
xi = 0.5:0.2:10;
[p]=polyfit(log(sst_jse(i,zi)),log(nnt_jse(i,zi)),3);
yi=polyval(p,log(xi));
h2 =line(xi,exp(yi),'Color',color{1});
set(h(1),'Color',color{1});
set(h(1),'Marker','o');
title('Log-Log Plot JSE');
ylabel('log N(s)');
xlabel('log s');
for i=2:size(sst,1)
     zi = (nnt_jse(i,:)>1);
     h(i)=line(sst_jse(i,zi),nnt_jse(i,zi),'Color',color{i},'Marker','o','Linestyle','none');
     [p]=polyfit(log(sst_jse(i,zi)),log(nnt_jse(i,zi)),3);
     yi=polyval(p,log(xi));
     h2 =line(xi,exp(yi),'Marker','none','Color',color{i});
end
legend(h(1:end),'#1 Jul-Aug','#2 Aug-Sep','#3 Sep-Oct','#4 Oct-Nov','#5 Nov-Dec','#6 Dec-Jan');

%% plot the surface
surf(nnt_jse,sst_jse);
shading interp;
set(gca,'XScale','log','ZScale','log');

%% plot the coupling parameters
%
% GS(T,N) for T days and N number of stocks.
% 
gs_jse(gs_jse==Inf)=0;
mgs=[];
stj=[];
mgu=[];
mgl=[];
for j=1:max(max((ns_jse)))
    % find all clusters with the same size
    sizeindx = (ns_jse==j);
    % find all the gs values for a cluster of size ns
    gsj = gs_jse(sizeindx);
    % remove zeros
    gsj = gsj(~gsj==0);
    if ~isempty(gsj)
        % historgram
        % [gsjh(j,:),xi(j,:)] = hist(gsj,40);
        % mean
        mgs = [mgs; median(gsj)];
        mgu = [mgu; max(gsj)];
        mgl = [mgl; min(gsj)];
        stj = [stj; j];
    end
end % loop over cluster size
subplot(2,1,1);
errorbar(stj,mgs,(mgs-mgl),mgu-mgs,'Marker','o');
set(gca,'Ylim',[0,1],'Xlim',[1,20]);
ylabel('g_s');
xlabel('n_s');
title('JSE clusters (no market mode)');

%% plot the coupling parameters
%
% GS(T,N) for T days and N number of stocks.
% 
gs_lse(gs_lse==Inf)=0;
mgs=[];
stj=[];
mgu=[];
mgl=[];
for j=1:max(max((ns_lse)))
    % find all clusters with the same size
    sizeindx = (ns_lse==j);
    % find all the gs values for a cluster of size ns
    gsj = gs_lse(sizeindx);
    % remove zeros
    gsj = gsj(~gsj==0);
    if ~isempty(gsj)
        % historgram
        % [gsjh(j,:),xi(j,:)] = hist(gsj,40);
        % mean
        mgs = [mgs; median(gsj)];
        mgu = [mgu; max(gsj)];
        mgl = [mgl; min(gsj)];
        stj = [stj; j];
    end
end % loop over cluster sizes
subplot(2,1,2);
errorbar(stj,mgs,(mgs-mgl),mgu-mgs,'Marker','o');
set(gca,'Ylim',[0,1],'Xlim',[1,20]);
ylabel('g_s');
xlabel('n_s');
title('LSE clusters (no market mode)');

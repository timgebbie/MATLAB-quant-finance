%% Initialise
clear all; clc;

%% Required Datastream data
% Username: DS:XQTM001
% Password: SWIFT94 1
dsc = datastream('DS:XQTM001','VISOR527','Datastream','http://dataworks.thomson.com/Dataworks/Enterprise/1.0');

%% Get all the tickers in the index @ date
%
% Level 1: ICBIC
% Level 2: ICBSSC
% Level 3: ICBSC 
% Level 4: ICBSUC <--
%    
data = fetch(dsc, sprintf('LJSEOVER~LIST~=MNEM,MV,ICBSUC,ICBIC~AA~@%s',datestr(today,29)));
mv = str2double(data.MV);
tickers = data.MNEM;
icb = str2double(data.ICBSUC);
icb1 = str2double(data.ICBIC);
% start date
end_date = datestr(today,29);
% end date
start_date = datestr(today-3000,29);
% frequency
freq = 'D';
% set up datatypes and tickers
items   = {'P'};
% compute the value traded

%% Liquidity screen
% minmv0 = exp(median(log(mv0))-0.6*mad(log(mv0)));
% for si=1:3
%     sec{si} = sec{si}(mv{si}>minmv0);
% end
[smv, si]= sort(mv,'descend');
sizeidx = si(1:20);
tickers0 = tickers(sizeidx);
icb0 = icb(sizeidx);
icb10 = icb1(sizeidx);
jquantity = [];
equantity = [];

%% Load the data
[jsefts,err]=ds2ftsfetch(dsc,tickers0,items,start_date,end_date,freq);
jsefts = fillts(jsefts{1},'z');
x = fts2mat(jsefts);
[m0,d0]=size(x);
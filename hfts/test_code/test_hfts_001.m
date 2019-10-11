%% High-Frequency Time-Series (HFTS) objects
% Authors: T. Gebbie
% Version: <PROJECT>-<NAME>-<DATE>-<MAJOR>-<MINOR> e.g. -AMF2014-001-001
%
% # Problem Specification:  ...
% # Data Specification: ...
% # Configuration Control: 

% # Version Control: ... (SVN)
% # References: ...
% # Current Situation: ...
% # Future Situation: ...
%
% Uses:

%% 1. Clear workspace
close all;
clear all;
clc;

%% 2. Load data
% paths
% C:\Users\user\Documents\MATLAB\hfts\data\JSEImpactCurvesProjectData\JSE\AGLJ_J
group = 'hfts';
project = '\data\JSE-TestData\JSE\AGLJ_J';
filename = 'AGLJ_J-Transactions-01Nov2013_0830-to-07Nov2013_1730';
% full path the data file
filename = fullfile(fileparts(userpath),'MATLAB',group,project,[filename '.mat']);
% load the data file
load(filename);
% get the size of the data 
whos('data');

%% Class constructor and methods for Tick Data
tsH = hfts(data),
tsH = aggregate(tsH);
tsH.AGL(1:4,:),
size(tsH.AGL),
size(tsH.BIL),
tsH.series,
tsH0 = hfts(dataH,{'Price','Volume'}),
tsH0 = aggregate(tsH);
tsH1 = mergets(tsH),
tsH1.Price(1:2,:),
tsH2 = resample(tsH,1/3600),
tsH3 = tsH,
tsH3.freq = 's',

%% convert to FINTS objects
f1 = fints(tsH);
f2 = fints(tsH1);

%% Merge HFTS objects 
tsAM = merge(tsH,tsM);

%% Test TRTH DATA
try
tsI = hfts(dataI,{'Price','Volume'}),
catch
end

%% Class constructor and methods for Bar-Data (already aggregated)
tsE = hfts(dataE),

%% Plot function
plot(tsH,'25-Jan-2012',1.5);
plot(tsH,'25-Jan-2012',10);

%% fill in missing data
% linear interpolation
tsHf=fillts(tsH);
% zero-order hold
tsHfz=fillts(tsH,'z');

%% remove overlapping missing data
stH1r=nanfreets(tsH1);
display(stH1r);

%% compute returns
% covert to tick-to-tick returns
stH1ret = tick2ret(tsH1);
% convert to inhomogenously sampled per-minutes returns
stH1rets = tick2ret(tsH1,'geometric','ticktime');
display(stH1rets);

%% plot the price fluctuations
plot(stH1rets,'25-Jan-2012',10);

%% Documentation
help hfts
help hfts/aggregate
help hfts/extend
help hfts/fints
help hfts/mergets
help hfts/plot
help hfts/subsasgn
help hfts/tick2ret
help hfts/display
help hfts/fillts
help hfts/hfts
help hfts/nanfreets
help hfts/resample
help hfts/subsref
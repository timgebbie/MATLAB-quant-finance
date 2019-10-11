% script file to set automation server (to ensure that EXCEL talks to the
% correct open version of matlab)

% to disable -> Start up the 32 bit MATLAB
% -> Run the following command:
% >> !matlab /unregserver

status = enableservice('AutomationServer');
status = enableservice('AutomationServer',true)
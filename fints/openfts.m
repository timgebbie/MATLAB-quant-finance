function Y = openfts(varargin)
% FINTS/OPENFTS Open FINTS object in workspace variable editor.
%
%    OPENFTS(X) Open FINTS object X in workspace variable editor.
%
% See Also: OPENVAR

% Author: Tim Gebbie 

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:57 $ $Author: Tim Gebbie $

switch class(varargin{1})
    case 'fints'
        % Evaluate FINTS
        % open the DATA
        assignin('base',varargin{1}.desc,fts2mat(varargin{1}));
        openvar(char(varargin{1}.desc));
        % open the FIELDNAMES
        assignin('base','FIELDNAMES',fieldnames(varargin{1},1));
        openvar('FIELDNAMES');
        return;

    case 'cell'
        % Evaluate structure -- to be migrated to FTSDATA
        for i=1:size(varargin{1},2),
            switch class(varargin{1}{i})
                case 'fints'
                    % open the DATA
                    assignin('base',char(varargin{1}{i}.desc),fts2mat(varargin{1}{i}));
                    openvar(char(varargin{1}{i}.desc));
                    if i==size(varargin{1},2),
                        % open the FIELDNAMES
                        assignin('base','FIELDNAMES',transpose(fieldnames(varargin{1}{i},1)));
                        openvar('FIELDNAMES');
                    end
                otherwise
                    % skip and do nothing
            end
        end

end
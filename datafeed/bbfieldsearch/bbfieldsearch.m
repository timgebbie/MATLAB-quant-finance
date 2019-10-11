function bbfieldsearch
% BBFIELDSEARCH - A graphical search utility for Bloomberg Datafeed Fields. 
%
% It can be used to search bbfieldnames or bboverrides in
% \@bloomberg\bbfields.mat and return matching field names, types,
% categories, IDs and description.
%

% Created: Nov 12, 2008 by Ameya Deoras

% Set up variables
handles = struct;
sharedvars = struct; %#ok<NASGU>
data = struct;

bbfieldsearchLoadGUI();
bbfieldsearchInitialize();

set(handles.figh,'Visible','on');
% And we're done!

% ------------ Initialization Functions ----------------
    function bbfieldsearchLoadGUI()
        % Load figure
        figname = 'bbfieldsearch.fig';
        try
            handles.figh = hgload(figname,struct('Visible','off'));
        catch %#ok<CTCH>
            error('Error loading %s', figname);
        end
        % Dynamically set figure location to users default
        defpos = get(0,'DefaultFigurePosition');
        set(handles.figh,'Units','Pixels');
        curpos = get(handles.figh,'Position');
        set(handles.figh, 'Position',[defpos(1:2) curpos(3:4)]);
        
        % Populate handles structure
        findtags = get(findobj(handles.figh,'-regexp','tag','.+'),'tag');
        for i = 1:length(findtags)
            handles.(findtags{i}) = findobj(handles.figh,'tag',findtags{i});
        end
        % Set figure properties and callbacks:
        bbfieldsearchSetCallbacks();
    end

    function bbfieldsearchSetCallbacks()
        set(handles.fieldsbox,'Callback',@(varargin)modsearchresult);
        set(handles.searchbutton,'Callback',@(varargin)dosearch);
        set(handles.queredit,'Callback',@(varargin)dosearch_shortcut);
    end

    function bbfieldsearchInitialize()
        % Set up the figure before making it visible
        % Initialize shared variables
        fprintf('Loading bbfields.mat...');
        data.bb = load('bbfields.mat');
        fprintf('Done\n');
    end

    function dosearch_shortcut()
        % Runs the search if you type in the editbox and hit return
        if get(handles.figh,'CurrentCharacter') == char(13)
            dosearch;
        end
    end

    function dosearch()
        query = get(handles.queredit,'String');
        if ~get(handles.exactbox,'Value')
            query = regexp(query,'[^\s]*','match');
        else
            query = {query};
        end
        % Search either fieldnames or overrides
        if get(handles.ovbox,'Value')
            source = data.bb.bboverrides;
        else
            source = data.bb.bbfieldnames;
        end

        matches = true(1,length(source)); % Initialize matches
        % Each term is searched for separately and the results are ANDed
        for i = 1:length(query) 
            temp = regexpi(source,query{i},'once');
            matches = matches & ~cellfun(@isempty,temp).';
        end
        
        if get(handles.ovbox,'Value') % Convert override matches to fieldname matches
            temp = cellfun(@(k)strcmp(k,data.bb.bbfieldnames),data.bb.bboverrides(matches),'UniformOutput',false);
            data.matches = cellfun(@find,temp).';
        else
            data.matches = find(matches);
        end

        % Display results
        set(handles.fieldsbox,'String',data.bb.bbfieldnames(data.matches),'Value',1);       
        modsearchresult
    end

    function modsearchresult
        % Display information about selected field
        if ~isfield(data,'matches')
            return
        end
        
        if isempty(data.matches)
            set(handles.desctbl,'Data',{'',[],[],[]}.');
            set(handles.desctext,'String','');
            return
        end
            
        chosenresult = get(handles.fieldsbox,'Value');
        chosenid = data.matches(chosenresult);
        
        % Set the table values
        newtblval = {data.bb.bbcategories{chosenid};...
            data.bb.bbdatamask(chosenid);...
            data.bb.bbfieldids(chosenid);...
            data.bb.bbfieldtypes(chosenid)};
        set(handles.desctbl,'Data',newtblval);
        
        % Search for help on this field
        chosenfield = data.bb.bbfieldnames{chosenid};
        helpid = find(strcmp(chosenfield, data.bb.bbhelpfields(:,1)));
        if isempty(helpid)
            set(handles.desctext, 'String', 'No help for field');
        else
            set(handles.desctext, 'String', data.bb.bbhelpfields{helpid,2});
        end
        
    end   
        
end
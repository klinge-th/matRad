function cst = createCst(structures, useDefaultBool)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call cst = createCst(structures, useDefaultBool) to create a cell "cst"
% containing the following parameters:
%   1: organ number
%   2: organ name
%   3: organ class
%   4: maximum dose [Gy]
%   5: minimum dose [Gy]
%   6: maximum penalty
%   7: minimum penalty
%   8: VOILIST for countour (indices)
% 
% if useDefaultBool is zero or not set, the user will be asked if default
% parameters should be used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% checking input
if nargin < 2
    useDefaultBool = 0;
end

%% initializing cst-cell
cst{numel(structures(1,:)), 8} = [];

%% filling organ number, name and VOILIST (indices)

% loop over all contoured structures
for i = 1:numel(structures(1,:))
    cst{i,1} = i - 1; % first organ has number 0    
    cst{i,2} = structures(i).structName;
    cst{i,8} = structures(i).indices;
end

%% filling organ class, max/min dose and max/min penalty

% check whether default values or user input should be used
if ~useDefaultBool
    useUserinput = input(['Do you wish to set organ-parameters by hand?'...
                            '\n1: Yes\n0: No (use default values)\n']);
    if ~useUserinput
        useDefaultBool = 1;
    end
end

% start filling the cst cell
if useDefaultBool
    targetIsSet = 0;
    % 1. set all organs as OAR 
    for i = 1:numel(structures(1,:))
        cst{i,3} = 'OAR';  
        cst{i,4} = 30;  
        cst{i,5} = 0;
        cst{i,6} = 80;
        cst{i,7} = 0;
    end
    
    % 2. look for potential Targets
    cellString = cst(:,2);
    idx1 = regexpi(cellString,'tv');
    idx2 = regexpi(cellString,'target');
    
    % change parameters if target was found
    for i = 1:numel(structures(1,:))
        if ~isempty(idx1{i}) || ~isempty(idx2{i})
            cst{i,3} = 'TARGET';
            cst{i,4} = 60;  
            cst{i,5} = 60;
            cst{i,6} = 200;
            cst{i,7} = 200;
            
            targetIsSet = 1;
        end        
    end
    
    % if no target was found, set last volume as 'TARGET'
    if ~targetIsSet
        cst{end,3} = 'TARGET';
        cst{end,4} = 60;  
        cst{end,5} = 60;
        cst{end,6} = 200;
        cst{end,7} = 200;
        
        fprintf(['No target volume identified.\n'...
            'Last volume was set as ''TARGET'' by default.'])
    end
    
else
    % 1. use user input to fill parameters
    fprintf('Please fill in the parameters by hand...\n')
    for i = 1:numel(structures(1,:))
        organName = cst{i,2};
        cst{i,3} = input([organName '''s class (''OAR'',''TARGET'' '...
                            'or ''IGNORED''):']);  
        cst{i,4} = input([organName '''s max dose [Gy]:']);  
        cst{i,5} = input([organName '''s min dose [Gy]:']);
        cst{i,6} = input([organName '''s penalty for max dose:']);
        cst{i,7} = input([organName '''s penalty for min dose:']);
        fprintf('\n')
    end
    
    % 2. check if a target volume is set
    idx = strfind(cst(:,3),'TARGET');
    if isempty([idx{:}])
        fprintf(['WARNING: No target volumes was defined!\nPlease adjust'...
            'cst cell before executing treatment planning.']);
    end
end


end
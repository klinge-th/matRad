function fileList = createFileList(patDirectory)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call fileList = createFileList(patDirectory) to create a list of all
% files contained in the patient directory and subdirectories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get information about main directory
mainDirInfo = dir(patDirectory);   
% get index of subfolders
dirIndex = [mainDirInfo.isdir]; 
% list of filenames in main directory
fileList = {mainDirInfo(~dirIndex).name}';

%% create full path for all files in main directory
if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(patDirectory,x),...
                fileList, 'UniformOutput', false);
end

%% search subdirectories
subDirList = {mainDirInfo(dirIndex).name}'; % list of subdirectories
validIndex = ~ismember(subDirList,{'.','..'}); % exclude '.' and '..'

% loop over all subdirectories
isDirectory = find(validIndex);
if ~isempty(isDirectory)
    for i = isDirectory(1):isDirectory(end)
        % create subdirectory path
        nextDir = fullfile(patDirectory, subDirList{i}); 
        % call createFileList recursively
        fileList = [fileList; createFileList(nextDir)];
    end
end

end
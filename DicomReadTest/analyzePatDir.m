function [ctList, structList, structPath, otherFiles] = analyzePatDir(patDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call [ctList, structList, structPath, otherFiles] = analyzePatDir(patDir)
% to analyze the chosen directory ('patDir') and it's subdirectory for 
% DICOM files. The output contains a list of all identified CT and
% structure files and the path to a single RTSTRUCT file that shall be
% used for the patient import.
% Unidentified (or files we are not interested in) DICOM files are
% stored in 'otherFiles'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1st get all files within the patient directory
fprintf('\nSearching all files in patient directory...')
fileList = createFileList(patDir);
fprintf('finished!\n')

%% 2nd check for dicom files and differentiate types (CT, RTSTRUCT, etc...)
% checking for Dicom file type
fprintf('\nDetecting valid dicom files...')
numOfFiles = numel(fileList(:,1));
for i = numOfFiles:-1:1
    try
        tempInfo = dicominfo(fileList{i}); % try to get DicomInfo
        fileList{i,2} = tempInfo.Modality;
    catch % if dicominfo fails -> file not in DICOM format -> remove entry
        fileList(i,:) = [];
    end
    matRad_progress(numOfFiles-i+1, numOfFiles);
end

% sort file paths according to file type
ctList = fileList(strcmp(fileList(:,2),'CT'),1);
structList = fileList(strcmp(fileList(:,2),'RTSTRUCT'),1);
otherFiles = fileList(strcmp(fileList(:,2),'RTSTRUCT')...
                + strcmp(fileList(:,2),'CT') == 0,:);
            
%% 3rd checking that the ct list isn't empty
if isempty(ctList)
    error('No CT slices found in patient directory')
end
            
%% 4th choose RTSTRUCT file
if numel(structList) == 1
    structPath = structList{1};
elseif numel(structList) ~= 1
    if numel(structList) == 0
        fprintf(['\nno RTSTRUCT file was found!\nUnable to continue '...
                'without structure file...\n'])
        useManualPath = input(['Please enter a path to valid RTSTRUCT'...
                                'file:\n0: No\n1: Yes\n']);
        if useManualPath
            structPath = input('Path to RTSTRUCT file:\n');
        else
            error('No RTSTRUCT file selected. Exiting...');
        end
    elseif numel(structList) > 1
        fprintf('\nMore than one RTSTRUCT file was found:\n')
        for i = 1:numel(structList)
            fprintf('%d: %s\n',i,structList{i})
        end
        structIdx = input('Choose the desired file by it''s number:\n');
        structPath = structList{structIdx};
    end
end
end
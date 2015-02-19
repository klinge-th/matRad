%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Skript to create a ct-cube of a specified resolution and a cst-cell
% (containing info about the contoured organs) from DICOM ct-slices and 
% a RTSTRUCT file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameters
% specify paths to the ct-image folder and the RTSTRUCT file
ctPath = 'D:\matRad projects\GitHub\matRad\TestPatient\Quasimodo';
structPath = ['D:\matRad projects\GitHub\matRad\TestPatient\' ...
            'RS1.3.6.1.4.1.2452.6.120060512.20736.311.101211283.dcm'];

targetCtRes = [6 6 6]; % define the desired ct-resolution (will be
                     % interpolated from the original ct-cube)
% output folder:
outputFolder = 'D:\matRad projects\GitHub\matRad\DICOMimported\';
% patient description used for the final *.mat file
patientName = 'TestPatient1';
        
%% import ct-cube
fprintf(['+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ...
    '\nimporting ct-cube...\n']);
[origCt, origCtResolution, origCtInfo] = readCtSlices(ctPath, 0); % 0 = no visualization

%% calculating water equivalent thickness from HU
fprintf('\nconversion of ct-Cube to waterEqT...\n');
origCt = calcWaterEqT(origCt, origCtInfo);

%% interpolating new ct-cube
fprintf('\ninterpolating ct-cube to desired resolution...\n');
ct = interp3dCube(origCt, origCtResolution, targetCtRes);

% creating necessary info for the handling of the structures
ctInfo.PixelSpacing = [targetCtRes(1);targetCtRes(2)];
ctInfo.SliceThickness = targetCtRes(3);
ctInfo.ImagePositionPatient = origCtInfo.ImagePositionPatient;
ctInfo.ImageOrientationPatient = origCtInfo.ImageOrientationPatient;
ctInfo.Width = numel(ct(:,1,1));
ctInfo.Height = numel(ct(1,:,1));
ctInfo.ImagesInAcquisition = numel(ct(1,1,:));

%% import structure data
fprintf('\nreading structures...\n');
structures = readStruct(structPath, 0); % 0 = no visualization

%% creating structure cube
for i = 1:numel(structures)
    fprintf('\ncreating cube for %s volume...\n', structures(i).structName);
    structures(i).cube = createStructCube(structures(i).points, ctInfo);
    structures(i).indices = getIndizesFromCube(structures(i).cube);
end

%% creating cst
fprintf('\ncreating cst...\n');
cst = createCst(structures, 1); % 1: use default parameters 2: user input

%% save ct, ctResolution and cst
fprintf('\nsaving variables...\n');
ctResolution = targetCtRes;
if ~exist(outputFolder,'dir')
    mkdir(outputFolder)
end
save([outputFolder patientName '.mat'],'ct','ctResolution','cst');
fprintf(['\nfinished!\nImported patient data can be found in:\n'...
    patientName '.mat\n']);
fprintf('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n')
%% show exemplary slice
visCtAndContour(ct, structures);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Skript to create a ct-cube of a specified resolution and a cst-cell
% (containing info about the contoured organs) from DICOM ct-slices and 
% a RTSTRUCT file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameters
% specify paths to the ct-image folder and the RTSTRUCT file
ctPath = 'D:\matRad projects\GitHub\matRad\TestPatient\TG119_Dicom';
structPath = ['D:\matRad projects\GitHub\matRad\TestPatient\TG119_Dicom'...
            '\RS.TG119_CShape.dcm'];

targetCtRes = [3 3 2.5]; % define the desired ct-resolution (will be
                     % interpolated from the original ct-cube)
% output folder:
outputFolder = 'D:\matRad projects\GitHub\matRad\DICOMimported\';
% patient description used for the final *.mat file
patientName = 'TestPatient1';
        
%% import ct-cube
fprintf(['+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ...
    '\nimporting ct-cube...']);
[origCt, origCtResolution, origCtInfo] = readCtSlices(ctPath, 1); % 0 = no visualization
fprintf('finished!\n');

%% calculating water equivalent thickness from HU
% % % not before the interpolation, as it possibly results in a values < 0
% % % fprintf('\nconversion of ct-Cube to waterEqT...');
% % % origCt = calcWaterEqT(origCt, origCtInfo);
% % % fprintf('finished!\n');

%% interpolating new ct-cube
fprintf('\ninterpolating ct-cube to desired resolution...');
ct = interp3dCube(origCt, origCtResolution, targetCtRes);

% creating necessary info for the handling of the structures
ctInfo.PixelSpacing = [targetCtRes(1);targetCtRes(2)];
ctInfo.SliceThickness = targetCtRes(3);
ctInfo.ImagePositionPatient = origCtInfo.ImagePositionPatient;
ctInfo.ImageOrientationPatient = origCtInfo.ImageOrientationPatient;
ctInfo.PatientPosition = origCtInfo.PatientPosition;
ctInfo.Width = numel(ct(:,1,1));
ctInfo.Height = numel(ct(1,:,1));
ctInfo.ImagesInAcquisition = numel(ct(1,1,:));
ctInfo.RescaleSlope = origCtInfo.RescaleSlope;
ctInfo.RescaleIntercept = origCtInfo.RescaleIntercept;

fprintf('finished!\n');
%% calculating water equivalent thickness from HU
fprintf('\nconversion of ct-Cube to waterEqT...');
ct = calcWaterEqT(ct, ctInfo);
fprintf('finished!\n');

%% import structure data
fprintf('\nreading structures...');
structures = readStruct(structPath, 0); % 0 = no visualization
fprintf('finished!\n');

%% creating structure cube
for i = 1:numel(structures)
    fprintf('\ncreating cube for %s volume...\n', structures(i).structName);
    structures(i).cube = createStructCube(structures(i).points, ctInfo);
    structures(i).indices = getIndizesFromCube(structures(i).cube);
end
fprintf('finished!\n');

%% creating cst
fprintf('\ncreating cst...');
cst = createCst(structures, 1); % 1: use default parameters 2: user input
fprintf('finished!\n');

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
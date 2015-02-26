%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Skript to create a ct-cube of a specified resolution and a cst-cell
% (containing info about the contoured organs) from DICOM ct-slices and 
% a RTSTRUCT file
% second version: now the patient diretory can be scanned for DICOM files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
% specify path to the patient directory containing the ct and structure
% files
patDir = 'D:\klingeData\TestPatients\TG119_dicom';
% define the desired ct-resolution which will be interpolated from the
% original ct-cube
targetCtRes = [3 3 2.5];
% output folder:
outputFolder = 'D:\matRad projects\GitHub\matRad\DICOMimported\';
% patient description used for the final *.mat file
patientName = 'TestPatient2';

%% analyze patient directory
fprintf(['+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ...
    '\nAnalyzing patient directory...\n']);
[ctList, structList, structPath, otherFiles] = analyzePatDir(patDir);

%% import ct-cube
fprintf('\nimporting ct-cube...');
[origCt, origCtResolution, sliceInfo, indexing] =...
    readCtSlicesNEW(ctList, 1); % 0 = no visualization
fprintf('finished!\n');

%% check the spacing of the slices
% find all identical slice thicknesses
eqSlices = find([sliceInfo.SliceThickness] == sliceInfo(1).SliceThickness);
% if slices are not equispaced -> can't be imported yet
if numel(eqSlices) < numel([sliceInfo.SliceThickness])
    error('Non-constant slice spacing detected! The import has been aborted.')
end

%% interpolating new ct-cube
fprintf('\ninterpolating ct-cube to desired resolution...');
ct = interp3dCube(origCt, origCtResolution, targetCtRes);

% creating necessary info for the handling of the structures
ctInfo.PixelSpacing = [targetCtRes(1);targetCtRes(2)];
ctInfo.SliceThickness = targetCtRes(3);
ctInfo.ImagePositionPatient = sliceInfo(1).ImagePositionPatient;
ctInfo.ImageOrientationPatient = sliceInfo(1).ImageOrientationPatient;
ctInfo.PatientPosition = sliceInfo(1).PatientPosition;
ctInfo.Width = numel(ct(:,1,1));
ctInfo.Height = numel(ct(1,:,1));
ctInfo.ImagesInAcquisition = numel(ct(1,1,:));
ctInfo.RescaleSlope = sliceInfo(1).RescaleSlope;
ctInfo.RescaleIntercept = sliceInfo(1).RescaleIntercept;

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
    structures(i).cube = createStructCubeNEW(structures(i).points, ctInfo);
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

%% visualize results
pln.resolution = ctResolution;
pln.isoCenter = matRad_getIsoCenter(cst,ct,pln,0);
matRad_visCtDose([],cst,pln,ct);
% visCtAndContour(ct, structures);
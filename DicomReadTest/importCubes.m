%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Skript to create a ct-cube and a matching Structure cubes from DICOM
% ct-slices and an RTSTRUCT file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameters
ctPath = 'D:\matRad projects\GitHub\matRad\TestPatient\Quasimodo';
structPath = ['D:\matRad projects\GitHub\matRad\TestPatient\' ...
            'RS1.3.6.1.4.1.2452.6.120060512.20736.311.101211283.dcm'];

targetCtRes = [3 3 3]; % define the desired ct-resolution (will be
                     % interpolated from the original ct-cube)
        
%% import ct-cube
fprintf('importing ct-Cube...\n');
[origCt, origCtResolution, origCtInfo] = readCtSlices(ctPath, 0); % 0 = no visualization

%% interpolating new ct-cube
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
fprintf('reading structures...\n');
structures = readStruct(structPath, 0); % 0 = no visualization

%% creating structure cube

for i = 1:numel(structures)
    fprintf('creating cube for %s volume...\n', structures(i).structName);
    structures(i).cube = createStructCube(structures(i).points, ctInfo);
    structures(i).indizes = getIndizesFromCube(structures(i).cube);
end
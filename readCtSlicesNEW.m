function [ct, ctResolution, info, indexing] = readCtSlicesNEW(ctList, visualizationBool)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call ct = readCtSlices('path\to\DICOM\files', visualizationBool)
% returns a X x Y x Z - Matrix containing the ct image
% if visualizationBool is not specified, visualization is turned on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% processing input variables
if nargin < 2
    visualizationBool = 1;
end

%% preparing the slices and ct-cube
ctInfo = dicominfo(ctList{1});
ctResolution = zeros(1,3);
ctResolution(1) = ctInfo.PixelSpacing(1);
ctResolution(2) = ctInfo.PixelSpacing(2);
ctResolution(3) = ctInfo.SliceThickness;

% creation of info list
numOfSlices = numel(ctList);
info = struct(ctInfo);
fprintf('\ncreating info...')
for i = 1:numOfSlices
    info(i) = dicominfo(ctList{i});
    matRad_progress(i,numOfSlices);
end

% adjusting sequence of slices (filenames my not be ordered propperly....
% e.g. CT1.dcm, CT10.dcm, CT100zCoordList = [info.ImagePositionPatient(1,3)]';.dcm, CT101.dcm,...
CoordList = [info.ImagePositionPatient]';
[~, indexing] = sort(CoordList(:,3)); % get sortation from z-coordinates

ctList = ctList(indexing);
info = info(indexing);

%% checking the patient position
% As of now, the matRad treatment planning system is only valid for
% patients in a supine position. Other orientations (e.g. prone, decubitus
% left/right) are not supported.
% Defined Terms:
% HFP     Head First-Prone                  (not supported)
% HFS     Head First-Supine                 (supported)
% HFDR    Head First-Decubitus Right        (not supported)
% HFDL    Head First-Decubitus Left         (not supported)
% FFDR    Feet First-Decubitus Right        (not supported)
% FFDL    Feet First-Decubitus Left         (not supported)
% FFP     Feet First-Prone                  (not supported)
% FFS     Feet First-Supine                 (supported)

if ~strcmp(ctInfo.PatientPosition,'HFS') ...
        || ~strcmp(ctInfo.ctInfo.PatientPosition,'FFS')
    error(['This Patient Position is not supported by matRad.'...
        ' As of now only ''HFS'' (Head First-Supine) and ''FFS'''...
        ' (Feet First-Supine) can be processed.'])    
end

%% creation of ct-cube
fprintf('reading slices...')
ct = zeros(ctInfo.Width, ctInfo.Height, numOfSlices);
for i = 1:numOfSlices
    currentFilename = ctList{i};
    [currentImage, map] = dicomread(currentFilename);
    ct(:,:,i) = currentImage(:,:); % creation of the ct cube
    
    % draw current ct-slice
    if visualizationBool
        if ~isempty(map)
            image(ind2rgb(uint8(63*currentImage/max(currentImage(:))),map));
            xlabel('x [voxelnumber]')
            ylabel('y [voxelnumber]')
            title(['Slice number ' int2str(i) ' of ' int2str(numOfSlices)])
        else
            image(ind2rgb(uint8(63*currentImage/max(currentImage(:))),bone));
            xlabel('x [voxelnumber]')
            ylabel('y [voxelnumber]')
            title(['Slice number ' int2str(i) ' of ' int2str(numOfSlices)])
        end
        pause(0.1);
    end
    matRad_progress(i,numOfSlices);
end

%% correction if not lps-coordinate-system
% when using the physical coordinates (ctInfo.ImagePositionPatient) to
% arrange the  slices in z-direction, there is no more need for mirroring
% in the z-direction
fprintf('\nz-coordinates taken from ImagePositionPatient\n')

% The x- & y-direction in lps-coordinates are specified in:
% ImageOrientationPatient
xDir = ctInfo.ImageOrientationPatient(1:3); % lps: [1;0;0]
yDir = ctInfo.ImageOrientationPatient(4:6); % lps: [0;1;0]
nonStandardDirection = false;

% correct x- & y-direction

if xDir(1) == 1 && xDir(2) == 0 && xDir(3) == 0
    fprintf('x-direction OK\n')
elseif xDir(1) == -1 && xDir(2) == 0 && xDir(3) == 0
    fprintf('\nMirroring x-direction...')
    ct_temp = zeros(size(ct));

    for j=1:size(ct,1)
        ct_temp(size(ct,3)-j+1,:,:) = ct(j,:,:);
    end

    ct = ct_temp;
    fprintf('finished!\n')
else
    nonStandardDirection = true;
end
    
if yDir(1) == 0 && yDir(2) == 1 && yDir(3) == 0
    fprintf('y-direction OK\n')
elseif yDir(1) == 0 && yDir(2) == -1 && yDir(3) == 0
    fprintf('\nMirroring y-direction...')
    ct_temp = zeros(size(ct));

    for j=1:size(ct,1)
        ct_temp(:,size(ct,3)-j+1,:) = ct(:,j,:);
    end

    ct = ct_temp;
    fprintf('finished!\n')
else
    nonStandardDirection = true;
end
if nonStandardDirection
    fprintf(['Non-standard patient orientation.\n'...
        'CT might not fit to contoured structures\n'])
end

end
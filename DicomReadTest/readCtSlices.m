function [ct, ctResolution, ctInfo, info] = readCtSlices(ctPath, visualizationBool)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call ct = readCtSlices('path\to\DICOM\files', visualizationBool)
% returns a X x Y x Z - Matrix containing the ct image
% if visualizationBool is not specified, visualization is turned on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% processing input variables
if nargin < 2
    visualizationBool = 1;
end

%% get list of *.dcm files
nameList = dir([ctPath '\*.dcm']);
% use only files that are named 'CT', in case there are other *.dcm files
% in the folder (e.g. RTSTRUCT file 'RS1.3.4.1..... .dcm')
for i = numel(nameList):-1:1
    if isempty(regexp(nameList(i).name,'CT', 'once'));
        nameList(i) = [];
    end
end
numOfSlices = numel(nameList);% number of ct-slices in chosen directory

%% read the *.dcm ct-slices
ctInfo = dicominfo(nameList(1).name); % ct-info struct
ctResolution = zeros(1,3);
ctResolution(1) = ctInfo.PixelSpacing(1);
ctResolution(2) = ctInfo.PixelSpacing(2);
ctResolution(3) = ctInfo.SliceThickness;

% creation of ct-cube
ct = zeros(ctInfo.Width, ctInfo.Height, numOfSlices);
info = struct(ctInfo);
for i = 1:numOfSlices
    currentFilename = nameList(i).name;
    [currentImage, map] = dicomread(currentFilename);
    ct(:,:,i) = currentImage(:,:); % creation of the ct cube
    
    % get info for each ct-file
    info(i) = dicominfo(nameList(i).name);
    
    % draw current ct-slice
    if visualizationBool
        if ~isempty(map)
            image(ind2rgb(uint8(63*currentImage/max(currentImage(:))),map));
        else
            image(ind2rgb(uint8(63*currentImage/max(currentImage(:))),bone));
        end
        pause(0.1);
    end
end

%% correction if not lps-coordinate-system
% if head-to-feet (HF: Head First) instead of feet-to-head (FF: Feet first)
% the ct-cube has to be mirrored
if ~isempty(regexp(ctInfo.PatientPosition,'HF', 'once'))
    fprintf('\nMirroring z-direction...')
    ct_temp = zeros(size(ct));

    for j=1:size(ct,3)
        ct_temp(:,:,size(ct,3)-j+1) = ct(:,:,j);
    end

    ct = ct_temp;
    fprintf('finished!\n')
end

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
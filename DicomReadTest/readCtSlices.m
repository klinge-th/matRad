function [ct, ctResolution, ctInfo] = readCtSlices(ctPath, visualizationBool)
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
for i = 1:numOfSlices
    currentFilename = nameList(i).name;
    [currentImage, map] = dicomread(currentFilename);
    ct(:,:,i) = currentImage(:,:); % creation of the ct cube
    
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


end
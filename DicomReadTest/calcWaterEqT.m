function ctHU = calcWaterEqT(ct, ctInfo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to calculate the water equivalent thickness from a ct-image cube
%
% The ct-image is mad up of intensity values (IV), which can be translated
% to HU:
%       HU = IV * slope + intercept
% slope and intercept are stored in the dicom file info
% 
% using a look up table (LUT) for HU to waterEqThickness, a new cube is 
% generated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% conversion from IV to HU

slope = ctInfo.RescaleSlope;
intercept = ctInfo.RescaleIntercept;

ctHU = ct * slope + intercept;

%% conversion from HU to waterEqThickness
load('DicomReadTest\HU2waterEqT.mat'); % load LUT

% Manual adjustments if ct data is corrupt. If some values are out of range
% of the LUT, then these values are adjusted.
ctHU(ctHU<-1024) = -1024;
ctHU(ctHU>3071) = 3071;

% execute conversion to waterEqT: 
% LUT:| waterEqT  |   HU    |
%     |   0       |  -1024  |
%     |   0       |  -1023  |
%     |  ...      |   ...   |
% 
% the first row corresponds to a HU-value of -1024 -> index = ctHU+1025
ctHU = reshape(HU2waterEqT(ctHU+1025,1),size(ctHU));

end
function structCube = createStructCube(structContPoints,ctInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to create a cube similar to the original ct-cube containing the
% contoured structure in the ct-coordinates
% call structCube = createStructCube(structContPoints,ctInfo)
% - structContPoints: cartesian-contour-coordinates
% - ctInfo: struct containing the dicomInfo of the ct-slices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% general conditions
voxelSpacing = [ctInfo.PixelSpacing(1), ctInfo.PixelSpacing(2),...
                                                    ctInfo.SliceThickness];

% checking Patient Orientation
if ~isequal(ctInfo.ImageOrientationPatient,[1;0;0;0;1;0])
    error('createStructCube:patientOrientation',...
        'Patient axis not along x & y axis')
end

% determination of offset between ct-image and struct-contours
xOff = ctInfo.ImagePositionPatient(1);
yOff = ctInfo.ImagePositionPatient(2); 
zOff = ctInfo.ImagePositionPatient(3);

% initializing cube                                                
cubeDimensions = [ctInfo.Width, ctInfo.Height, ctInfo.ImagesInAcquisition];
structCube = zeros(cubeDimensions);

%% generate voxel coordinates from cartesian
numOfContPoints = numel(structContPoints(:,1));
voxContPoints = zeros(numOfContPoints,3);
for i = 1:numOfContPoints
    cartVect = structContPoints(i,:);
    
    voxelVect = [0.5 + (cartVect(1) - xOff) / voxelSpacing(1),...
        0.5 + (cartVect(2) - yOff) / voxelSpacing(2),...
        0.5 + (cartVect(3) - zOff) / voxelSpacing(3)];
    voxContPoints(i,:) = voxelVect;
    % +0.5 = 1/2 voxel. This sets the center of the first voxel at the
    % origin of the cube in physical coordinates
end

voxContPoints = ceil(voxContPoints(:,:));
voxContPoints(voxContPoints <= 0) = 1; % in case of a point at the origin

%% generate coordinates inside the contours
% create grid points
[X,Y] = meshgrid(1:double(cubeDimensions(1)),1:double(cubeDimensions(2)));
% create contour vectors
xVect = voxContPoints(:,1);
yVect = voxContPoints(:,2);

numberOfSlices = numel(unique(voxContPoints(:,3)));
indexCounter = 1;
for i = 1:numberOfSlices % loop over all slices with contour points
    
    sliceCoordinate = voxContPoints(indexCounter,3);
    numOfPointsInSlice = ...
        sum(voxContPoints(:,3) == sliceCoordinate);
    
    %determine points inside the contour
    IN = inpolygon(X,Y,...
        xVect(indexCounter:(indexCounter+numOfPointsInSlice-1)),...
        yVect(indexCounter:(indexCounter+numOfPointsInSlice-1)));
    
    % fill structCube
    structCube(:,:,sliceCoordinate) = IN;    
    
    indexCounter = indexCounter + numOfPointsInSlice;
    matRad_progress(i, numberOfSlices);
end


end
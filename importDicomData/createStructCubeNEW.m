function structCube = createStructCubeNEW(structContPoints,ctInfo)

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
if ~isequal(abs(ctInfo.ImageOrientationPatient),[1;0;0;0;1;0])
    error('createStructCube:patientOrientation',...
        'Patient axis not along x & y axis')
end

% determination of offset between ct-image and struct-contours
% for this the dicominfo has to be taken from the first slice (in the
% lps-coordinate system)
xOff = ctInfo.ImagePositionPatient(1);
yOff = ctInfo.ImagePositionPatient(2); 
zOff = ctInfo.ImagePositionPatient(3);

% determine direction of the coordinates to transform to lps-system
dirVect = [ctInfo.ImageOrientationPatient(1),... % x-direction
            ctInfo.ImageOrientationPatient(5),...% y-direction 
            1]; 
        % z-direction is already correct for the imported cube when using
        % the physical coordinates to determine the slice sequence

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
% adjustment if x-direction of the cube was mirrored
if dirVect(1) == -1;
    voxContPoints(:,1) = cubeDimensions(1) - voxContPoints(:,1) + 1;
end
% adjustment if y-direction of the cube was mirrored
if dirVect(2) == -1;
    voxContPoints(:,2) = cubeDimensions(2) - voxContPoints(:,2) + 1;
end

voxContPoints = ceil(voxContPoints(:,:));
voxContPoints(voxContPoints <= 0) = 1; % in case of a point at the origin

%% generate coordinates inside the contours

% first delete contour points that are definded outside of the ct-cube
for i = 1:3
    idx = voxContPoints(:,i) > cubeDimensions(i);
    if sum(idx) ~= 0
        fprintf('deleting contourpoints defined outside of the CT-cube\n')
    end
    voxContPoints(idx,:) = [];    
end

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
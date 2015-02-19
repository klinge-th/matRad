function interpCube = interp3dCube(origCube, origRes, newRes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call interpCube = interp3dCube(original ct-Cube, origRes, newRes) to 
% change the dimensions of the ct-cube. origRes and newRes are row-vectors
% with the distance of the voxels in mm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% setting resolutions
origNumOfVoxX = numel(origCube(:,1,1));
origNumOfVoxY = numel(origCube(1,:,1));
origNumOfVoxZ = numel(origCube(1,1,:));

factX = origRes(1) / newRes(1);
factY = origRes(2) / newRes(2);
factZ = origRes(3) / newRes(3);

newNumOfVoxX = round(factX * origNumOfVoxX);
newNumOfVoxY = round(factY * origNumOfVoxY);
newNumOfVoxZ = round(factZ * origNumOfVoxZ);

%% create grids for the cubes
[origX, origY, origZ] = ndgrid(1:origNumOfVoxX,...
                            1:origNumOfVoxY,1:origNumOfVoxZ);
[newX, newY, newZ] = ndgrid(1:(1/factX):origNumOfVoxX,...
                            1:(1/factY):origNumOfVoxY,...
                            1:(1/factZ):origNumOfVoxZ);
                                                
%% interpolate Cube

interpCube = interpn(origX,origY,origZ,origCube,newX,newY,newZ,'spline'); 


end
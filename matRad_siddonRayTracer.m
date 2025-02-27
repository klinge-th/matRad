function [alphas,l,rho,d12,vis] = matRad_siddonRayTracer(isocenter,resolution,sourcePoint,targetPoint,cubes,visBool)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% siddon ray tracing through three dimensional cube to calculate the
% radiological depth according to Siddon 1985 Medical Physics
% 
% call
%   [alphas,l,rho,d12,vis] = matRad_siddonRayTracer(isocenter,resolution,sourcePoint,targetPoint,cubes,visBool)
%
% input
%   isocenter:      isocenter within cube [voxels]
%   resolution:     resolution of the cubes [mm/voxel]
%   sourcePoint:    source point of ray tracing
%   targetPoint:    target point of ray tracing
%   cubes:          cell array of cubes for ray tracing (it is possible to pass
%                   multiple cubes for ray tracing to save computation time)
%   visBool:        toggle on/off visualization (optional)
%
% output (see Siddon 1985 Medical Physics for a detailed description of the
% variales)
%   alphas          relative distance between start and endpoint for the 
%                    intersections with the cube
%   l               lengths of intersestions with cubes
%   rho             densities extracted from cubes
%   d12             distance between start and endpoint of ray tracing
%   vis             struct for later visualization purposes
%
% References
%   [1] http://www.ncbi.nlm.nih.gov/pubmed/4000088
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2015, Mark Bangert, on behalf of the matRad development team
%
% m.bangert@dkfz.de
%
% This file is part of matRad.
%
% matrad is free software: you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free 
% Software Foundation, either version 3 of the License, or (at your option)
% any later version.
%
% matRad is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License in the
% file license.txt along with matRad. If not, see
% <http://www.gnu.org/licenses/>.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 6
    visBool = 0;
end

% Add isocenter to source and target point. Because the algorithm does not
% works with negatives values. This put (0,0,0) in the center of first
% voxel
sourcePoint = sourcePoint + isocenter;
targetPoint = targetPoint + isocenter;

% Save the numbers of planes.
[yNumPlanes, xNumPlanes, zNumPlanes] = size(cubes{1});
xNumPlanes = xNumPlanes + 1;
yNumPlanes = yNumPlanes + 1;
zNumPlanes = zNumPlanes + 1;

% eq 11
% Calculate the distance from source to target point.
d12 = norm(sourcePoint-targetPoint);

% eq 3
% Position of first planes in millimeter. 0.5 because the central position
% of the first voxel is at [resolution(1) resolution(2) resolution(3)]
xPlane_1 = .5*resolution(1);
yPlane_1 = .5*resolution(2);
zPlane_1 = .5*resolution(3);

% Position of last planes in milimiter
xPlane_end = (xNumPlanes - .5)*resolution(1);
yPlane_end = (yNumPlanes - .5)*resolution(2);
zPlane_end = (zNumPlanes - .5)*resolution(3);

% eq 4
% Calculate parametrics values of \alpha_{min} and \alpha_{max} for every
% axis, intersecting the ray with the sides of the CT. 
if targetPoint(1) ~= sourcePoint(1)
    aX_1   = (xPlane_1 - sourcePoint(1)) / (targetPoint(1) - sourcePoint(1));
    aX_end = (xPlane_end - sourcePoint(1)) / (targetPoint(1) - sourcePoint(1));
else
    aX_1   = [];
    aX_end = [];
end
if targetPoint(2) ~= sourcePoint(2)
    aY_1   = (yPlane_1 - sourcePoint(2)) / (targetPoint(2) - sourcePoint(2));
    aY_end = (yPlane_end - sourcePoint(2)) / (targetPoint(2) - sourcePoint(2));
else
    aY_1   = [];
    aY_end = [];
end
if targetPoint(3) ~= sourcePoint(3)
    aZ_1   = (zPlane_1 - sourcePoint(3)) / (targetPoint(3) - sourcePoint(3));
    aZ_end = (zPlane_end - sourcePoint(3)) / (targetPoint(3) - sourcePoint(3));
else
    aZ_1   = [];
    aZ_end = [];
end

% eq 5
% Compute the \alpha_{min} and \alpha_{max} in terms of parametric values
% given by equation 4.
alpha_min = max([0 min(aX_1,aX_end) min(aY_1,aY_end) min(aZ_1,aZ_end)]);
alpha_max = min([1 max(aX_1,aX_end) max(aY_1,aY_end) max(aZ_1,aZ_end)]);

% eq 2
% Calculate X,Y,Z min and max using parametrically equations.
x_min = sourcePoint(1) + alpha_min * (targetPoint(1) - sourcePoint(1));
y_min = sourcePoint(2) + alpha_min * (targetPoint(2) - sourcePoint(2));
z_min = sourcePoint(3) + alpha_min * (targetPoint(3) - sourcePoint(3));
x_max = sourcePoint(1) + alpha_max * (targetPoint(1) - sourcePoint(1));
y_max = sourcePoint(2) + alpha_max * (targetPoint(2) - sourcePoint(2));
z_max = sourcePoint(3) + alpha_max * (targetPoint(3) - sourcePoint(3));

% eq 6
% Calculate the range of indeces who gives parametric values for
% intersected planes.
if targetPoint(1) == sourcePoint(1)
    i_min = []; i_max = [];
elseif targetPoint(1) > sourcePoint(1)
    i_min = xNumPlanes - (xPlane_end - alpha_min * (targetPoint(1) - sourcePoint(1)) - sourcePoint(1))/resolution(1);
    i_max = 1          + (sourcePoint(1) + alpha_max * (targetPoint(1) - sourcePoint(1)) - xPlane_1)/resolution(1);
    % rounding
    i_min = ceil(1/1000*(round(1000*i_min)));
    i_max = floor(1/1000*(round(1000*i_max)));
else
    i_min = xNumPlanes - (xPlane_end - alpha_max * (targetPoint(1) - sourcePoint(1)) - sourcePoint(1))/resolution(1);
    i_max = 1          + (sourcePoint(1) + alpha_min * (targetPoint(1) - sourcePoint(1)) - xPlane_1)/resolution(1);
    i_min = ceil(1/1000*(round(1000*i_min)));
    i_max = floor(1/1000*(round(1000*i_max)));
end
if targetPoint(2) == sourcePoint(2)
    j_min = []; j_max = [];
elseif targetPoint(2) > sourcePoint(2)
    j_min = yNumPlanes - (yPlane_end - alpha_min * (targetPoint(2) - sourcePoint(2)) - sourcePoint(2))/resolution(2);
    j_max = 1          + (sourcePoint(2) + alpha_max * (targetPoint(2) - sourcePoint(2)) - yPlane_1)/resolution(2);
    j_min = ceil(1/1000*(round(1000*j_min)));
    j_max = floor(1/1000*(round(1000*j_max)));
else
    j_min = yNumPlanes - (yPlane_end - alpha_max * (targetPoint(2) - sourcePoint(2)) - sourcePoint(2))/resolution(2);
    j_max = 1          + (sourcePoint(2) + alpha_min * (targetPoint(2) - sourcePoint(2)) - yPlane_1)/resolution(2);
    j_min = ceil(1/1000*(round(1000*j_min)));
    j_max = floor(1/1000*(round(1000*j_max)));
end
if targetPoint(3) == sourcePoint(3)
    k_min = []; k_max = [];
elseif targetPoint(3) >= sourcePoint(3)
    k_min = zNumPlanes - (zPlane_end - alpha_min * (targetPoint(3) - sourcePoint(3)) - sourcePoint(3))/resolution(3);
    k_max = 1          + (sourcePoint(3) + alpha_max * (targetPoint(3) - sourcePoint(3)) - zPlane_1)/resolution(3);
    k_min = ceil(1/1000*(round(1000*k_min)));
    k_max = floor(1/1000*(round(1000*k_max)));
else
    k_min = zNumPlanes - (zPlane_end - alpha_max * (targetPoint(3) - sourcePoint(3)) - sourcePoint(3))/resolution(3);
    k_max = 1          + (sourcePoint(3) + alpha_min * (targetPoint(3) - sourcePoint(3)) - zPlane_1)/resolution(3);
    k_min = ceil(1/1000*(round(1000*k_min)));
    k_max = floor(1/1000*(round(1000*k_max)));
end

% eq 7
% For the given range of indices, calculate the paremetrics values who
% represents intersections of the ray with the plane.
if i_min ~= i_max
    if targetPoint(1) > sourcePoint(1)
        alpha_x = (resolution(1)*(i_min:1:i_max)-sourcePoint(1)-.5*resolution(1))/(targetPoint(1)-sourcePoint(1));
    else
        alpha_x = (resolution(1)*(i_max:-1:i_min)-sourcePoint(1)-.5*resolution(1))/(targetPoint(1)-sourcePoint(1));
    end
else
    alpha_x = [];
end
if j_min ~= j_max
    if targetPoint(2) > sourcePoint(2)
        alpha_y = (resolution(2)*(j_min:1:j_max)-sourcePoint(2)-.5*resolution(2))/(targetPoint(2)-sourcePoint(2));
    else
        alpha_y = (resolution(2)*(j_max:-1:j_min)-sourcePoint(2)-.5*resolution(2))/(targetPoint(2)-sourcePoint(2));
    end
else
    alpha_y = [];
end
if k_min ~= k_max
    if targetPoint(3) > sourcePoint(3)
        alpha_z = (resolution(3)*(k_min:1:k_max)-sourcePoint(3)-.5*resolution(3))/(targetPoint(3)-sourcePoint(3));
    else
        alpha_z = (resolution(3)*(k_max:-1:k_min)-sourcePoint(3)-.5*resolution(3))/(targetPoint(3)-sourcePoint(3));
    end
else
    alpha_z = [];
end

% eq 8
% Merge parametrics sets.
alphas = unique([alpha_min alpha_x alpha_y alpha_z alpha_max]);

% eq 10
% Calculate the voxel intersection length.
l = d12*diff(alphas);

% eq 13
% Calculate \alpha_{middle}
alphas_mid = mean([alphas(1:end-1);alphas(2:end)]);

% eq 12
% Calculate the voxel indices: first convert to physical coords
i_mm = sourcePoint(1) + alphas_mid*(targetPoint(1) - sourcePoint(1));
j_mm = sourcePoint(2) + alphas_mid*(targetPoint(2) - sourcePoint(2));
k_mm = sourcePoint(3) + alphas_mid*(targetPoint(3) - sourcePoint(3));
% then convert to voxel index
i = round(i_mm/resolution(1));
j = round(j_mm/resolution(2));
k = round(k_mm/resolution(3));

% Handle numerical instabilities at the borders.
i(i<=0) = 1; j(j<=0) = 1; k(k<=0) = 1;
i(i>xNumPlanes-1) = xNumPlanes-1;
j(j>yNumPlanes-1) = yNumPlanes-1;
k(k>zNumPlanes-1) = zNumPlanes-1;

% Convert to linear indices
ix = sub2ind(size(cubes{1}),j,i,k);

% obtains the values from cubes
for i = 1:numel(cubes)
    rho{i} = cubes{i}(ix);
end

if visBool
   vis.alpha_x = alpha_x;
   vis.alpha_y = alpha_y;
   vis.alpha_z = alpha_z;
   vis.x_min   = x_min;
   vis.x_max   = x_max;
   vis.y_min   = y_min;
   vis.y_max   = y_max;
   vis.z_min   = z_min;
   vis.z_max   = z_max;
   vis.ix      = ix;
else
   vis = [];
end
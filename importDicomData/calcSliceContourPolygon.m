function [structX, structY] = calcSliceContourPolygon(structSlice)

structX = zeros(structSlice.NumberOfContourPoints,1); %prealocation
structY = zeros(structSlice.NumberOfContourPoints,1); %prealocation
indX = 1; % initial index of the x-coordinate
indY = 2; % initial index of the y-coordinate

% loop over all countour points of this slice
for i = 1:structSlice.NumberOfContourPoints
    structX(i) = structSlice.ContourData(indX);
    structY(i) = structSlice.ContourData(indY);
    indX = indX + 3;
    indY = indY + 3;
end

% close contour
structX = [structX; structX(1)];
structY = [structY; structY(1)];


end
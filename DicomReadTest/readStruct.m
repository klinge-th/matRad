function structures = readStruct(structPath,visbool)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to read the locations of the structures described in the
% RTSTRUCT file and return a struct containing:
% - contour-points off all defined structures (3-dim physical coordinates)
% - structure name and number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% get info
structInfo = dicominfo(structPath);

% list the defined structures
listOfDefStructs = fieldnames(structInfo.StructureSetROISequence);
% list of contoured structures
listOfContStructs = fieldnames(structInfo.ROIContourSequence);

%% process structure data
numOfDefStructs = numel(listOfDefStructs);
numOfContStructs = numel(listOfContStructs);

for i = 1:numOfContStructs % loop over every structure   

% determination of the structure's name

%     necessary?    
% %     roiNumber = structInfo.ROIContourSequence.(...
% %                                 listOfContStructs{i}).ReferencedROINumber;
% % 
% %     for j = 1:numOfDefStructs
% %         if roiNumber == structInfo.StructureSetROISequence.(...
% %                                 listOfDefStructs{j}).ROINumber;
% %             
% %             strucName = structInfo.StructureSetROISequence.(...
% %                                 listOfDefStructs{j}).ROIName;
% %             break
% %         end
% %     end

% Is This enough?
    structures(i).structName = structInfo.StructureSetROISequence.(...
                                   listOfDefStructs{i}).ROIName;
    structures(i).structNumber = structInfo.ROIContourSequence.(...
                                 listOfContStructs{i}).ReferencedROINumber;
    structures(i).structColor = structInfo.ROIContourSequence.(...
                                 listOfContStructs{i}).ROIDisplayColor;                         

    listOfSlices = fieldnames(structInfo.ROIContourSequence.(...
                                   listOfContStructs{i}).ContourSequence);
    
    % getting data of all structure slices
    structZ = []; % initializing array for z-coordinates of struct. slices
    wholeStructurePoints = zeros(1,3);
    for j = 1:numel(listOfSlices)
        structSlice = structInfo.ROIContourSequence.(...
                listOfContStructs{i}).ContourSequence.(listOfSlices{j});
        if strcmpi(structSlice.ContourGeometricType, 'POINT')
            continue;
        end
        % store the z-coordinate of this structure slice
        structZ = [structZ; structSlice.ContourData(3)];
        
        [structX, structY] = calcSliceContourPolygon(structSlice);
        slicePoints = [structX, structY, ones(length(structX),1)*structZ(j)];
        wholeStructurePoints = vertcat(wholeStructurePoints, slicePoints);
    end
    
    structures(i).points = wholeStructurePoints(2:end,:);
    
end

%% visualization
if visbool
    figureHandle = figure;
    hold on
    legendentries = '';
    for i = 1:numel(structures)
        plot(i) = scatter3(structures(i).points(:,1),structures(i).points(:,2),...
            structures(i).points(:,3),'*',...
            'MarkerEdgeColor',structures(i).structColor ./ 255,'Displayname',structures(i).structName);
    end
    legend('show')
end

end
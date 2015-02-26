function zVec = findzvec(rtstruc_path)
            dicom_struc_info = dicominfo(rtstruc_path);
            % dicomStructuresInfo.ROIContourSequence contains a list of all contoured
            % structers
            list_of_contoured_strucs = ...
                fieldnames(dicom_struc_info.ROIContourSequence);
            i = 1;
            for j = 1:(length(list_of_contoured_strucs)); % for every structure
                %% Calculate contour polygon and indicator_mask
                % list of slices of a given structure
                list_of_slices = fieldnames(dicom_struc_info.ROIContourSequence.(...
                    list_of_contoured_strucs{j}).ContourSequence);
                for k = 1:length(list_of_slices) % for every slice in a given structure
                    % get structure_slice
                    struc_slice = dicom_struc_info.ROIContourSequence.(...
                        list_of_contoured_strucs{j}).ContourSequence.(...
                        list_of_slices{k});
                    if strcmpi(struc_slice.ContourGeometricType, 'POINT')
                        continue;
                    end
                    % get z coordinate of this slice
                    zVec(i,1) = struc_slice.ContourData(3);
                    i = i+1;
                end
            end
            zVec = sort(unique(zVec),'descend');
        end
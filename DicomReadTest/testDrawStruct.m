function testDrawStruct(structCube, slice)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test the drawing of a ct cube after import from DICOM format
% call testDrawCt(3-dim. ct-cube Matrix, slice number)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% draw
% % % figure
% % % subplot(3,1,1)
% % % image(ind2rgb(squeeze(uint8(structCube(:,:,slice))),jet));
% % % 
% % % subplot(3,1,2)
% % % image(ind2rgb(squeeze(uint8(structCube(:,:,slice))),jet));
% % % 
% % % subplot(3,1,3)
% % % image(ind2rgb(squeeze(uint8(structCube(:,:,slice))),jet));

% figure
image(ind2rgb(squeeze(uint8(255*structCube(:,:,slice))),flipud(gray)));

end
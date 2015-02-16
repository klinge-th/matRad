function testDrawCt(ct, slice)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test the drawing of a ct cube after import from DICOM format
% call testDrawCt(3-dim. ct-cube Matrix, slice number)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% draw
figure
subplot(3,1,1)
image(ind2rgb(squeeze(uint8(63*ct(:,:,slice)/max(ct(:)))),bone));

subplot(3,1,2)
image(ind2rgb(squeeze(uint8(63*ct(:,250,:)/max(ct(:)))),bone));

subplot(3,1,3)
image(ind2rgb(squeeze(uint8(63*ct(250,:,:)/max(ct(:)))),bone));

end
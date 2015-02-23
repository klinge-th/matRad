for i = 1:numel(ct(1,:,1))
    image(ind2rgb(squeeze(uint8(63*ct(:,:,i)/max(ct(:)))),bone));
    pause(0.1);
end
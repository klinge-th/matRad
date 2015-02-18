function visCtAndContour(ct,structures)

figure 
hold on
% draw ct
image(ind2rgb(squeeze(uint8(63*ct(:,:,floor(median(1:numel(ct(1,1,:)))))/max(ct(:)))),bone));
% draw contours
for i = 1:numel(structures(1,:))
    contour(structures(i).cube(:,:,floor(median(1:numel(ct(1,1,:))))),.5*[1 1],...
        'Color',structures(i).structColor / 255,...
        'Displayname',structures(i).structName,...
        'LineWidth',2);
end
legend('show')



end
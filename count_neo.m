clear

NumFrame = 1;
spot_num = zeros(1,NumFrame)-1;

for i = 1:1:1
    im1 = imread('Strep_200nM_T11_1nM_hairpin_100nM_video.tif');
    im1 = double(im1);
    position = peakpick(im1,1.8); % consider central area: 80th-430th pixels on x and y.
%     position = peaktest(im1,1.8); 
    spot_num(i) = length(position);
end


%mean(spot_num)
imagesc(im1) 
colorbar
colormap gray
hold on
scatter(position(:,2),position(:,1),40,'g') % row index (1st dimension from 'im1') is on y axis.
xlabel('x')
ylabel('y')
%title('1um mb6d slide1d ostrep 100pm t20 bsainbf','fontsize',20);
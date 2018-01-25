clear

NumFrame=1;
spot_num=zeros(1,NumFrame)-1;
for i=1:1:1 % specify the frame index
    % use positions of bright spots in 1st frame as reference and 
    % study their intensity change across trajectory.
    
im1=imread('Cy3B_T11_50nM_4mW_oss.tif','index',i); % remember to change the # frame
%im1=double(im1(100:400,100:400));
im1=double(im1); % 2D matrix stores the value on each pixel.
position=peaktest(im1,1.3); % cant pre-allocate position bc its dimension might be different every time.
spot_num(i)=length(position);
end
length(position)
%mean(spot_num)
imagesc(im1) 
colorbar
colormap gray
hold on
scatter(position(:,2),position(:,1),40,'g')
%title('1um mb6d slide1d ostrep 100pm t20 bsainbf','fontsize',20);
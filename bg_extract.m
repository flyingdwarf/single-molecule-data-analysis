
bg=[];
filename='Cy3B_T11_50nM_4mW_oss.tif';
im=imread(filename,'index',1);
im=double(im);
im=im(51:450,51:450);
pix=peaktest(im,1.3,0);% use the same parameter as in traj_extract
edge=4;
out=[find(pix(:,1)<edge)',find(pix(:,1)>(400-edge))',find(pix(:,2)<edge)',find(pix(:,2)>(400-edge))'];
pix(out,:)=[];

for j=1:1000
    
im=imread(filename,'index',j);
im=double(im);
im=im(51:450,51:450);

for i=1:length(pix)
    reg=im(pix(i,1)+(-1:1),pix(i,2)+(-1:1));%may have overlap if choose 2, when spots density is high
    int_bg(i)=sum(reg(:));
end

bg(j)=(sum(im(:))-sum(int_bg))/(400*400-25*length(pix));

end

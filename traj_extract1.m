function int=traj_extract1(file,bgm)

frame=1800;%depends on the number of frame
im=arrayfun(@(i) imread(file,'Index',i),1:frame,'UniformOutput',false);
sect=(1:1:frame);
im_stack=double(reshape(cell2mat(im),512,512,frame));
%im_stack=im_stack(51:450,51:450,:);
%sometimes used the 51:450 pixels (center part of the image) for better
%data quality
pick_pos=peaktest(im_stack(:,:,1),1.3,0);
%im_stack=(im_stack-180)./bgm(51:450,51:450);

edge=3;
out=[find(pick_pos(:,1)<edge)',find(pick_pos(:,1)>(512-edge))',find(pick_pos(:,2)<edge)',find(pick_pos(:,2)>(512-edge))'];
%out=[find(pick_pos(:,1)<edge)',find(pick_pos(:,1)>(400-edge))',find(pick_pos(:,2)<edge)',find(pick_pos(:,2)>(400-edge))'];
pick_pos(out,:)=[];
int=arrayfun(@(x) reshape(sum(sum(im_stack(pick_pos(x,1)+(-1:1),pick_pos(x,2)+(-1:1),1:frame))),1,frame),1:length(pick_pos),'uniformoutput',false);
%int=arrayfun(@(x) reshape(im_stack(pick_pos(x,1),pick_pos(x,2),1:frame),1,frame),1:length(pick_pos),'uniformoutput',false);
int=cell2mat(int');
end

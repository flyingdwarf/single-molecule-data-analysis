function int=traj_extract(file)

%im=cell(1,4000);
NumFrame=1000;
im=arrayfun(@(i) imread(file,'Index',i),1:NumFrame,'UniformOutput',false);
% load in each frame.
% @(i) imread(...): creat an anonymous function
% 1:NumFrame: define the increment of i
% 'UniformOutput', false: outputs of func can be of any size and type.

sect=(1:1:NumFrame);
im_stack=double(reshape(cell2mat(im),512,512,NumFrame)); % stack all in a 3D matrix
sect_pos=arrayfun(@(x) peaktest(im_stack(:,:,x),1.3,0),sect,'uniformoutput',false);
all_pos=unique(cell2mat(sect_pos'),'rows');
% treat each row as a single entity and return the unique row in a sorted order
% all_pos contains all peak positions ever appeared in any of the frames.

i=1;
pick_pos=cell(1,15000); 
while isempty(all_pos)==0
    pick=find((abs(all_pos(:,2)-all_pos(1,2)))<4 & abs(all_pos(:,1)-all_pos(1,1))<4);
    pick_pos{i}=all_pos(pick,:);
    all_pos(pick,:)=[];
    i=i+1;
end
pick_pos(cellfun(@isempty,pick_pos))=[]; % pick_pos becomes a 1D cell
posnum=cell2mat(cellfun(@(x) size(x,1),pick_pos,'uniformoutput',false));
pick_pos(posnum<3)=[]; % posnum<3 returns an array with logical values: 0 or 1
pick_pos=cellfun(@mean,pick_pos,'uniformoutput',false); % on one bright spot, get the average coordinate.
pick_pos=round(cell2mat(pick_pos')); % pick_pos: x*2 matrix. round to nearest integer bc raw image's coordinates are integers

edge=3;
out=[find(pick_pos(:,1)<edge)',find(pick_pos(:,1)>(512-edge))',find(pick_pos(:,2)<edge)',find(pick_pos(:,2)>(512-edge))'];
pick_pos(out,:)=[];

% calculate intensity 
% take another 8 (3*3-1=8) points in vicinity for all frames and sum them up.
int=arrayfun(@(x) reshape(sum(sum(im_stack(pick_pos(x,1)+(-1:1),pick_pos(x,2)+(-1:1),1:NumFrame))),1,NumFrame),...
             1:length(pick_pos),'UniformOutput',false);
int=cell2mat(int')/9; % average over 9 points

end

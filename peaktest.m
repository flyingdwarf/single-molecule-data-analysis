function pix=peaktest(im,ratio,offset)

if nargin <3
    offset=0;
end

peak=cell(1,300);
bg=mean(im(:))-offset; % background is the average
[pos(:,1),pos(:,2)]=find(im>bg*ratio); % coordinate of peak candidates. pos(:,1): row #; pos(:,2): col #
edge=7; % define the margin. 
% Not consider peaks outside the margin. only within [edge, 512-edge]. 
% why? bc of the camera?
out=[find(pos(:,1)<=edge)',find(pos(:,1)>=(512-edge))',find(pos(:,2)<=edge)',find(pos(:,2)>=(256-edge))'];
% get the row number of coordinates of outlier peaks

pos_edge=pos(out,:); % record the position of outlier peaks
pos(out,:)=[]; % clear those rows.

%pos_id=arrayfun(@(x,y) check_pix(x,y,im),pos(:,1),pos(:,2));
%pos(pos_id==0,:)=[];

pos=[pos_edge;pos]; % pick out the outlier peaks' positions
i=1;
while isempty(pos)==0 % before the iteration: if it's empty, it's the outlier peak.
pick=find((abs(pos(:,2)-pos(1,2)))<5 & abs(pos(:,1)-pos(1,1))<5); % pos(1,:) and its neighbour will be picked.
peak{i}=pos(pick,:); % store pos(1,:) and its neighbour for peak No.i 
pos(pick,:)=[]; % it'll delete that row so dimension will decrease. pos(1,:) will be different
i=i+1;
end
peak(cellfun(@isempty,peak))=[]; 
% cellfun: apply function to each cell in cell array.
% cellfun(...) returns logical results, 0 or 1, for each position of array
% peak(1)=[] is different from peak{1}=[]: former: collapse cell array into
%   a row array; latter: only change cell content into empty. dimension
%   doesnt change.
% only empty cells will be deleted.

pixnum=cell2mat(cellfun(@(x) size(x,1),peak,'uniformoutput',false));
peak(pixnum<3)=[];
pix=cellfun(@(x) group_pix(x,im),peak,'uniformoutput',false);
pix=round(cell2mat(pix'));
end

function pixid=check_pix(pixel_y,pixel_x,im)
pix_range=8;
y=pixel_y+[-pix_range:pix_range];
x=pixel_x+[-pix_range:pix_range];
local_mean=sum(sum(im(y,x)))/((pix_range*2+1)^2);
if im(pixel_y,pixel_x)>(local_mean*1.2)
    pixid=1;
else
    pixid=0;
end
end

function pix=group_pix(pixels,im)

for j=1:size(pixels,1);
    int(j)=im(pixels(j,1),pixels(j,2));
end
pix(1)=sum(pixels(:,1).*int')/sum(int);
pix(2)=sum(pixels(:,2).*int')/sum(int);

end



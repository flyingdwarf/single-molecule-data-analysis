function int = traj_extract1(file,bgm)
% latest version. 09-03-18

%% parameters
NumFrame = 2000;
% sect = 1:1:frame;
ratio = 1.8;
edge1 = 80; 
edge2row = 512 - edge1;
edge2col = 512 - edge1;
% file = 'Strep_200nM_T11_1nM_hairpin_100nM_video.tif';

%% Read data and identify bright spots using the first frame.
im = arrayfun(@(i) imread(file,'Index',i),1:NumFrame,'UniformOutput',false);
im_stack = double(reshape(cell2mat(im),512,512,NumFrame));
% Do not crop images here becasue need the whole image to calculate background in "peakpick". 
% so could use ratio consistently.

% Identify spots from a certain frame. Usually the 1st frame because no spots are bleached.
pick_pos = peakpick(im_stack(:,:,1),ratio,0); % peakpick contains crop but only give bright spots in cropped area.

%% Look at the cropped area
im_stack = im_stack(edge1:edge2row,edge1:edge2col,:); % crop all frames.
% im_stack = (im_stack-180)./bgm(edge1:edge2row,edge1:edge2col); % seems make better sense to do this 

% Change indices of identified bright spots as well.
pick_pos(:,1) = pick_pos(:,1) - edge1+1;
pick_pos(:,2) = pick_pos(:,2) - edge1+1;

% Make sure each central spot has 8 pixels around.
margin=3;
boundrow = edge2row;
boundcol = edge2col;
out = [...
        find(pick_pos(:,1) < margin)',find(boundrow - pick_pos(:,1) < margin)',...
        find(pick_pos(:,2) < margin)',find(boundcol - pick_pos(:,2) < margin)'];
pick_pos(out,:) = [];

% Calculate the summed intensity in the 3x3 matrix of each peak, in each frame.
int = arrayfun(...
@(x) reshape(sum(sum(im_stack(pick_pos(x,1)+(-1:1),pick_pos(x,2)+(-1:1),1:NumFrame))),1,NumFrame),...
	1:length(pick_pos),'uniformoutput',false);
int=cell2mat(int');
int=int/9; % average over 9 elements in 3x3 matrix.
end
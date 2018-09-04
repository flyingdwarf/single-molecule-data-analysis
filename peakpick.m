function pix = peakpick(im,ratio,offset) % peaktest involves crop and only give bright spots in cropped area.
% im = im1;
% ratio = 1.7;

if nargin < 3 % number of input arguments
    offset = 0;
end

%% Find out bright spots based on ratio and bg, excluding peripheral areas.
peak = cell(1,300);
bg = mean(im(:))-offset; % background signal comes from averaged signal
[pos(:,1),pos(:,2)] = find(im > (bg*ratio)); % coordinate of peak candidates. pos(:,1): row #; pos(:,2): col #

% Define the margin. 
edge1 = 80; 
edge2row = 512 - edge1; % row index corresponds to y-value
edge2col = 512 - edge1; % col index corresponds to x-value
% Not consider peaks outside the margin. only within [edge, 512-edge]. 
% Central image is more illuminated than corners. Observed from calibration.

% Find out and remove outliers
out = [find(pos(:,1) < edge1)',find(pos(:,1) > edge2row)',...
       find(pos(:,2) < edge1)',find(pos(:,2) > edge2col)'];
pos(out,:) = []; 

%% Group adjacent bright peaks. Only use the group with more than or equal to 3 peaks
i=1;
% iterate until pos is empty
while isempty(pos)==0  
    % group adjacent peaks   
    pick = find(abs(pos(:,1)-pos(1,1))<5 & abs(pos(:,2)-pos(1,2))<5); % get the index in the matrix.
    peak{i} = pos(pick,:); % each element in "peak" cell is a nx2 array. n is variable.
    pos(pick,:) = [];
    i = i+1;
end
% % peak(cellfun(@isempty,peak))=[]; % not necessary: if it is empty, it is already [].
% cellfun: apply function to each cell in cell array.
% isempty returns logical results, 0 or 1, for each position of array
% peak(1)=[] is different from peak{1}=[]: former: collapse cell array into
%   a row array; latter: only change cell content into empty. dimension
%   doesnt change.
% only empty cells will be deleted.

% filter out small group. 
peaknum = cellfun(@(x) size(x,1),peak); % function is "size", place holder "x" indicates the variable.
% Or: pixnum1 = cell2mat(cellfun(@(x) size(x,1),peak,'uniformoutput',false));
peak(peaknum<3) = [];

%% Get the intensity-weighted center position for each group.
pix = cellfun(@(x) group_peaks(x,im),peak,'uniformoutput',false);
pix = round(cell2mat(pix')); % round to integer, i.e., the index in "im". So ONE source of pixel shift!!!!
end

function pix = group_peaks(peaks,im)

int = zeros(size(peaks,1),1);
for j = 1:size(peaks,1)
    int(j) = im(peaks(j,1),peaks(j,2));
end

% Use intensity as weight to get average position for each group of peaks.
pix(1) = sum(peaks(:,1).*int)/sum(int);
pix(2) = sum(peaks(:,2).*int)/sum(int);
end

%pos_id=arrayfun(@(x,y) check_pix(x,y,im),pos(:,1),pos(:,2));
%pos(pos_id==0,:)=[];

% function pixid = check_pix(pixel_y,pixel_x,im)
% pix_range=8;
% y=pixel_y+[-pix_range:pix_range];
% x=pixel_x+[-pix_range:pix_range];
% local_mean=sum(sum(im(y,x)))/((pix_range*2+1)^2);
% if im(pixel_y,pixel_x)>(local_mean*1.2)
%     pixid=1;
% else
%     pixid=0;
% end
% end



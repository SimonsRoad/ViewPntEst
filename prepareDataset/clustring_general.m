% clc;close all;
clear all;
% load([CONF.exp_dir, '/human36m_big.mat'])
small_4000; % config file
% load([CONF.exp_dir 'h80k_training_pose_name_2d3d.mat']); 
% load([CONF.exp_dir 'h80k_tranOnly_allAct_pose3d.mat'])


new_pose = zeros(size(pose_matrix,1), 36);
new_pose(:,1:18) =  [pose_matrix(:,4:12) pose_matrix(:,13:21)];    %knees
new_pose(:,18:18+17)= pose_matrix(:,34:51); %left & right hand
 
Z = linkage(new_pose, 'ward','euclidean','savememory', 'on');
NC = 10;c = cluster(Z, 'maxclust', NC);idx = c;
dst = strcat(CONF.exp_dir,'clusters')
for i=1:NC
    cat = find(idx == i);
    [i, length(cat)]
    mkdir(dst,  num2str(i))
    for j=1:length(cat)
       copyfile( [CONF.exp_dir names{cat(j)}(4:end)], [dst '/' num2str(i) '/' names{cat(j)}(18:end)])
    end
    
end
i
% for i=1:length(ind1)
%     im= imread(names{ind1(i)});
%   imwrite(im, ['/home/tt/star/h80k/data/tmp1/', num2str(i),'.jpg'])
% end
close all
figure;
subplot(311);im = imread( [ names{ind1(100)}]);imshow(im)
subplot(312);im = imread( [ names{ind2(200)}]);imshow(im)
subplot(313);im = imread( [ names{ind3(1010)}]);imshow(im)

% save('trn_only_Z_ward_max_leg_neck_feet.mat', 'Z', 'NC', 'idx');
clc;close all
len = [];
for i =1:NC
    len = [len, length(find(idx== i))];
end

clc;close all
len
samples = 16;
for i =1:NC
    group = find(idx== i);
    for j=i+1:NC
     aa = pdist2(new_pose(group,:), new_pose((idx== j),:));
     [i, j ,min(aa(:))]
    end
    figure(i)
    index = randi([1, length(group)], 1, samples);
    for s=1:samples
        subplot(sqrt(samples),sqrt(samples),s);imshow(imread(names{group(index(s))}))
    end
    subplot(sqrt(samples),sqrt(samples),1);title(num2str(length(group)))
end

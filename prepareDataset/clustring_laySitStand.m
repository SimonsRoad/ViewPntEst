% clc;close all;
clear all;
small_4000;
% load([CONF.exp_dir 'h80k_trnOnly_P23.mat']);
load([CONF.exp_dir 'h80k_trnVal_P23Name.mat']) % this is validation and train


new_pose = zeros(size(pose3d_matrix,1), 3);
new_pose(:,1)= max(pose3d_matrix(:,8) , pose3d_matrix(:,17));  %leg
new_pose(:,2)= max(pose3d_matrix(:,11) , pose3d_matrix(:,20)); %feet
new_pose(:,3)= pose3d_matrix(:,26); %neck

Z = linkage(new_pose, 'ward','euclidean','savememory', 'on');
NC = 3;c = cluster(Z, 'maxclust', NC);idx = c;
ind1  =find(idx==1);  ind2 = find(idx==2); ind3 = find(idx==3);
[length(ind1), length(ind2), length(ind3)]

% for i=1:length(ind3)
%     im= imread([CONF.exp_dir names{ind3(i)}(3:end)]);
%     imwrite(im, [CONF.exp_dir 'trn_standing/', num2str(i),'.png'])
% end
close all
figure;
subplot(311);im = imread( [CONF.exp_dir names{ind1(100)} ]);imshow(im)
subplot(312);im = imread( [CONF.exp_dir names{ind2(200)} ]);imshow(im)
subplot(313);im = imread( [CONF.exp_dir names{ind3(1000)} ]);imshow(im)

% save('trn_only_Z_ward_max_leg_neck_feet.mat', 'Z', 'NC', 'idx');
id_standing = ind3;
save([CONF.exp_dir 'h80k_trnVal_P23Name.mat'], 'pose3d_matrix', 'pose2d_matrix', 'names', 'id_standing', 'val_index')

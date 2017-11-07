% uncomment and adapt the line below depending on where you want your data
close all;clc;clear all;
small_4000; % config file
pose3D_pre = zeros(1, 51);
load([CONF.exp_dir 'human36m_big.mat'])
%% load some files
load([CONF.exp_dir, '/human36m_big.mat'])
N_trn = sum(METADATA.train_frame_count)
% pose_matrix96 = zeros(N_trn, 96);
% names = cell(N,1);
% pose_matrix96 = [];
pose2d_matrix = [];
total = 0;
% load(('/home/tt/star/h80k/data/h80k_training_pose_name.mat'))
 
for ii = 1:15
    activity= sprintf('ActivitySpecific_%02d.mat', ii);
    %     rgb = matfile([CONF.exp_dir 'DenseFeatures' filesep 'RGB' filesep activity]);
    %     gtd3p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep activity]);
    mask = matfile([CONF.exp_dir 'DenseFeatures' filesep 'GTFGM' filesep activity]);
    images = mask.Ftest;
    N_activity = METADATA.test_frame_count(ii);
    ii
    %     pose_matrix = zeros(N_activity, 96);
    pose2D_activity = zeros(N_activity, 32);
    for frNo = 1:N_activity
        %         im = cell2mat(images(frNo,1));
        %         im_name = sprintf('../training_imgs/im%d_%d.jpg', ii, frNo);
        %         imwrite(im, im_name)
        %         names{g_frNo} = im_name;
        tmp = mask.Ftrain(frNo,:);
         imshow(tmp)
         imwrite(tmp, [])
        %         pose3D = gtd3p.Ftrain(frNo,:);
        %         NPose = normalize_pose(pose3D, CONF.skel3d);
        %         pose_matrix(frNo,:) = pose3D;
    end
    %     pose_matrix96 = [pose_matrix96; pose_matrix];
    pose2d_matrix = [pose2d_matrix;pose2D_activity];
    total = N_activity + total;
end
% pose_matrix = pose_matrix(1:g_frNo-1,:);size(pose_matrix)
% names = names(1:g_frNo-1);
% save('/home/tt/star/h80k/data/h80k_training_pose_name96.mat', 'pose_matrix96', 'names')
load([CONF.exp_dir 'h80k_training_pose_name.mat']);
save([CONF.exp_dir 'h80k_training_pose_name_2d3d.mat'], 'names', 'pose_matrix', 'pose2d_matrix')


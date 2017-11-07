close all;clc
directory = '../data/';
% addpath(genpath('/home/tt/star/human36m/code/'))
small_4000; % config file
% addpath(genpath('../human36m_code/'))
addpath('./visualization/')
%% load some files
activity= 'ActivitySpecific_01.mat';
rgb = matfile([CONF.exp_dir 'DenseFeatures' filesep 'RGB' filesep activity]);
gtpl = matfile([CONF.exp_dir 'DenseFeatures' filesep 'GTPL' filesep activity]);
gtfgm = matfile([CONF.exp_dir 'DenseFeatures' filesep 'GTFGM' filesep activity]);
gtd3p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep activity]);
gtd2p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD2P' filesep activity]);
%% show a frame

frno = 1;
figure;
pose_96 = gtd3p.Ftrain(frno,:);
pose_51 = normalize_pose(pose_96, CONF.skel3d);
pose_96_est = convert_joint51_96(pose_51);
pose2d = gtd2p.Ftrain(frno,:);
pose2d_r = reshape(pose2d,2,32);
im = cell2mat(rgb.Ftrain(frno,1));

subplot(221);imshow(im);
subplot(222);
skel= CONF.skel3d;
rb = H36MRenderBody(skel,'Style','sketch','ColormapType','left-right');
rb.render3D(pose_96);
% subplot(223); rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(pose_96_est);
% subplot(224);show2DPose(pose_51, CONF.skel2d); title('2d positions');
%%
pose2d = reshape(pose2d, 2, 32);
subplot(223);imshow(im);
sel_2dPose =  reshape(pose2d(ind_joint_2d), 2, 16);
hold on; plot(sel_2dPose(1,:), sel_2dPose(2,:), '*g')
% pose2d_rn = bsxfun(@minus,pose2d_r,pose2d_r(:,1));
%%
im_flip = flip(im, 2);
subplot(223);imshow(im_flip)
tmp = reshape(pose_51,3, 51/3);
joint_flip = tmp;
joint_flip(:,12:14) = tmp(:,15:17);  
joint_flip(:,15:17) = tmp(:,12:14); 
joint_flip(:,2:4) = tmp(:,5:7); 
joint_flip(:,5:7) = tmp(:,2:4);
joint_flip(1,:) = -joint_flip(1,:);
pose51_flip = reshape(joint_flip, 1, 51);
subplot(224);rb.render3D(convert_joint51_96(pose51_flip));


clc;close all;
addpath('/home/t Share/h80k/util');
ind_joint_2d = [1:8, 13:18, 25:28, 31:32, 35:40, 51:56];
CONF.exp_dir = '/home/tt/star/previous_code/h80k/data/';
small_4000;
load([CONF.exp_dir 'human36m_big.mat'])
%% load some files
rgb = matfile([CONF.exp_dir 'DenseFeatures' filesep 'RGB' filesep 'ActivitySpecific_01.mat']);
gtd3p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep 'ActivitySpecific_01.mat']);
gtd2p = matfile([CONF.exp_dir 'DenseFeatures' filesep 'GTD2P' filesep 'ActivitySpecific_01.mat']);

%
pose2D = gtd2p.Ftrain;
pose2D = pose2D(:,ind_joint_2d);
pose2D_ief = convert2IEF(pose2D);
pose2D_centered = bsxfun(@minus, pose2D_ief, pose2D_ief(:,7,:));
pose2D_cntr_vec = reshape(pose2D_centered, 32, size(pose2D_centered,3));
hdf5write('trn_pose2d.h5', '/train' , pose2D_cntr_vec);
%% show a frame
frno = 100;
figure;
im = cell2mat(rgb.Ftrain(frno,1));
pose3D = gtd3p.Ftrain(frno,:);
%
subplot(131);imshow(im);
subplot(132);plot_pose_stickmodel(pose2D_centered');axis equal; axis off;
subplot(133); rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(pose3D);

% close all;clc;
% clear all;
small_4000;load([CONF.exp_dir 'human36m_big.mat']);addpath('./util/')
% pose3d_matrix = [];pose2d_matrix = [];
% for ii = [1 2 4 13 15]
%     activity= sprintf('ActivitySpecific_%02d.mat', ii);
%     gtd2p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD2P' filesep activity]);
%     gtd3p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep activity]);
%     N_activity = size(gtd3p.Ftrain,1);
%     ii
%     val_index_act= zeros(N_activity, 1);
%     pose3D_activity = zeros(N_activity, 51);
%     names_act = cell(N_activity,1);
%     pose2D_activity = zeros(N_activity, 32);     
%     for frNo = 1:N_activity
%         pose3D = gtd3p.Ftrain(frNo,:);
%         NPose = normalize_pose(pose3D, CONF.skel3d, 'hip');
%         pose3D_activity(frNo,:) = NPose;     
%         tmp = gtd2p.Ftrain(frNo,:);
%         tmp = convert2IEF(tmp(ind_joint_2d)); 
%         pose2D_activity(frNo,:) = reshape(tmp, 1, 32);
%     end
%     pose2d_matrix = [pose2d_matrix;pose2D_activity];pose3d_matrix = [pose3d_matrix; pose3D_activity];
% end
% save([CONF.exp_dir 'h80k_trnValStanding.mat'], 'pose3d_matrix', 'pose2d_matrix')
load([CONF.exp_dir 'h80k_trnValStanding.mat'])

rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right');
Z = linkage(pose3d_matrix, 'ward','euclidean','savememory', 'on');
NC = 50;idx = cluster(Z, 'maxclust', NC);
 close all
no_pnts = zeros(1,NC);
for i=1:NC
    no_pnts(i) = length(find(idx==i));
end
 
n=0;
for i=1:16
    subplot(4,4,i)
    ind = find(idx == n*16+i);
    rb.render3D(convert_joint51_96(pose3d_matrix(ind(1),:)));title(num2str(no_pnts(i+n*16)))
end
 
n=1;figure;
for i=1:16
    subplot(4,4,i)
    ind = find(idx == n*16+i);
    rb.render3D(convert_joint51_96(pose3d_matrix(ind(1),:)));title(num2str(no_pnts(i+n*16)))
end

n=2;figure;
for i=1:NC-n*16
    subplot(4,4,i)
    ind = find(idx == n*16+i);
    rb.render3D(convert_joint51_96(pose3d_matrix(ind(1),:)));title(num2str(no_pnts(i+n*16)))
end

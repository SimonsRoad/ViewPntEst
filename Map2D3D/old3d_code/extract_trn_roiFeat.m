close all;clc;
clear all;
small_4000; % config file

load([CONF.exp_dir 'human36m_big.mat'])
addpath('./visualization/')
run(['/home/tt/star/matconvnet-1.0-beta18/matlab/vl_setupnn.m']);
% net = load([CONF.exp_dir, 'cnn_models/net-up8_8bin_fast.mat']);
net = load([CONF.exp_dir, 'cnn_models/net_8bins_full_lrn.mat']);


w = net.meta.normalization.imageSize(1);
avgrage = net.meta.normalization.averageImage;
% load([CONF.exp_dir '/training_only.mat']);
load([CONF.exp_dir '/training_only2.mat']);
% label = {'a_0', 'a_45', 'a_90', 'a_135', 'a_180', 'a_225', 'a_270', 'a_315'};
offset = 5;
d_feat = 9216;  %4096

for ii = 1:length(METADATA.file_names)
    activity= sprintf('ActivitySpecific_%02d.mat', ii);
    trn_ind = 1: METADATA.train_frame_count(ii);
    trn_ind(METADATA.val_indx{ii}) = [];
    %     gtd2p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD2P' filesep activity]);
    %     training_only{ii}.pose2d = gtd2p.Ftrain(trn_ind, :);
    pose2d = convert2IEF(training_only{ii}.pose2d(:,ind_joint_2d));
    %     p =training_only{ii}.pose2d;
    %     if isfield(validation{ii}, 'hogFeat')
    %         training_only{ii} = rmfield(training_only{ii}, 'hogFeat');
    %     end
    dirname = [CONF.exp_dir, 'train_only_activity/', num2str(ii), '/'];
    %     training_only{ii}.imagePath = dirname;
    no_frms = length(trn_ind);
    %     names = cell(1, no_frms);
    CNN_F_activity = zeros(no_frms, d_feat);
    cnn_orient = zeros(no_frms,1);
    pose51 = normalize_pose(training_only{ii}.pose96, skel, 'hip');
    pr = pose51(:,[43,45]);
    pl = pose51(:,[34,36]);
    rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
    orient = estimate_gt_orient(rotation);
    cnn_orient = zeros(no_frms,1);
    %     cnn_upBorient = zeros(no_frms,1);
    ii
    parfor i = 1:no_frms
        im = imread([dirname, num2str(i), '.jpg']);
        curr_pose = pose2d(:,[10:16],i);
        y_range = max(min(curr_pose(2,:))- 2*offset, 1):min(max(curr_pose(2,:))+ 2*offset, size(im,1));
        x_range = max(1, min(curr_pose(1,:))-2*offset):min(max(curr_pose(1,:))+ 2*offset, size(im,2));
        im_crop = im( round(y_range), round(x_range),:);
        
        im_ = single(imresize(im_crop, [w, w]));
        im_ = bsxfun(@minus,im_, reshape(avgrage,1,1,3));
        res = vl_simplenn(net, im_);
%         CNN_F_activity(i, :) = squeeze(res(18).x);
%         score = squeeze(gather(res(end).x));
%         [best_score, ind_best] = max(score);
        poolfeatures = res(16).x;
        CNN_F_activity(i, :) = poolfeatures(:);
        %         names{i} = [num2str(trn_ind(i)) '.jpg'];
        %         cnn_orient(i) = ind_best;
    end
    %     training_only{ii}.cnnFeat = CNN_F_activity;
    %     training_only{ii}.orient = orient;
    %     training_only{ii}.cnn_upBorient = cnn_upBorient;
    %     training_only{ii}.cnn_orient = cnn_orient;
    %     training_only{ii}.names = names;
    %     training_only{ii}.cnn_orient = cnn_orient;
    training_only{ii}.cnnFeat = CNN_F_activity;
end

save([CONF.exp_dir '/training_only2_roi.mat'], 'training_only'); disp(' training_only done :)')


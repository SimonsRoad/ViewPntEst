close all;clc;
clear all;
addpath('util')
small_4000;

addpath('./matFiles/')
load('IEF_val1.mat')
load([CONF.exp_dir 'human36m_big.mat'])
% run(['/home/tt/star//matconvnet-1.0-beta18/matlab/vl_setupnn.m']);
% net = load([CONF.exp_dir, 'cnn_models/net-up8_8bin_fast.mat']);
load(['/home/t Share/h80k/net-tanSynthAll30.mat']);
w = net.meta.normalization.imageSize(1);
avgrage = net.meta.normalization.rgbMean;

% load([CONF.exp_dir '/validation.mat']);
load([CONF.exp_dir '/validation2.mat'])
label = {'a_0', 'a_45', 'a_90', 'a_135', 'a_180', 'a_225', 'a_270', 'a_315'};
offset = 15;
ind_act = [1:3 6,9, 13, 15];
for aa = 1:length(ind_act)
    ii = ind_act(aa);
    val_ind = METADATA.val_indx{ii};
    activity= sprintf('ActivitySpecific_%02d.mat', ii);
    %     gtd2p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD2P' filesep activity]);
    %     validation{ii}.pose2d = gtd2p.Ftrain(val_ind, :);
    %     rgb = matfile([CONF.exp_dir 'DenseFeatures' filesep 'RGB' filesep activity]);
    %     imgs =  rgb.Ftrain(val_ind,1);
    if isfield(validation{ii}, 'hogFeat')
        validation{ii} = rmfield(validation{ii}, 'hogFeat');
    end
    %         validation{ii}.pose96 = pose(val_ind,:);
    pose2d_matrix = validation{ii}.pose2d(:,ind_joint_2d);
    pose2d = reshape(pose2d_matrix', 2, 16, size(pose2d_matrix,1));
    %     pose2d_IEF_val = IEF_val{ii};
    %     pose2d = reshape(pose2d_IEF_val', 2, 16, size(pose2d_IEF_val,1));
    %
    dirname = ['/validation_only/act_', num2str(ii), '/'];
    %     validation{ii}.imagePath = dirname;
    %     names = cell(1,no_frms);
    no_frms = length(val_ind);
    CNN_F_val = zeros(no_frms, 4096);
    ii
    pose51 = normalize_pose(validation{ii}.pose96, skel, 'hip');
    pr = pose51(:,[43,45]);
    pl = pose51(:,[34,36]);
    rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
    orient = estimate_gt_4orient(rotation);
    cnn_orient = zeros(no_frms,1);
    for i = 1:no_frms
        names{i} = [dirname, '/im1_', num2str(i) ,'.jpg'];
        im =  imread([CONF.exp_dir ,names{i}]);
        tmp = convert2IEF(pose2d_matrix(i,:));
        im = pad_cntr_img(im, tmp(:, 9));
        im_ = single(imresize(im, [w, w]));
        %         im_ = bsxfun(@minus,im_, reshape(avgrage,1,1,3));
        res = vl_simplenn(net, im_);
        score = squeeze(gather(res(end).x));
        [best_score, ind_best] = max(score);
        %         CNN_F_val(i, :) = squeeze(res(19).x);
%         figure;imshow(im);title(label{ind_best})
        cnn_orient(i) = ind_best;
    end
    validation{ii}.orient = orient;
    %     validation{ii}.cnnFeat = CNN_F_val;
    %     %     validation{ii}.cnnFeat_ub = CNN_F_val;
    validation{ii}.cnn_orient = cnn_orient;
end

save([CONF.exp_dir '/validation_actSpeNet.mat'], 'validation');disp('validation done :)')


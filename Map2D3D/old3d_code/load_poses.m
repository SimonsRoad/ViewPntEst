clc;close all;
% clear all;
small_4000; % config file
addpath('./visualization/');
% addpaths;
root_dir = '/home/tt/star/';
% run([root_dir, '/matconvnet-1.0-beta18/matlab/vl_setupnn.m']);
% model_path = ['./matconvnet-vgg-f_fullImage/'];
% net = load([model_path, 'net-deployed.mat']);
% w = net.meta.normalization.imageSize(1);
% avg_im = zeros(w,w,3);
% avgrage = net.meta.normalization.averageImage;
% avg_im(:,:,1) = avgrage(1)*ones(w,w);
% avg_im(:,:,2) = avgrage(2)*ones(w,w);
% avg_im(:,:,3) = avgrage(3)*ones(w,w);

% load('./matFiles/imdb_h80k.mat');
% index_train = find(images.set==1);
% N_train = length(index_train)
N =  length(images.name);
train_CNN_feats = zeros(N, 4096);
train_3dposes_96 = zeros(N, 96);
training = load('./matFiles/h80k_training_pose_name.mat');
pose_train= cell(15,1);
for i=1:15
    activity = sprintf('ActivitySpecific_%02d.mat', i);
    pose_train{i} = load([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep activity], 'Ftrain');
end
%
parfor frNo = 1:N
    name = images.name{frNo};
    split_ind = strfind(name, '_');
    if ~strcmp(name(12), '_')
        activity_no = str2double(name(14:split_ind(2)-1));
        img_no = str2double(name(split_ind(2)+1:end-4));
        target_pose = pose_train{activity_no}.Ftrain(img_no,:);
    else
        activity_no = str2double(name(15:split_ind(3)-1));
        img_no = str2double(name(split_ind(3)+1:end-4));
        target_pose = pose_train{activity_no}.Ftrain(img_no,:);
        target_pose(1:3:96) = -target_pose(1:3:96);
    end
    train_3dposes_96(frNo, :) = target_pose;
    %%
    %      im = imread([CONF.exp_dir ,'/train_clusters/',name]);
    %     figure;subplot(121);imshow(im)
    %     subplot(122);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(target_pose);
end

save( [CONF.exp_dir, '/train_3dposes_96.mat'], 'train_3dposes_96');


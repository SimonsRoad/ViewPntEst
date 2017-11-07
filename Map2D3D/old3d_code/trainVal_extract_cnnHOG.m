clc;close all;
clear all;
small_4000; % config file
root_dir = '/home/tt/star/';
run([root_dir, '/matconvnet-1.0-beta18/matlab/vl_setupnn.m']);
% model_path = ['./matconvnet-vgg-f_fullImage/'];
% net = load([model_path, 'net-deployed.mat']);
net = load('/home/tt/star/h80k/data/net-gray_standVSnot.mat');
w = net.meta.normalization.imageSize(1);
avg_im = zeros(w,w,3);
avgrage = net.meta.normalization.averageImage;
avg_im(:,:,1) = avgrage(1)*ones(w,w);
avg_im(:,:,2) = avgrage(2)*ones(w,w);
avg_im(:,:,3) = avgrage(3)*ones(w,w);

train_annot = load('./matFiles/imdb_h80k.mat');
names = train_annot.images.name;
N = length(names);
train_CNN_feats = zeros(N, 4096);
train_3dposes = zeros(N, 51);
training = load([CONF.exp_dir '/h80k_training_pose_name.mat']);
 load('./HOG/h80k_imdb.mat');
 standFlag = zeros(1,N);
    
for frNo = 1:N
    name = names{frNo};
    im = rgb2gray(imread([CONF.exp_dir, '/train_clusters/', name]));
    im_ = single(imresize(im, [w, w]));
    im_ = bsxfun(@minus,im_, avg_im);
    res = vl_simplenn(net, im_);
    scores = squeeze(gather(res(end).x));
    [bestScore, bestInd] = max(scores);
    standingFlag(frNo) = bestInd-1;
%     train_CNN_feats(frNo, :) = squeeze(res(18).x);
%     %% read pose
%     tmp = ['../training_imgs', name(11:end)];
%     index = find(strcmp(training.names ,tmp));
%     if ~isempty(index)
%         target_pose = training.pose_matrix(index,:);
%     else
%         tmp = ['../training_imgs/', name(13:end)];
%         index = find(strcmp(training.names ,tmp));
%         target_pose = training.pose_matrix(index,:);
%         target_pose(1:3:51) = -target_pose(1:3:51);
%     end
%     train_3dposes(frNo, :) = target_pose;
end
train_annot.images.stand = standingFlag;
% train_annot.images.pose51 = train_3dposes;
% train_annot.images.cnnFeat = train_CNN_feats;
% train_annot.images.hogFeat = hog_feats;
save( [CONF.exp_dir, 'train_annot_grayStand.mat'], 'train_annot');


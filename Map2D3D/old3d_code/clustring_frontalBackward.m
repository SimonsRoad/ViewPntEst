clc;close all;
clear all;
addpaths;
addpath('/home/t Share/human36m_code/utils/')
small_4000; % config file
load([CONF.exp_dir 'h80k_training_pose_name.mat']);
load([CONF.exp_dir 'Z_ward_max_leg_neck_feet.mat']);
id_standing = find(idx == 3);
name_standing = names(id_standing);
pose_standing = pose_matrix(id_standing,:);
dst_path = '/home/tt/star/h80k/data/train_cluster_FBRL/';

parfor i=1:1:length(name_standing)
    name = name_standing{i};
    src_path = [CONF.exp_dir name(3:end)];
    im =  (imread(src_path));
    joints = reshape(pose_standing(i,:), 3, 17);
    ratio = abs(joints(1,2)/ joints(3,2));
    %         if strcmp(name(18:end), 'im1_42.jpg')
    bending_metric =  max(abs(joints(1,11)/joints(2,11)) , abs(joints(3,11)/joints(2,11)));
    
    if  (bending_metric) < 0.9
        if ratio > 0.8
            if joints(1,15) < joints(1,12)  % frontal
                copyfile(src_path, [dst_path, 'frontal/',name(18:end)])
            else
                copyfile(src_path, [dst_path, 'backward/',name(18:end)])
            end
        else
            if joints(3,12) >  joints(3,15) % right hand
                copyfile(src_path, [dst_path, 'right/',name(18:end)])
            else
                %                 im = flipdim(im,2); imwrite(im, [dst_path, 'right/',name(18:end)])
                copyfile(src_path, [dst_path, 'left/',name(18:end)])%
            end
        end
    end
end
% end

length(name_standing)
% im1 = imread('/home/tt/star/h80k/data/train_cluster_FBRL/left/im3_283.jpg');figure;subplot(221);imshow(im1); subplot(222);imshow(im1(1:round(1/2*h),:,:));subplot(223);imshow(im1(round(0.5*h):end,:,:))


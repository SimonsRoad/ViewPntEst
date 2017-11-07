clc;close all;
clear all;
% addpath('/home/t Share/human36m_code/utils/')
small_4000; % config file
load([CONF.exp_dir 'h80k_training_pose_name_2d3d.mat']);
load([CONF.exp_dir 'Z_ward_max_leg_neck_feet.mat']);
id_standing = find(idx == 3);
name_standing = names(id_standing);
pose_standing = pose_matrix(id_standing,:);
pose2d = convert2IEF(pose2d_matrix(id_standing,:));
dst_path = '/home/tt/star/h80k/data/trn_clust_crop_8Bin/';
pr = pose_standing(:,[43,45]);
ph = pose_standing(:,[31,33]);
pl = pose_standing(:,[34,36]);
rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
offset=10;
w = 124;
W = 224;
pose2d_avg = zeros(4, 16);

for i = 1:1:length(name_standing)
    %     ind = find(175 <=rotation & rotation<180);
    name = name_standing{i};
    src_path = [CONF.exp_dir name(3:end)];
    im =  (imread(src_path));
    joints = reshape(pose_standing(i,:), 3, 17);
    bending_metric =  max(abs(joints(1,11)/joints(2,11)) , abs(joints(3,11)/joints(2,11)));
    if  (bending_metric) > 0.9
        continue;
    end
    curr_pose = pose2d(:,[1:10,12:15],i);
    y_range = max(min(curr_pose(2,:))- 15,0):min(max(curr_pose(2,:))+ 2*offset, size(im,1));
    x_range = min(curr_pose(1,:))-offset:min(max(curr_pose(1,:))+ 2*offset, size(im,2));
    im_crop = im( round(y_range), round(x_range),:);
    im_crop_resize = imresize(im_crop, [224, w]);
    padd_img = im_crop_resize;
    padd_x = (W-w)/2;
    padd_img = padarray(padd_img, [0 padd_x], 'pre');
    padd_img = padarray(padd_img, [0 padd_x], 'post');
    im_flip = flip(padd_img,2);
%                 figure;
%                 subplot(221);imshow(im);title(['rot= ', num2str(rotation(i))])
%                 subplot(222); imshow(im_crop)
%                 subplot(223); imshow(im_crop_resize)
%                 subplot(224); imshow(padd_img)
    
    if -5 <= rotation(i) && rotation(i)<= 5
        imwrite(padd_img, [dst_path, 'a_0/',name(18:end)])
        imwrite(im_flip, [dst_path, 'a_0/_', name(18:end)])
        pose2d_avg(i,:) = pose2d_avg(i,:)+ 
   
        
    elseif 85 <= rotation(i) && rotation(i) <= 95
        imwrite(padd_img, [dst_path, 'a_90/',name(18:end)])
        imwrite(im_flip, [dst_path, 'a_270/_', name(18:end)])

        
            
    elseif  175 <= rotation(i) || rotation(i)<= -175
        imwrite(padd_img, [dst_path, 'a_180/',name(18:end)])
        imwrite(im_flip, [dst_path, 'a_180/_', name(18:end)])

        
         
    elseif -95 <= rotation(i) && rotation(i)< -85
        imwrite(padd_img, [dst_path, 'a_270/',name(18:end)])
          imwrite(im_flip, [dst_path, 'a_90/_', name(18:end)])
        
   end
end




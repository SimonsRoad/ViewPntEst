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
pose2d_n = bsxfun(@minus, pose2d, pose2d(:,7,:));
pose2d_flip = flip_2djoint_IEF(pose2d_n);
pose3d_flip = flip_3djoint(pose_standing);
% pose2d_flip = flip_2djoint_IEF(squeeze(reshape(pose2d,1,32, size(pose2d,3))));
dst_path = '/home/tt/star/h80k/data/';
pr = pose_standing(:,[43,45]);
ph = pose_standing(:,[31,33]);
pl = pose_standing(:,[34,36]);
rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;

% rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right');
names_bin = cell(1, 9);
offset = 15;
W = 224;
pose2d_upB = zeros(3000, 12);
c1 = 1;

parfor i = 1:1:length(name_standing)
    name = name_standing{i};
    src_path = [CONF.exp_dir name(3:end)];
    im =  (imread(src_path));
    joints = reshape(pose_standing(i,:), 3, 17);
    bending_metric =  max(abs(joints(1,11)/joints(2,11)) , abs(joints(3,11)/joints(2,11)));
    if  (bending_metric) > 0.9
        continue;
    end
    %     curr_pose = pose2d(:,[10:16],i);
    %     y_range = max(min(curr_pose(2,:))- 2*offset, 1):min(max(curr_pose(2,:))+ 2*offset, size(im,1));
    %     x_range = max(1, min(curr_pose(1,:))-2*offset):min(max(curr_pose(1,:))+ 2*offset, size(im,2));
    %     im_crop = im( round(y_range), round(x_range),:);
    im_crop = im(round(0.6*size(im,1)):end,:, :);
    im_crop_resize = imresize(im_crop, [W, W]);
    %     im_crop_resize = im_crop_resize;
    %     padd_x = (W-w)/2;
    %     im_crop_resize = padarray(im_crop_resize, [0 padd_x], 'pre');
    %     im_crop_resize = padarray(im_crop_resize, [0 padd_x], 'post');
    im_flip = flip(im_crop_resize,2);
    
    if -5 <= rotation(i) && rotation(i)<= 5
        name_im = ['/trn_lowerB_8bins/', 'a_0/',name(18:end)];
        name_flip = ['/trn_lowerB_8bins/', 'a_0/_',name(18:end)];
        
        imwrite(im_crop_resize, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        
        %         names_bin{c1} = name_im;
        %         pose2d_upB(c1,:) = reshape(pose2d_n(:,[11:16],i),1, 12);
        %         names_bin{c1+1} = name_flip;
        %         pose2d_upB(c1+1,:) = reshape(pose2d_flip(:,[11:16],i),1, 12);
        %                er_hand = calc_err2d(reshape(pose2d_n(:,[11:16],i),1, 12), reshape(pose2d_flip(:,[11:16],i),1, 12));
%         er_hand = JointError(  pose_standing(i,[37:42,46:51]), pose3d_flip(i,[37:42,46:51]) );
%         figure;
%         subplot(231);imshow(im);title(['rot= ', num2str(rotation(i)), ', er_hand = ', num2str(er_hand)])
%         subplot(232); plot_pose_stickmodel(pose2d(:,:,i)');
%         subplot(233);rb.render3D(convert_joint51_96(pose3d_flip(i,:)));
%         subplot(234); imshow(im_flip)
%         subplot(235); plot_pose_stickmodel(pose2d_flip(:,:,i)');
%         subplot(236);rb.render3D(convert_joint51_96(pose_standing(i,:) ));
%         c1 = c1 +2;
        
    elseif 40 <= rotation(i) && rotation(i)<= 50
        name_im = ['/trn_lowerB_8bins/', 'a_45/',name(18:end)];
        name_flip = ['/trn_lowerB_8bins/', 'a_315/_',name(18:end)];
        
        imwrite(im_crop_resize, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        
        %         names_bin{c2} = name_im;
        %         pose2d_upB(c2,:) = reshape(pose2d_n(:,[11:16],i),1, 12);
        %         names_bin{c2+1} = name_flip;
        %         pose2d_upB(c2+1,:) = reshape(pose2d_flip(:,[11:16],i),1, 12);
        %         c2 = c2 +2;
        
        
    elseif 80 <= rotation(i) && rotation(i) <= 100
        name_im = ['/trn_lowerB_8bins/', 'a_90/',name(18:end)];
        name_flip = ['/trn_lowerB_8bins/', 'a_270/_' , name(18:end)];
        
        imwrite(im_crop_resize, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        
        
    elseif 130 <= rotation(i) && rotation(i)<= 140
        name_im = ['/trn_lowerB_8bins/', 'a_135/',name(18:end)];
        name_flip = ['/trn_lowerB_8bins/', 'a_225/_' , name(18:end)];
        
        imwrite(im_crop_resize, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        
        
    elseif  175 <= rotation(i) || rotation(i)<= -175
        name_im = ['/trn_lowerB_8bins/', 'a_180/',name(18:end)];
        name_flip = ['/trn_lowerB_8bins/', 'a_180/_' , name(18:end)];
        
        imwrite(im_crop_resize, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        
        
    elseif -140 <= rotation(i) && rotation(i)< -128
        name_im = ['/trn_lowerB_8bins/', 'a_225/',name(18:end)];
        name_flip = ['/trn_lowerB_8bins/', 'a_135/_' , name(18:end)];
        imwrite(im_crop_resize, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        
        
    elseif -100 <= rotation(i) && rotation(i)< -80
        name_im = ['/trn_lowerB_8bins/', 'a_270/',name(18:end)];
        name_flip = ['/trn_lowerB_8bins/', 'a_90/_' , name(18:end)];
        imwrite(im_crop_resize, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        
        
    elseif -55 <= rotation(i) && rotation(i)< -35
        
        name_im = ['/trn_lowerB_8bins/', 'a_315/',name(18:end)];
        name_flip = ['/trn_lowerB_8bins/', 'a_45/_' , name(18:end)];
        
        imwrite(im_crop_resize, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
    end
end




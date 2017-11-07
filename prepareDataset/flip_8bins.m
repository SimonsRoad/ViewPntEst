clc;close all;
clear all;
addpath('/home/t Share/human36m_code/utils/')
small_4000; % config file
load([CONF.exp_dir 'h80k_training_pose_name.mat']);
load([CONF.exp_dir 'Z_ward_max_leg_neck_feet.mat']);
id_standing = find(idx == 3);
name_standing = names(id_standing);
pose_standing = pose_matrix(id_standing,:);
dst_path = '/home/tt/star/h80k/data/trn_8bin_fullBody/';
pr = pose_standing(:,[43,45]);
pl = pose_standing(:,[34,36]);

rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
% indexC = strfind(name_standing, '../training_imgs/im1_2546.jpg');
% index= find(not(cellfun('isempty', indexC)));
show_im = 0;

parfor i = 1:1:length(name_standing)
    %     ind = find(175 <=rotation & rotation<180);
    name = name_standing{i};
    src_path = [CONF.exp_dir name(3:end)];
    im =  (imread(src_path));
    %     im = im(1:round(size(im,1)/2) ,:,:);
    im_flip = flip(im,2);
    % figure; imshow(im);title(['rot= ', num2str(rotation(i))])
    joints = reshape(pose_standing(i,:), 3, 17);
    bending_metric =  max(abs(joints(1,11)/joints(2,11)) , abs(joints(3,11)/joints(2,11)));
    if  (bending_metric) > 0.9
        continue;
    end
    
    if -5 <= rotation(i) && rotation(i)<= 5
        %         copyfile(src_path, [dst_path, 'a_0/',name(18:end)])
        imwrite(im, [dst_path, 'a_0/', name(18:end)]);
        if show_im
            figure; subplot(121);imshow(im); subplot(122);imshow(im_flip)
        end
        imwrite(im_flip, [dst_path, 'a_0/_', name(18:end)])
        
%     elseif 40 <= rotation(i) && rotation(i)<= 50
%         %         copyfile(src_path, [dst_path, 'a_45/',name(18:end)])
%         imwrite(im, [dst_path, 'a_45/',name(18:end)]);
%         imwrite(im_flip, [dst_path, 'a_315/_', name(18:end)])
%         
%     elseif 80 <= rotation(i) && rotation(i) <= 100
%         %         copyfile(src_path, [dst_path, 'a_90/',name(18:end)])
%         imwrite(im, [dst_path, 'a_90/',name(18:end)])
%         imwrite(im_flip, [dst_path, 'a_270/_', name(18:end)])
        
        
%     elseif 130 <= rotation(i) && rotation(i)<= 140
%         %         copyfile(src_path, [dst_path, 'a_135/',name(18:end)])
%         imwrite(im, [dst_path, 'a_135/',name(18:end)])
%         imwrite(im_flip, [dst_path, 'a_225/_', name(18:end)])
%         
%     elseif  175 <= rotation(i) || rotation(i)<= -175
%         %         copyfile(src_path, [dst_path, 'a_180/',name(18:end)])
%         imwrite(im, [dst_path, 'a_180/',name(18:end)])
%         imwrite(im_flip, [dst_path, 'a_180/_', name(18:end)])
%         
%     elseif -140 <= rotation(i) && rotation(i)< -128
%         %         copyfile(src_path, [dst_path, 'a_225/',name(18:end)]);
%         imwrite(im, [dst_path, 'a_225/',name(18:end)]);
%         imwrite(im_flip, [dst_path, 'a_135/_', name(18:end)])
        
    elseif -100 <= rotation(i) && rotation(i)< -88
        imwrite(im, [dst_path, 'a_270/',name(18:end)])
        imwrite(im_flip, [dst_path, 'a_90/_', name(18:end)])
        
%     elseif -68 <= rotation(i) && rotation(i)<= -40
%         imwrite(im, [dst_path, 'a_315/',name(18:end)])
%         imwrite(im_flip, [dst_path, 'a_45/_', name(18:end)])
    end
    
end




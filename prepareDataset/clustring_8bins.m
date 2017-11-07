% clc;close all;
clear all;
% addpath('/home/t Share/human36m_code/utils/')
small_4000; % config file
load([CONF.exp_dir 'h80k_training_pose_name.mat']);
load([CONF.exp_dir 'Z_ward_max_leg_neck_feet.mat']);
id_standing = find(idx == 3);
name_standing = names(id_standing);
pose_standing = pose_matrix(id_standing,:);
dst_path = '/home/tt/star/h80k/data/train_cluster_8Bin_full/';
pr = pose_standing(:,[43,45]);
ph = pose_standing(:,[31,33]);
pl = pose_standing(:,[34,36]);



rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
counter = 0;

for i = 1:1:length(name_standing)
    %     ind = find(175 <=rotation & rotation<180);
    name = name_standing{i};
    src_path = [CONF.exp_dir name(3:end)];
    im =  (imread(src_path));
    joints = reshape(pose_standing(i,:), 3, 17);
    bending_metric =  max(abs(joints(1,11)/joints(2,11)) , abs(joints(3,11)/joints(2,11)));
    if  (bending_metric) > 0.9
                continue;
%         figure; imshow(im);title(['rot= ', num2str(rotation(i))])
%         counter = counter+1;
    end
        if -5 <= rotation(i) && rotation(i)<= 5
            copyfile(src_path, [dst_path, 'a_0/',name(18:end)])
    
        elseif 35 <= rotation(i) && rotation(i)<= 55
            copyfile(src_path, [dst_path, 'a_45/',name(18:end)])
    
        elseif 80 <= rotation(i) && rotation(i) <= 100
            copyfile(src_path, [dst_path, 'a_90/',name(18:end)])
    
        elseif 130 <= rotation(i) && rotation(i)<= 140
            copyfile(src_path, [dst_path, 'a_135/',name(18:end)])
    
        elseif  170 <= rotation(i) || rotation(i)<= -170
            copyfile(src_path, [dst_path, 'a_180/',name(18:end)])
    
        elseif -140 <= rotation(i) && rotation(i)< -130
            copyfile(src_path, [dst_path, 'a_225/',name(18:end)])
    
        elseif -100 <= rotation(i) && rotation(i)< -80
            copyfile(src_path, [dst_path, 'a_270/',name(18:end)])
    
        elseif -55 <= rotation(i) && rotation(i)< -35
            copyfile(src_path, [dst_path, 'a_315/',name(18:end)])
        end
    
end




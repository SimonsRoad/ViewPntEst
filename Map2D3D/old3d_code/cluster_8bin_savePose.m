clc;close all;clear all;
addpath('/home/t Share/human36m_code/utils/')
small_4000; % config file
load([CONF.exp_dir 'h80k_training_pose_name.mat']);
load([CONF.exp_dir 'Z_ward_max_leg_neck_feet.mat']);
id_standing = find(idx == 3);
name_standing = names(id_standing);
pose_standing = pose_matrix(id_standing,:);
pose3d_flip = flip_3djoint(pose_standing);
dst_path = '/home/tt/star/h80k/data/';
pr = pose_standing(:,[43,45]);
pl = pose_standing(:,[34,36]);
rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
show_im = 0;
counter = ones(8,1);
names_all = cell(8, 1);
pose_all = cell(8, 1);
for i=1:8
    names_all{i}= cell(3500,1);
    pose_all{i} = zeros(3500, 51);
end
tic
for i = 1:1:length(name_standing)
    name = name_standing{i};
    src_path = [CONF.exp_dir name(3:end)];
    im =  (imread(src_path));
    im_flip = flip(im,2);
    if strcmp('im6_862.jpg',name(18:end))
        name(18:end)
    end
    joints = reshape(pose_standing(i,:), 3, 17);
    
    %     a1 = atan(abs(joints(3,11)/joints(2,11)))*190/pi;
    %     a2 = atan(abs(joints(1,11)/joints(2,11)))*190/pi;
    %     if a1>30 || a2>30
    %         [a1, a2]
    %         figure; imshow(im);title(['rot= ', num2str(rotation(i))]);title(['a1 = ', num2str(a1), ', a2 = ', num2str(a2)])
    %     end
    bending_metric =  max(abs(joints(1,11)/joints(2,11)) , abs(joints(3,11)/joints(2,11)));
    if  (bending_metric) > 1
        continue;
    end
    
    if -5 <= rotation(i) && rotation(i)<= 5
        name_im = ['/trn_full_8bin_3dpose/', 'a_0/',name(18:end)];
        name_flip = ['/trn_full_8bin_3dpose/', 'a_0/_',name(18:end)];
        
        imwrite(im, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        c = 1;
        pose_all{c}(counter(c),:) = pose_standing(i,:);
        pose_all{c}(counter(c)+1, :) = pose3d_flip(i,:);
        
        names_all{c}{counter(c)}= name_im;
        names_all{c}{counter(c)+1}= name_flip;
        counter(c) = counter(c)+2;
        
        
    elseif 40 <= rotation(i) && rotation(i)<= 50
        name_im = ['/trn_full_8bin_3dpose/', 'a_45/',name(18:end)];
        name_flip = ['/trn_full_8bin_3dpose/', 'a_315/_',name(18:end)];
        
        imwrite(im, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        c = 2;
        pose_all{c}(counter(c),:) = pose_standing(i,:);
        names_all{c}{counter(c)}= name_im;
        counter(c) = counter(c)+ 1;
        c = 8;
        names_all{c}{counter(c)}= name_flip;
        pose_all{c}(counter(c),:) = pose3d_flip(i,:);
        counter(c) = counter(c)+ 1;
        
    elseif 80 <= rotation(i) && rotation(i) <= 100
        name_im = ['/trn_full_8bin_3dpose/', 'a_90/',name(18:end)];
        name_flip = ['/trn_full_8bin_3dpose/', 'a_270/_' , name(18:end)];
        
        imwrite(im, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        c = 3;
        pose_all{c}(counter(c),:) = pose_standing(i,:);
        names_all{c}{counter(c)}= name_im;
        counter(c) = counter(c)+ 1;
        c = 7;
        pose_all{c}(counter(c)+1, :) = pose3d_flip(i,:);
        names_all{c}{counter(c)+1}= name_flip;
        counter(c) = counter(c)+1;
        
        
    elseif 130 <= rotation(i) && rotation(i)<= 140
        name_im = ['/trn_full_8bin_3dpose/', 'a_135/',name(18:end)];
        name_flip = ['/trn_full_8bin_3dpose/', 'a_225/_' , name(18:end)];
        
        imwrite(im, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        c = 4;
        pose_all{c}(counter(c),:) = pose_standing(i,:);
        names_all{c}{counter(c)}= name_im;
        counter(c) = counter(c)+ 1;
        
        c = 6;
        pose_all{c}(counter(c)+1, :) = pose3d_flip(i,:);
        names_all{c}{counter(c)+1}= name_flip;
        counter(c) = counter(c) + 1;
        
    elseif  175 <= rotation(i) || rotation(i)<= -175
        name_im = ['/trn_full_8bin_3dpose/', 'a_180/',name(18:end)];
        name_flip = ['/trn_full_8bin_3dpose/', 'a_180/_' , name(18:end)];
        
        imwrite(im, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        c = 5;
        pose_all{c}(counter(c),:) = pose_standing(i,:);
        names_all{c}{counter(c)}= name_im;
        counter(c) = counter(c)+ 1;
        
        pose_all{c}(counter(c)+1, :) = pose3d_flip(i,:);
        names_all{c}{counter(c)+1}= name_flip;
        counter(c) = counter(c)+ 1;
        
    elseif -140 <= rotation(i) && rotation(i)< -128
        name_im = ['/trn_full_8bin_3dpose/', 'a_225/',name(18:end)];
        name_flip = ['/trn_full_8bin_3dpose/', 'a_135/_' , name(18:end)];
        imwrite(im, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        c = 6;
        pose_all{c}(counter(c),:) = pose_standing(i,:);
        names_all{c}{counter(c)}= name_im;
        counter(c) = counter(c)+ 1;
        
        c = 4;
        pose_all{c}(counter(c)+1, :) = pose3d_flip(i,:);
        names_all{c}{counter(c)+1}= name_flip;
        counter(c) = counter(c) + 1;
        
    elseif -100 <= rotation(i) && rotation(i)< -88
        name_im = ['/trn_full_8bin_3dpose/', 'a_270/',name(18:end)];
        name_flip = ['/trn_full_8bin_3dpose/', 'a_90/_' , name(18:end)];
        imwrite(im, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        c = 7;
        pose_all{c}(counter(c),:) = pose_standing(i,:);
        names_all{c}{counter(c)}= name_im;
        counter(c) = counter(c)+ 1;
        c = 3;
        
        pose_all{c}(counter(c)+1, :) = pose3d_flip(i,:);
        names_all{c}{counter(c)+1}= name_flip;
        counter(c) = counter(c)+ 1;
        
        
    elseif -68 <= rotation(i) && rotation(i)<= -40
        name_im = ['/trn_full_8bin_3dpose/', 'a_315/',name(18:end)];
        name_flip = ['/trn_full_8bin_3dpose/', 'a_45/_' , name(18:end)];
        
        imwrite(im, [dst_path, name_im])
        imwrite(im_flip, [dst_path, name_flip])
        c = 8;
        pose_all{c}(counter(c),:) = pose_standing(i,:);
        names_all{c}{counter(c)}= name_im;
        counter(c) = counter(c)+ 1;
        c = 2;
        
        names_all{c}{counter(c)+1} = name_flip;
        pose_all{c}(counter(c)+1, :) = pose3d_flip(i,:);
        counter(c) = counter(c)+ 1;
        
    end
end

for c=1:8
    pose_all{c}(counter(c):end,:)=[];
    names_all{c}(counter(c):end) = [];
    counter(c) = counter(c)-1;
end
counter'
annot = struct;
annot.names_all = names_all;
annot.pose_all = pose_all;
annot.counter = counter;
save('cluster_8bin_pose.mat', '-struct', 'annot')



clc;close all;
clear all;
addpath('./util/');addpath('./matFiles/')
addpath('/home/t Share/human36m_code/utils/')
small_4000; % config file
load([CONF.exp_dir 'h80k_trnVal_allAct_crop_NameP23.mat']);
act1_val = load([CONF.exp_dir 'h80k_val_act1_crop_NameP23.mat'])
% load(['./trn_only_Z_ward_max_leg_neck_feet.mat'])
% load([CONF.exp_dir 'h80k_training_pose_name.mat']);
load([CONF.exp_dir 'Z_ward_max_leg_neck_feet.mat']);
id_standing = find(idx == 3);
name_standing = names(id_standing);
val_index = val_index(id_standing);
pose_standing = pose_matrix(id_standing,:);
dst_path = '/home/tt/star/h80k/data/bins_trn_subjSep/';
val_dst_path = '/home/tt/star/h80k/data/bins_val_act1/';
pr = pose_standing(:,[43,45]);
pl = pose_standing(:,[34,36]);

rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
% indexC = strfind(name_standing, '../training_imgs/im1_2546.jpg');
% index= find(not(cellfun('isempty', indexC)));
show_im = 0;
m = length(act1_val.names);
act1_name = cell(m,1);
 for i=1:m
     act1_name(i) = cellstr(['../training_imgs/', act1_val.names{i}]);
 end

% name_trnVal_excpAct1 = setdiff(name_standing, act1_name);
 
parfor i = 1:1:length(name_standing)
    
    name = name_standing{i};
    src_path = [CONF.exp_dir name(3:end)];
    im =  (imread(src_path));
%     im = im(1:round(size(im,1)/2) ,:,:);
    im_flip = flip(im,2);
    %     figure;
    %     subplot(121); imshow(im);title(['rot= ', num2str(rotation(i))])
    %     subplot(122); rb.render3D(  convert_joint51_96( val_pose51(i,:) ))
    joints = reshape(pose_standing(i,:), 3, 17);
    bending_metric =  max(abs(joints(1,11)/joints(2,11)) , abs(joints(3,11)/joints(2,11)));
    if  (bending_metric) > 0.9
        continue;
    end

        ind_act1 = findName(name_standing{i}, act1_name);
    if ~isempty(ind_act1)
        val_index = 1;
    else
        val_index = 0;
    end
    
    if -5 <= rotation(i) && rotation(i)<= 5
        if val_index
            imwrite(im, [val_dst_path, 'a_0/', name(18:end)]);
            imwrite(im_flip, [val_dst_path, 'a_0/_', name(18:end)])
        else
            imwrite(im, [dst_path, 'a_0/', name(18:end)]);
            imwrite(im_flip, [dst_path, 'a_0/_', name(18:end)])
        end
        
    elseif 40 <= rotation(i) && rotation(i)<= 50
        
        if val_index
            imwrite(im, [val_dst_path, 'a_45/', name(18:end)]);
            imwrite(im_flip, [val_dst_path, 'a_315/_', name(18:end)])
        else
            imwrite(im, [dst_path, 'a_45/', name(18:end)]);
            imwrite(im_flip, [dst_path, 'a_315/_', name(18:end)])
        end
        
        
        
        
    elseif 75 <= rotation(i) && rotation(i) <= 85
        if val_index
            imwrite(im, [val_dst_path, 'a_90/',name(18:end)])
            imwrite(im_flip, [val_dst_path, 'a_270/_', name(18:end)])
        else
            imwrite(im, [dst_path, 'a_90/',name(18:end)])
            imwrite(im_flip, [dst_path, 'a_270/_', name(18:end)])
        end
        
    elseif 130 <= rotation(i) && rotation(i)<= 140
        if val_index
            imwrite(im, [val_dst_path, 'a_135/',name(18:end)])
            imwrite(im_flip, [val_dst_path, 'a_225/_', name(18:end)])
        else
            imwrite(im, [dst_path, 'a_135/',name(18:end)])
            imwrite(im_flip, [dst_path, 'a_225/_', name(18:end)])
        end
        
    elseif  175 <= rotation(i) || rotation(i)<= -175
        if val_index
            imwrite(im, [val_dst_path, 'a_180/',name(18:end)])
            imwrite(im_flip, [val_dst_path, 'a_180/_', name(18:end)])
        else
            imwrite(im, [dst_path, 'a_180/',name(18:end)])
            imwrite(im_flip, [dst_path, 'a_180/_', name(18:end)])
        end
        
    elseif -150 <= rotation(i) && rotation(i)< -135
        if val_index
            imwrite(im, [val_dst_path, 'a_225/',name(18:end)]);
            imwrite(im_flip, [val_dst_path, 'a_135/_', name(18:end)])
        else
            imwrite(im, [dst_path, 'a_225/',name(18:end)]);
            imwrite(im_flip, [dst_path, 'a_135/_', name(18:end)])
        end
        
    elseif -85 <= rotation(i) && rotation(i)< -75
        if val_index
            imwrite(im, [val_dst_path, 'a_270/',name(18:end)])
            imwrite(im_flip, [val_dst_path, 'a_90/_', name(18:end)])
        else
            imwrite(im, [dst_path, 'a_270/',name(18:end)])
            imwrite(im_flip, [dst_path, 'a_90/_', name(18:end)])
        end
        
    elseif -50 <= rotation(i) && rotation(i)<= -40
        if val_index
            imwrite(im, [val_dst_path, 'a_315/',name(18:end)])
            imwrite(im_flip, [val_dst_path, 'a_45/_', name(18:end)])
        else
            imwrite(im, [dst_path, 'a_315/',name(18:end)])
            imwrite(im_flip, [dst_path, 'a_45/_', name(18:end)])
        end
    end
    
end




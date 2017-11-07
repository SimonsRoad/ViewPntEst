close all;clc;clear all;
addpath('util/')
small_4000; % config file
pose3D_pre = zeros(1, 51);
load([CONF.exp_dir 'human36m_big.mat'])

%% load some files
% N_trn = sum(METADATA.train_frame_count)
val_index = [];
imgs = cell(1,15);
names = cell(1,15);

p2dAct =  cell(1,15);p3dAct =  cell(1,15);
names_all =[];
pose3d_matrix = [];
pose2d_matrix = [];
val = 0
% ii = [1,2,13,15]   standing activities
for ii = [1:15]
    activity= sprintf('ActivitySpecific_%02d.mat', ii);
    rgb = matfile([CONF.exp_dir 'DenseFeatures' filesep 'RGB' filesep activity]);rgb = rgb.Ftrain;
    gtd2p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD2P' filesep activity]);
    gtd3p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep activity]);
 
    p2dAct{ii} = gtd2p.Ftrain;
    p3dAct{ii} =gtd3p.Ftrain;
    trn_ind = 1: METADATA.train_frame_count(ii);
    trn_ind(METADATA.val_indx{ii}) = [];
   
    fileh80k_allAct2d3d = sprintf('/home/t Share/h80k/rnn/data/80k_trn2d3dNameOrient_all.h5');
    ind = trn_ind;
    dstFolder = '/imgs_trn';
    if val
        dstFolder = '/imgs_val';
        ind = METADATA.val_indx{ii};
        fileh80k_allAct2d3d = sprintf('/home/t Share/h80k/rnn/data/80k_val2d3dNameOrient_all.h5');
    end
    no_frms = length(ind);
    W=224;
    pose3d_matrix = zeros(no_frms, 51);
    names_act = zeros(no_frms,1);
    pose2d_matrix = zeros(no_frms, 32); 
    
    for frNo = 1:no_frms  
        im = cell2mat(rgb(ind(frNo),1));
        w = size(im,2);
%         padd_img = im;
%         padd_x = round((W-w)/2);
%         if(padd_x>2)
%             padd_img = padarray(padd_img, [0 padd_x], 'pre');
%             padd_img = padarray(padd_img , [0 padd_x], 'post');
%         end
%         im_resize = imresize(padd_img, [W, W]);
        im_name = sprintf('%s/act_%d/%d.png',dstFolder, ii, frNo);
        imwrite(im, [ CONF.exp_dir  im_name])
%         imshow(padd_img)
        NPose = normalize_pose(p3dAct{ii}(ind(frNo),:), CONF.skel3d, 'hip');
        pose3d_matrix(frNo,:) = NPose;
        %         names_act{frNo} = im_name;
        names_act(frNo) = frNo;
        tmp = p2dAct{ii}(ind(frNo),:);
        p2 = convert2IEF(tmp(ind_joint_2d));
        tmp = bsxfun(@minus, p2, p2(:,7));
        pose2d_matrix(frNo,:) = reshape(tmp, 1, 32);
        %         figure;subplot(121);imshow(im)
        %         %         im = pad_cntr_img(im, tmp(:, 9));
        %         subplot(122); plot_pose_stickmodel([tmp']);
        
        %         imwrite(im, [CONF.exp_dir im_name(3:end)])
        %         fprintf(file_trnNames, im_name);
        %         fprintf(file_trnNames,'\n');
    end
    %     fclose(file_trnNames);
    %     %     pose_matrix96 = [pose_matrix96; pose_matrix];
    %     %     pose2d_matrix = [pose2d_matrix;pose2d_matrix];
    %     %     pose_matrix = [pose_matrix; pose3d_matrix];
    %     %     names = [names;names_act];
    %     %     pose2D{ii} = pose2d_matrix;
    %     %     pose3D{ii} = pose3d_matrix;
    %     %     names{ii} = names_act;
    %
    %     %     pose2d_matrix = [pose2d_matrix; pose2d_matrix];
    %     %     pose3d_matrix = [pose3d_matrix; pose3d_matrix];
    %     %     names_all = [names_all; names_act];
    
    pr = pose3d_matrix(:,[43,45]);
    pl = pose3d_matrix(:,[34,36]);
    rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
    orient = calc_orient(rotation);
    ii
    if (ii==1)
        hdf5write(fileh80k_allAct2d3d, sprintf('pose3D_act%d',ii), pose3d_matrix);
        hdf5write(fileh80k_allAct2d3d, sprintf('pose2D_act%d',ii) , pose2d_matrix,  'WriteMode', 'append' );
        hdf5write(fileh80k_allAct2d3d, sprintf('name_act%d',ii) , names_act,  'WriteMode', 'append' );
        hdf5write(fileh80k_allAct2d3d, sprintf('orient_act%d',ii) , orient,  'WriteMode', 'append' );
    else
        hdf5write(fileh80k_allAct2d3d, sprintf('pose3D_act%d',ii) , pose3d_matrix, 'WriteMode', 'append');
        hdf5write(fileh80k_allAct2d3d, sprintf('pose2D_act%d',ii) , pose2d_matrix, 'WriteMode', 'append');
        hdf5write(fileh80k_allAct2d3d, sprintf('name_act%d',ii) , names_act,  'WriteMode', 'append' );
        hdf5write(fileh80k_allAct2d3d, sprintf('orient_act%d',ii) , orient,  'WriteMode', 'append' );
    end
end




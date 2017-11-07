close all;clc;
% clear all;
small_4000; % config file
pose3D_pre = zeros(1, 51);
load([CONF.exp_dir 'human36m_big.mat'])
%% load some files
% val_index = [];
% names =[];
% pose_matrix = [];
% pose2d_matrix = [];

fileh80k_allAct2d3d = sprintf('/home/t Share/h80k/rnn/data/val80k_2d3dName.h5');
% load(('/home/tt/star/h80k/data/h80k_training_pose_name.mat'))
for ii = 1:15
    activity= sprintf('ActivitySpecific_%02d.mat', ii);
    rgb = matfile([CONF.exp_dir 'DenseFeatures' filesep 'RGB' filesep activity]);
    rgb = rgb.Ftrain;
    gtd2p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD2P' filesep activity]);
    gtd3p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep activity]);
    ii
    
    val_ind = METADATA.val_indx{ii};
    no_frms = length(val_ind);
    %     val_index_act= zeros(no_frms, 1);
    pose3d_matrix = zeros(no_frms, 51);
    names_all = cell(no_frms,1);
    pose2d_matrix = zeros(no_frms, 32);
    %     file_valNames = fopen(sprintf('/home/t Share/h80k/rnn/data/names/val_act%d.txt', ii), 'w');
    
    for i = 1:no_frms
        frNo = val_ind(i);
        im = cell2mat(rgb(frNo,1));
        im_name = sprintf('/validation_only/act_%d/im%d_%d.jpg', ii,ii, frNo);
        pose3D = gtd3p.Ftrain(frNo,:);
        %         NPose = normalize_pose(pose3D, CONF.skel3d);
        names_all{i} = im_name(17:end);
        
        tmp = gtd2p.Ftrain(frNo,:);
        p2 = convert2IEF(tmp(ind_joint_2d));
        tmp = bsxfun(@minus, p2, p2(:,7));
        figure;
        imshow(im)
        hold on;plot_pose_stickmodel([p2']);
        
        %         im = pad_cntr_img(im, tmp(:, 9));
        %         subplot(122);imshow(im)
        
        %         imwrite(im, [CONF.exp_dir im_name])
        %         pose2d_matrix(i,:) = reshape(tmp, 1, 32);
        %         pose3d_matrix(i,:) = NPose;
        %         fprintf(file_valNames, im_name(17:end));
        %         fprintf(file_valNames,'\n');
    end
    %     fclose(file_valNames);
    %     pose_matrix96 = [pose_matrix96; pose_matrix];
    %     pose2d_matrix = [pose2d_matrix;pose2d_matrix];
    %     pose_matrix = [pose_matrix; pose3d_matrix];
    %     names = [names;names_all];
    %     val_index = [val_index; val_index_act];
    
    %     if (ii==1)
    %         hdf5write(fileh80k_allAct2d3d, sprintf('pose3D_act%d',ii), pose3d_matrix);
    %         hdf5write(fileh80k_allAct2d3d, sprintf('pose2D_act%d',ii) , pose2d_matrix, 'WriteMode', 'append');
    %     %         hdf5write(fileh80k_allAct2d3d, sprintf('name_act%d',ii) , names_all, 'WriteMode', 'append');
    %     else
    %         hdf5write(fileh80k_allAct2d3d, sprintf('pose3D_act%d',ii) , pose3d_matrix, 'WriteMode', 'append');
    %         hdf5write(fileh80k_allAct2d3d, sprintf('pose2D_act%d',ii) , pose2d_matrix, 'WriteMode', 'append');
    %     %         hdf5write(fileh80k_allAct2d3d, sprintf('name_act%d',ii) , names_all, 'WriteMode', 'append');
    %     end
end



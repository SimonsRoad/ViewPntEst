clc;
close all;
clear all;
load_files = 1;
addpath('/home/tt/star/h80k/H80Kcode_v1/visualization');
addpath(['../twinGaussian/']);
load([CONF.exp_dir 'deepFeat_trnOnly.mat'])
small_4000;

if load_files
    load([CONF.exp_dir 'human36m_big.mat']);
    Param.kparam2 = 2*1e-6;
    Param.kparam1 = Param.kparam2;
    Param.knn = 400;
    Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
    files = METADATA.file_names;
    load([CONF.exp_dir '/training_only2.mat']);
    load([CONF.exp_dir,'validation_newNet.mat']);
%     load('IEF_training1.mat')
%     %     load('IEF_val_maskCenter.mat')
%     load('IEF_val1.mat')
        load('IEF_training_refine.mat')
        load('IEF_val_refine.mat') 
    activity_err = zeros(1,length(files));
    %     rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right');
end
 
est_pose3D_struct = cell(1,3);
M = 100;
activity_pose3D = cell(1,15);

for ii = 1: length(files)
    val = validation{ii};
    training_data = training_only{ii};
    val_orient = val.cnn_upBorient;
    train_orient = training_data.orient;
    val_ind = METADATA.val_indx{ii};
    N_val = length(val_ind);
    val_imPath = val.imagePath;
    %     %% IEF pose
    pose2d_IEF_val = IEF_val{ii};
    pose2d_IEF_val = reshape(pose2d_IEF_val', 2, 16, size(pose2d_IEF_val,1));
%         pose2d_val_gt = val.pose2d(:,ind_joint_2d);
%         pose2d_IEF_val = convert2IEF(pose2d_val_gt);
    
    pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,7,:));
    pose2d_val = reshape(pose2d_IEF_val,32, size(pose2d_IEF_val,3))';
    val_pose51 = normalize_pose(val.pose96, skel);
    %% % IEF pose
    pose2d_IEF_trn = IEF_training{ii};
    pose2d_IEF_trn = reshape(pose2d_IEF_trn', 2, 16, size(pose2d_IEF_trn,1));
    
    %     pose2d_trn_gt = training_only{ii}.pose2d(:,ind_joint_2d);
    %     pose2d_IEF_trn = convert2IEF(pose2d_trn_gt);
    
    pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,7,:));
    pose2d_train = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';
    pose3d_train = normalize_pose(training_data.pose96, skel);
    %%
 
        parfor i = 1:1:N_val
            test_pose = val_pose51(i,ind3d);
            Test_pose2d = double(pose2d_val_aug(i,:));
 
        end
             
end
 



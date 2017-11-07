clc;
close all;
% clear all;
load_files = 0;
addpath('/home/tt/star/h80k/H80Kcode_v1/visualization');
addpath(['../twinGaussian/']);
small_4000;

if load_files
    load([CONF.exp_dir 'human36m_big.mat']);
    Param.kparam2 = 2*1e-6;
    Param.kparam1 = Param.kparam2;
    Param.knn = 400;
    Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
    files = METADATA.file_names;
    %     load([CONF.exp_dir '/training_only2.mat']);
    %     load([CONF.exp_dir,'validation2.mat']);
    
    load([CONF.exp_dir '/training_only2_roi.mat']);
    load([CONF.exp_dir,'validation2_roi.mat']);
    %     load('IEF_training1.mat')
    %     %     load('IEF_val_maskCenter.mat')
    %     load('IEF_val1.mat')
    load('IEF_training_refine.mat')
    load('IEF_val_refine.mat')
    activity_err = zeros(1,length(files));
end

M = 0.1;
groundT_2dPose = 0;
activity_pose3D = cell(1,15);
ind_act = [1:3 6,9, 13, 15];

for aa = 1:length(ind_act)
    ii = ind_act(aa);
    val = validation{ii};
    training_data = training_only{ii};
    val_orient = val.cnn_orient;
    train_orient = training_data.cnn_orient;
    val_ind = METADATA.val_indx{ii};
    N_val = length(val_ind);
    val_imPath = val.imagePath;
    if groundT_2dPose
        pose2d_val_gt = val.pose2d(:,ind_joint_2d);
        pose2d_IEF_val = convert2IEF(pose2d_val_gt);
        pose2d_trn_gt = training_only{ii}.pose2d(:,ind_joint_2d);
        pose2d_IEF_trn = convert2IEF(pose2d_trn_gt);
    else
        pose2d_IEF_val = IEF_val{ii};
        pose2d_IEF_val = reshape(pose2d_IEF_val', 2, 16, size(pose2d_IEF_val,1));
        pose2d_IEF_trn = IEF_training{ii};
        pose2d_IEF_trn = reshape(pose2d_IEF_trn', 2, 16, size(pose2d_IEF_trn,1));
    end
    
    pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,7,:));
    pose2d_val = reshape(pose2d_IEF_val,32, size(pose2d_IEF_val,3))';
    val_pose51 = normalize_pose(val.pose96, skel,'hip');
    
    pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,7,:));
    pose2d_train = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';
    pose3d_train = normalize_pose(training_data.pose96, skel, 'hip');
    %%
    Input = pose2d_train;
    Target = double(pose3d_train);

    %     pose2d_val_aug = val.cnnFeat;
    %     Input_aug = training_data.cnnFeat;
    pose2d_val_aug = augment_cnnFeat(pose2d_val, val.cnnFeat);
    Input_aug = augment_cnnFeat(Input, training_data.cnnFeat);
    %%
    Input_aug(:,dim+1:end) = M*Input_aug(:,dim+1:end);
    pose2d_val_aug(:,dim+1:end) = M*pose2d_val_aug(:,dim+1:end);
    
    %     [InvIK, InvOK] = TGPTrain(Input_aug,  Target, Param);
    TGPKNNError = zeros(1,N_val);
    est_3d = zeros(N_val, 51);
    part_err = zeros(N_val,  17);
    parfor i = 1:1:N_val
        test_pose = val_pose51(i,:);
        Test_pose2d = double(pose2d_val_aug(i,:));
        [IDX, D] = knnsearch(Input_aug, Test_pose2d, 'K', 3);
        TGPPred = mean(Target(IDX,:));
        %         TGPPred = TGPTest(Test_pose2d, Input_aug,  Target, Param, InvIK, InvOK);
        [TGPKNNError(i), part_err(i,:)] = JointError(TGPPred, test_pose);
        est_3d(i,:) = TGPPred;
    end
    [ii mean(TGPKNNError(1:N_val))]
    activity_pose3D{ii}.est = est_3d;
    activity_pose3D{ii}.err_parts = part_err;
    activity_pose3D{ii}.total_err = mean(TGPKNNError(1:N_val));
end
mafile_name= ['all_act_IEF_M_',num2str(M),'.mat'];
save(mafile_name, 'activity_pose3D');



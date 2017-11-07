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
    %     load([CONF.exp_dir '/validation_up.mat']);
    %      load([CONF.exp_dir,'training_only_up.mat']);
    load([CONF.exp_dir '/training_only2.mat']);
    load([CONF.exp_dir,'validation2.mat']);
    %         load('IEF_training.mat')
    %     load('IEF_val_maskCenter.mat')
    load('IEF_training_refine.mat')
    load('IEF_val_refine.mat')
    %     load('IEF_val.mat')
    %     cnnF_train = training_only.cnnFeat'; cnnF_train_n = bsxfun(@rdivide, cnnF_train, sqrt(sum(cnnF_train.^2,1)));
    activity_err = zeros(1,length(files));
end
ind3d_r = [43:51];ind2d_r = [25,26, 23,24, 21,22];
ind3d_l = [34:42];ind2d_l = [31,32, 29,30, 27,28];
ind3d_b = [4:33];ind2d_b = [1:20];


est_pose3D_struct = cell(1,3);
M = 0;
activity_pose3D = cell(1,15);
groundT_2dPose = 0;

for ii = 1: length(files)
    val = validation{ii};
    training_data = training_only{ii};
    val_orient = val.cnn_upBorient;
    train_orient = training_data.orient;
    val_ind = METADATA.val_indx{ii};
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
    
    %%
    pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,7,:));
    pose2d_val_orig = reshape(pose2d_IEF_val,32, size(pose2d_IEF_val,3))';
    pose3d_val_orig = normalize_pose(val.pose96, skel, 'hip');
    %%
    pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,7,:));
    pose2d_train_orig = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';
    pose3d_train_orig = normalize_pose(training_data.pose96, skel, 'hip');
    
    bin_err = zeros(8, 4);
    for b = 1:8
        val_ind = find(val_orient ==b);
        trn_ind = find(train_orient ==b);
        
        pose3d_train = pose3d_train_orig(trn_ind,:);
        pose2d_train = pose2d_train_orig(trn_ind,:);
        pose3d_val = pose3d_val_orig(val_ind,:);
        pose2d_val = pose2d_val_orig(val_ind,:);
        N_val = length(val_ind);
        for s = 1:3
            if s == 1
                ind3d = ind3d_r;
                ind2d = ind2d_r;
            elseif s == 2
                ind3d = ind3d_l;
                ind2d = ind2d_l;
            else
                ind3d = ind3d_b;
                ind2d = ind2d_b;
            end
            Input = pose2d_train;
            Target = double(pose3d_train);
            dim = length(ind2d);
            %%
            pose2d_val_aug = augmentFeature(pose2d_val(:,ind2d), val_orient );
            Input_aug = augmentFeature(Input(:,ind2d), train_orient);
            %%
            Input_aug(:,dim+1:end) = M*Input_aug(:,dim+1:end);
            pose2d_val_aug(:,dim+1:end) = M*pose2d_val_aug(:,dim+1:end);
            
%             [InvIK, InvOK] = TGPTrain(Input_aug, double(Target(:,ind3d)), Param);
            TGPKNNError = zeros(1,N_val);
            est_3d = zeros(N_val, size(ind3d,2));
            part_err = zeros(N_val,  dim/2);
            parfor i = 1:1:N_val
                test_pose = pose3d_val(i,ind3d);
                Test_pose2d = double(pose2d_val_aug(i,:));
                        [IDX, D] = knnsearch(Input_aug, Test_pose2d, 'K', 3);
                         TGPPred = mean(Target(IDX, ind3d));
%                 TGPPred2 = TGPTest(Test_pose2d, Input_aug, double(Target(:,ind3d)), Param, InvIK, InvOK);
                [TGPKNNError(i), part_err(i,:)] = JointError(TGPPred, test_pose);
                est_3d(i,:) = TGPPred;
                %% nn 2d
                %         eNN_2d = calc_err2d(Input ,Test_pose2d);
                %         [eNN_2d_sorted, ind_nn2d] = sort(eNN_2d);
            end
            activity_err(s) = mean(TGPKNNError(1:N_val));
            est_pose3D_struct.est{s} = est_3d;
            est_pose3D_struct.err{s} = TGPKNNError;
        end
        
        N = size(est_pose3D_struct.est{3}, 1);
        activity_pose3D{ii}.est = [zeros(N,3) est_pose3D_struct.est{3} est_pose3D_struct.est{2} est_pose3D_struct.est{1}];
        
        [err_total, err_parts] = JointError(activity_pose3D{ii}.est, pose3d_val);
        activity_pose3D{ii}.err = [mean(err_total) mean(est_pose3D_struct.err{3}) mean(est_pose3D_struct.err{2}) mean(est_pose3D_struct.err{1})];
        [b  activity_pose3D{ii}.err]
        bin_err(b,:) = activity_pose3D{ii}.err;
    end
    [mean(bin_err(:,1)') mean(bin_err(:,2)') mean(bin_err(:,3)') mean(bin_err(:, 4)')]'
end

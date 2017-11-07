clc;close all;
% clear all;
load_files = 0;
addpath('/home/tt/star/h80k/H80Kcode_v1/visualization');addpath(['../twinGaussian/']);small_4000;

if load_files
    load([CONF.exp_dir 'human36m_big.mat']);
    Param.kparam2 = 2*1e-6;Param.kparam1 = Param.kparam2;Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
    files = METADATA.file_names;
    load([CONF.exp_dir '/training_only2_roi.mat']);
    load([CONF.exp_dir,'validation2_roi.mat']);
    %     load('IEF_training1.mat')
    %     %     load('IEF_val_maskCenter.mat')
    %     load('IEF_val1.mat')
    load('IEF_training_refine.mat')
    load('IEF_val_refine.mat')
    activity_err = zeros(1,length(files));
end

ind3d_r = [43:51];ind2d_r = [25,26, 23,24, 21,22];%[21:26];
ind3d_l = [34:42];ind2d_l = [31,32, 29,30, 27,28];%[27:32];
ind3d_b = [4:33];ind2d_b = [1:20];


groundT_2dPose = 0;
est_pose3D_struct = cell(1,3);
M = 100;
activity_pose3D = cell(1,15);
ind_act = [1:3 6,9, 13, 15];

for aa = 1:length(ind_act)
    ii = ind_act(aa);
    val = validation{ii};training_data = training_only{ii};
    val_orient = val.cnn_upBorient;train_orient = training_data.cnn_upBorient;
    val_ind = METADATA.val_indx{ii};
    N_val = length(val_ind);
    val_imPath = val.imagePath;
    %% IEF pose
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
    for s = 1:3
        if s== 3
            pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,7,:));
            pose2d_val = reshape(pose2d_IEF_val,32, size(pose2d_IEF_val,3))';
             pose2d_val = bsxfun(@rdivide, pose2d_val, norm(pose2d_val(:,19:20)));
            val_pose51 = normalize_pose(val.pose96, skel, 'hip');
            
            pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,7,:));
            pose2d_train = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';
            pose2d_train = bsxfun(@rdivide, pose2d_train, norm(pose2d_train(:,19:20)));
            pose3d_train = normalize_pose(training_data.pose96, skel, 'hip');
            
        else
            pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,9,:));
            pose2d_val = reshape(pose2d_IEF_val,32, size(pose2d_IEF_val,3))';
             pose2d_val = bsxfun(@rdivide, pose2d_val, norm(pose2d_val(:,19:20)));
            val_pose51 = normalize_pose(val.pose96, skel, 'neck');
            
            pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,9,:));
            pose2d_train = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';
            pose2d_train = bsxfun(@rdivide, pose2d_train, norm(pose2d_train(:,19:20)));
            pose3d_train = normalize_pose(training_data.pose96, skel, 'neck');
        end
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
        Target = double(pose3d_train(:,ind3d));
        dim = length(ind2d);
        %%
        pose2d_val_aug = augmentFeature(pose2d_val(:,ind2d), val_orient );
        Input_aug = augmentFeature(Input(:,ind2d), train_orient);
        %%
        Input_aug(:,dim+1:end) = M*Input_aug(:,dim+1:end);
        pose2d_val_aug(:,dim+1:end) = M*pose2d_val_aug(:,dim+1:end);
        
        [InvIK, InvOK] = TGPTrain(Input_aug, Target, Param);
        TGPKNNError = zeros(1,N_val);
        est_3d = zeros(N_val, size(ind3d,2));
        part_err = zeros(N_val,  dim/2);
        parfor i = 1:1:N_val
            test_pose = val_pose51(i,ind3d);
            Test_pose2d = double(pose2d_val_aug(i,:));
            TGPPred = TGPTest(Test_pose2d, Input_aug, Target, Param, InvIK, InvOK);
            %             [IDX, D] = knnsearch(Input_aug, Test_pose2d, 'K', 5);
            %             TGPPred = mean(Target(IDX,ind3d));
            [TGPKNNError(i), part_err(i,:)] = JointError(TGPPred, test_pose);
            est_3d(i,:) = TGPPred;
        end
        activity_err(s) = mean(TGPKNNError(1:N_val));
        est_pose3D_struct.est{s} = est_3d;
        est_pose3D_struct.err{s} = TGPKNNError;
    end
    for s=1:2
        neck = repmat(est_pose3D_struct.est{3}(:,22:24), 1, 3);
         est_pose3D_struct.est{s} = bsxfun(@plus, est_pose3D_struct.est{s}, neck);
    end
    N = size(est_pose3D_struct.est{1}, 1);
    activity_pose3D{ii}.est = [zeros(N,3) est_pose3D_struct.est{3} est_pose3D_struct.est{2} est_pose3D_struct.est{1}];
    
    [err_total, err_parts] = JointError(activity_pose3D{ii}.est, val_pose51);
    activity_pose3D{ii}.err = [mean(err_total) mean(est_pose3D_struct.err{1}) mean(est_pose3D_struct.err{2}) mean(est_pose3D_struct.err{3})];
    [ii  activity_pose3D{ii}.err]'
    activity_pose3D{ii}.err = err_total;
    activity_pose3D{ii}.err_parts = [ (est_pose3D_struct.err{3});  (est_pose3D_struct.err{2});  (est_pose3D_struct.err{1})];
    
end
mafile_name= ['err_IEF_M_',num2str(M),'.mat'];
save(mafile_name, 'activity_pose3D');



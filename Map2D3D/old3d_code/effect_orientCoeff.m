clc;
close all;
clear all;
load_files = 1;
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
    load('IEF_training.mat')
    load('IEF_val.mat')
    %     cnnF_train = training_only.cnnFeat'; cnnF_train_n = bsxfun(@rdivide, cnnF_train, sqrt(sum(cnnF_train.^2,1)));
    activity_err = zeros(1,length(files));
    %     rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right');
end
ind3d_r = [43:51];
ind2d_r = [21:26];
ind3d_l = [34:42];
ind2d_l = [27:32];
ind3d_b = [4:33];
ind2d_b = [1:20];


activity_pose3D = cell(1,15);

for ii = 1: length(files)
    val = validation{ii};
    training_data = training_only{ii};
    val_orient = val.cnn_orient;
    train_orient = training_data.cnn_orient;
    val_ind = METADATA.val_indx{ii};
    N_val = length(val_ind);
    val_imPath = val.imagePath;
    %% IEF pose
    pose2d_IEF_val = IEF_val{ii};
    pose2d_IEF_val = reshape(pose2d_IEF_val', 2, 16, size(pose2d_IEF_val,1));
    pose2d_IEF_trn = IEF_training{ii};
    pose2d_IEF_trn = reshape(pose2d_IEF_trn', 2, 16, size(pose2d_IEF_trn,1));
    %%
    %     pose2d_val_gt = val.pose2d(:,ind_joint_2d);
    %     pose2d_IEF_val = convert2IEF(pose2d_val_gt);
    %
    %     pose2d_trn_gt = training_data.pose2d(:,ind_joint_2d);
    %     pose2d_IEF_trn = convert2IEF(pose2d_trn_gt);
    
    pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,7,:));
    %%
    %     h_2d_val = squeeze( abs(pose2d_IEF_val(2, 1,:))+ abs(pose2d_IEF_val(2, 10,:)))';
    %     pose2d_IEF_val_n = pose2d_IEF_val;
    %     scale= repmat(200./h_2d_val, 16,1);
    %     pose2d_IEF_val_n(2,:,:) = bsxfun(@times, squeeze(pose2d_IEF_val(2,:,:)), scale);
    %     h_2d_val_n = squeeze( abs(pose2d_IEF_val_n(2, 1,:))+ abs(pose2d_IEF_val_n(2, 10,:)))';
    %     pose2d_val = reshape(pose2d_IEF_val_n,32, size(pose2d_IEF_val,3))';
    %%
    pose2d_val = reshape(pose2d_IEF_val,32, size(pose2d_IEF_val,3))';
    val_pose51 = normalize_pose(val.pose96, skel);
    
    %     p3d = reshape(val_pose51', 3, 17, size(val_pose51,1));
    %     h_3d = squeeze( abs(p3d(2, 4,:))+ abs(p3d(2, 11,:)))';
    %     scale= repmat(1700./h_3d, 17,1);
    %     p3d(2,:,:) = bsxfun(@times, squeeze(p3d(2,:,:)), scale);
    %     val_pose51 = squeeze(reshape(p3d, 1, 51, size(val_pose51,1)))';
    %%
    pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,7,:));
    %%
    %     h_2d = squeeze( abs(pose2d_IEF_trn(2, 1,:))+ abs(pose2d_IEF_trn(2, 10,:)))';
    %     [sorted_h, ind_h]=sort(h_2d, 'descend');
    %     pose2d_IEF_trn_n = pose2d_IEF_trn;
    %     scale= repmat(200./h_2d, 16,1);
    %     pose2d_IEF_trn_n(2,:,:) = bsxfun(@times, squeeze(pose2d_IEF_trn(2,:,:)), scale);
    %     h_2d_n = squeeze( abs(pose2d_IEF_trn_n(2, 1,:))+ abs(pose2d_IEF_trn_n(2, 10,:)))';
    %     pose2d_train = reshape(pose2d_IEF_trn_n, 32, size(pose2d_IEF_trn,3))';
    %%
    pose2d_train = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';
    pose3d_train = normalize_pose(training_data.pose96, skel);
    %%
    %     p3d = reshape(pose3d_train', 3, 17, size(pose3d_train,1));
    %     h_3d = squeeze( abs(p3d(2, 4,:))+ abs(p3d(2, 11,:)))';
    %     scale= repmat(1700./h_3d, 17,1);
    %     p3d(2,:,:) = bsxfun(@times, squeeze(p3d(2,:,:)), scale);
    %     pose3d_train = squeeze(reshape(p3d, 1, 51, size(pose3d_train,1)))';
    %%
    M_vec = [2000];
    err = zeros(1, length(M_vec));
    for m=1:length(M_vec)
        M = M_vec(m);
        est_pose3D_struct = struct;
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
            pose2d_val_aug = augmentFeature(pose2d_val(:,ind2d), val_orient);
            Input_aug = augmentFeature(Input(:,ind2d), train_orient);
            %%
            Input_aug(:,dim+1:end) = M*Input_aug(:,dim+1:end);
            pose2d_val_aug(:,dim+1:end) = M*pose2d_val_aug(:,dim+1:end);
            
            [InvIK, InvOK] = TGPTrain(Input_aug, double(Target(:,ind3d)), Param);
            TGPKNNError = zeros(1,N_val);
            est_3d = zeros(N_val, size(ind3d,2));
            part_err = zeros(N_val,  dim/2);
            parfor i = 1:1:N_val
                test_pose = val_pose51(i,ind3d);
                Test_pose2d = double(pose2d_val_aug(i,:));
                %             im_val = imread([CONF.exp_dir  val.names{ (i)}]);
                TGPPred = TGPTest(Test_pose2d, Input_aug, double(Target(:,ind3d)), Param, InvIK, InvOK);
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
        
        [err_total, err_parts] = JointError(activity_pose3D{ii}.est, val_pose51);
        activity_pose3D{ii}.err = [mean(err_total) mean(est_pose3D_struct.err{3}) mean(est_pose3D_struct.err{2}) mean(est_pose3D_struct.err{1})];
        %         [ii  activity_pose3D{ii}.err]'
        err(m) = activity_pose3D{ii}.err(1);
    end
end
save('all_act_IEF_M_0.mat', 'activity_pose3D');

% save('poseIEF_CNNOrient.mat', 'activity_pose3D')
% save('poseIEF_GTOrient.mat', 'est_pose3D_struct')
% save('poseGT_noOrient.mat', 'est_pose3D_struct')
% save('est_pose3D_struct.mat', 'est_pose3D_struct')


right_hand = struct;
right_hand.err = TGPKNNError;
right_hand.est = est_3d;
save('right-hand_IEFP_GTO.mat', 'right_hand')
% save('right-hand_IEFP_cnnO.mat', 'right_hand')
% % save('right-hand_gtP_cnnO.mat', 'right_hand')


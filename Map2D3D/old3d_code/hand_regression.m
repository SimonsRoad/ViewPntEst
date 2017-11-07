clc;close all;
% clear all;
% load_files = 1;
addpath('/home/tt/star/h80k/H80Kcode_v1/visualization');
addpath(['../twinGaussian/']);small_4000;

if load_files
    load([CONF.exp_dir 'human36m_big.mat']);
    Param.kparam2 = 2*1e-6;
    Param.kparam1 = Param.kparam2;
    Param.knn = 400;
    Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
    files = METADATA.file_names;
    load([CONF.exp_dir '/training_only2.mat']);
    load([CONF.exp_dir,'validation2.mat']);
    %     load('IEF_training1.mat')
    %     %     load('IEF_val_maskCenter.mat')
    %     load('IEF_val1.mat')
    load('IEF_training_refine.mat')
    load('IEF_val_refine.mat')
    activity_err = zeros(1,length(files));
end

ind3d_r = [43:51];ind2d_r = [25,26, 23,24, 21,22];
ind3d_l = [34:42];ind2d_l = [27:32];    %ind2d_l = [31,32, 29,30, 27,28];
ind3d_b = [4:27, 31:33];ind2d_b = [1:12, 15:20];
% ind3d_r_L = [4:12];ind2d_r_L = [5,6, 3,4, 1,2];
% ind3d_l_L = [13:21];ind2d_l_L = [7:12];
groundT_2dPose = 1;
% est_pose3D_struct = struct;
% est_pose3D_struct.est = cell(1,5);
% est_pose3D_struct.err= cell(1,5);
M = 0;
% activity_pose3D = cell(1,15);

for ii = 1: length(files)
    val = validation{ii};
    training_data = training_only{ii};
    val_orient = val.cnn_upBorient;
    train_orient = training_data.orient;
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
    
    pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,9,:));
    pose2d_val = reshape(pose2d_IEF_val,32, size(pose2d_IEF_val,3))';
    
    pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,9,:));
    pose2d_train = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';
    
    %
    %     tmp_arm = reshape(pose3d_train', 3, 17, size(pose3d_train,1));
    %     upperArm = sqrt(sum(squeeze(tmp_arm(:,15, :) - tmp_arm(:,16, :)).^2, 1));
    %     lowerArm = sqrt(sum(squeeze(tmp_arm(:,17, :) - tmp_arm(:,16, :)).^2, 1));
    
    %         a= est_pose3D_struct.est{1};
    %     %     a = val_pose51(:,ind3d_r);
    %          tmp_arm = reshape(a', 3, 3, size(a,1));
    %         upperArm = sqrt(sum(squeeze(tmp_arm(:,1, :) - tmp_arm(:,2, :)).^2, 1));
    %         lowerArm = sqrt(sum(squeeze(tmp_arm(:,3, :) - tmp_arm(:,2, :)).^2, 1));
    %         figure;
    %         subplot(211);plot(upperArm);title('upperArm')
    %         subplot(212);plot(lowerArm);title('lowerArm')
    %         [mean(lowerArm), var(lowerArm)]   %  143.1471    1.4826
    %         [mean(upperArm), var(upperArm)] % 164.8395   25.3483
    
    %%
    for s = 3:3
        if s == 1 || s == 2
            pose3d_train = normalize_pose(training_data.pose96, skel, 'neck');
            val_pose51 = normalize_pose(val.pose96, skel, 'neck');
        else
            pose3d_train = normalize_pose(training_data.pose96, skel, 'hip');
            val_pose51 = normalize_pose(val.pose96, skel, 'hip');
        end
        
        if s == 1
            ind3d = ind3d_r;
            ind2d = ind2d_r;
        elseif s == 2
            ind3d = ind3d_l;
            ind2d = ind2d_l;
        elseif s==3
            
            ind3d = ind3d_b;
            ind2d = ind2d_b;
        elseif s == 4
            ind3d = ind3d_r_L;
            ind2d = ind2d_r_L;
            
        else
            ind3d = ind3d_l_L;
            ind2d = ind2d_l_L;
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
        
        [InvIK, InvOK] = TGPTrain(Input_aug, double(Target(:,ind3d)), Param);
        TGPKNNError = zeros(1,N_val);
        est_3d = zeros(N_val, size(ind3d,2));
        part_err = zeros(N_val,  dim/2);
        
        parfor i = 1:1:N_val
            test_pose = val_pose51(i,ind3d);
            Test_pose2d = double(pose2d_val_aug(i,:));
            TGPPred = TGPTest(Test_pose2d, Input_aug, double(Target(:,ind3d)), Param, InvIK, InvOK,(s==3));
            [TGPKNNError(i), part_err(i,:)] = JointError(TGPPred, test_pose);
            est_3d(i,:) = TGPPred;
            %% nn 2d
            %         eNN_2d = calc_err2d(Input ,Test_pose2d);
            %         [eNN_2d_sorted, ind_nn2d] = sort(eNN_2d);
        end
        activity_err(s) = mean(TGPKNNError(1:N_val));
        if s==3
            tmp_neck = reshape(est_3d',3, size(est_3d,2)/3, N_val);
            middle_head = squeeze(0.5*(tmp_neck(:,end,:)+ tmp_neck(:,end-1,:))) ;
            l = size(est_3d,2);
            est_3d= [est_3d(:, 1:l-3),middle_head', est_3d(:,l-2:l)];
        end
        est_pose3D_struct.est{s} = est_3d;
        est_pose3D_struct.err{s} = TGPKNNError;
        [s,  activity_err(s)]
    end
    tmp_b = reshape(  est_pose3D_struct.est{3}', 3, l/3+1, N_val);
    head = repmat(squeeze(tmp_b(:,8,:)), 3, 1);
    right_h = bsxfun(@plus, est_pose3D_struct.est{1}' , head);
    left_h = bsxfun(@plus, est_pose3D_struct.est{2}' , head);
    activity_pose3D{ii}.est = [zeros(N_val,3) est_pose3D_struct.est{3}  left_h' right_h' ];
    [activity_pose3D{ii}.err, err_parts] = JointError(activity_pose3D{ii}.est, val_pose51);
    %%
    activity_pose3D{ii}.err_parts(1,:) = JointError(activity_pose3D{ii}.est(:,ind3d_r), val_pose51(:,ind3d_r));
    activity_pose3D{ii}.err_parts(2,:) = JointError(activity_pose3D{ii}.est(:, ind3d_l), val_pose51(:, ind3d_l));
    ind3d_b_t = [4:33];
    activity_pose3D{ii}.err_parts(3,:) = JointError(activity_pose3D{ii}.est(:, ind3d_b_t), val_pose51(:, ind3d_b_t));
    %%
    [ii mean(activity_pose3D{ii}.err), mean(activity_pose3D{ii}.err_parts(3,:)), mean(activity_pose3D{ii}.err_parts(2,:)), mean(activity_pose3D{ii}.err_parts(1,:))]'
    
end


%%
% close all
% figure;
% p=3;o1=find(o==p);subplot(2,2,p);plot(a(o1,1),a(o1,2),'*r');hold on;plot(a(o1,3), a(o1,4),'*k');hold on;plot(a(o1,5), a(o1,6), '*');title(['pose = ',num2str(p)]);xlim([-200, 200]);ylim([-150, 150])

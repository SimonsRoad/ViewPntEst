ind3d_r = [43:51];ind2d_r = [25,26, 23,24, 21,22];%[21:26];
ind3d_l = [34:42];ind2d_l = [31,32, 29,30, 27,28];%[27:32];
ind3d_b = [4:33];ind2d_b = [1:20];

groundT_2dPose= 0;

M = 200;
est = cell(1,3);

for ii = 1: length(files)
    val = validation{ii};
    training_data = training_only{ii};
    val_orient = val.orient;
    train_orient = training_data.orient;
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
    pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,7,:));
    pose2d_val = reshape(pose2d_IEF_val,32, size(pose2d_IEF_val,3))';
    val_pose51 = normalize_pose(val.pose96, skel, 'hip');
    
    pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,7,:));
    pose2d_train = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';
    pose3d_train = normalize_pose(training_data.pose96, skel, 'hip');
    %%
    for m=1:2
        if m==2
            M = 0;
        end
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
            
            [InvIK, InvOK] = TGPTrain(Input_aug, double(Target(:,ind3d)), Param);
            i = 1196;
            test_pose = val_pose51(i,ind3d);
            Test_pose2d = double(pose2d_val_aug(i,:));
            TGPPred = TGPTest(Test_pose2d, Input_aug, double(Target(:,ind3d)), Param, InvIK, InvOK, (s==3));
            [TGPKNNError, part_err] = JointError(TGPPred, test_pose);
            est{s} = TGPPred;
            error_p{s} = TGPKNNError;
        end
        est_total(m,:) = [zeros(1,3)  est{3}  est{2}  est{1}];
        [err_total(m), err_parts] = JointError(est_total(m,:), val_pose51(i,:));
    end
    figure;
    R=2;C=2;
    rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right');
    figure;im_val = imread([CONF.exp_dir  val.names{i}]);
    subplot(R,C,1);imshow(im_val);
    
    subplot(R,C,2);rb.render3D(  convert_joint51_96(  val_pose51(i,:) ));title('Ground Pose 3D pose')
    subplot(R,C,3);rb.render3D(  convert_joint51_96(  est_total(2,:) ));title('3D est. using 2D pose')
    subplot(R,C,4);rb.render3D(  convert_joint51_96(  est_total(1,:) ));title('3D est. using 2D pose & viewPnt')
end

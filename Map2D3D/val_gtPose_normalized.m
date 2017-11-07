clc;
close all;
clear all;
load_files = 1
addpath('/home/tt/star/h80k/H80Kcode_v1/visualization');
root_dir = '/home/tt/star/';
addpath(['../twinGaussian/']);
small_4000;

if load_files
    load([CONF.exp_dir 'human36m_big.mat']);
    %     Param.kparam1 = 0.2;
    Param.kparam2 = 2*1e-6;
    Param.kparam1 = Param.kparam2;
    Param.knn = 400;
    Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
    files = METADATA.file_names;
    load([CONF.exp_dir '/validation_up.mat']);
    %     load([CONF.exp_dir '/validation_hand_act_1.mat']);
    %     load([CONF.exp_dir '/training_only_up_hand.mat']);
    
    load([CONF.exp_dir,'training_only_up.mat']);
    
    %     cnnF_train = training_only.cnnFeat'; cnnF_train_n = bsxfun(@rdivide, cnnF_train, sqrt(sum(cnnF_train.^2,1)));
    activity_err = zeros(1,length(files));
    rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right');
end

M=10
for ii = 1: length(files)
    
    val = validation{ii};
    val_ind = METADATA.val_indx{ii};
    N_val = length(val_ind);
    val_imPath = val.imagePath;
    
    pose2d_val_gt = val.pose2d(:,ind_joint_2d);
    pose2d_IEF_val = convert2IEF(pose2d_val_gt);
    
    pose2d_IEF_val = bsxfun(@minus, pose2d_IEF_val, pose2d_IEF_val(:,7,:));
    %%
    h_2d_val = squeeze( abs(pose2d_IEF_val(2, 1,:))+ abs(pose2d_IEF_val(2, 10,:)))';
    pose2d_IEF_val_n = pose2d_IEF_val;
    scale= repmat(200./h_2d_val, 16,1);
    pose2d_IEF_val_n(2,:,:) = bsxfun(@times, squeeze(pose2d_IEF_val(2,:,:)), scale);
    h_2d_val_n = squeeze( abs(pose2d_IEF_val_n(2, 1,:))+ abs(pose2d_IEF_val_n(2, 10,:)))';
    pose2d_val = reshape(pose2d_IEF_val_n,32, size(pose2d_IEF_val,3))';
    val_pose51 = normalize_pose(val.pose96, skel);
    
    p3d = reshape(val_pose51', 3, 17, size(val_pose51,1));
    h_3d = squeeze( abs(p3d(2, 4,:))+ abs(p3d(2, 11,:)))';
    scale= repmat(1700./h_3d, 17,1);
    p3d(2,:,:) = bsxfun(@times, squeeze(p3d(2,:,:)), scale);
    val_pose51 = squeeze(reshape(p3d, 1, 51, size(val_pose51,1)))';
    
    val_orient = val.orient;
    CNN_F_tst = val.cnnFeat;
    %%
    training_data = training_only{ii};
    pose2d_trn_gt = training_data.pose2d(:,ind_joint_2d);
    pose2d_IEF_trn = convert2IEF(pose2d_trn_gt);
    pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,7,:));
    h_2d = squeeze( abs(pose2d_IEF_trn(2, 1,:))+ abs(pose2d_IEF_trn(2, 10,:)))';
    [sorted_h, ind_h]=sort(h_2d, 'descend');
    pose2d_IEF_trn_n = pose2d_IEF_trn;
    scale= repmat(200./h_2d, 16,1);
    pose2d_IEF_trn_n(2,:,:) = bsxfun(@times, squeeze(pose2d_IEF_trn(2,:,:)), scale);
    h_2d_n = squeeze( abs(pose2d_IEF_trn_n(2, 1,:))+ abs(pose2d_IEF_trn_n(2, 10,:)))';
    pose2d_train = reshape(pose2d_IEF_trn_n, 32, size(pose2d_IEF_trn,3))';
    train_orient = training_data.orient;
    cnnF_train =  training_data.cnnFeat;
    
    pose3d_train = normalize_pose(training_data.pose96, skel);
    p3d = reshape(pose3d_train', 3, 17, size(pose3d_train,1));
    h_3d = squeeze( abs(p3d(2, 4,:))+ abs(p3d(2, 11,:)))';
    scale= repmat(1700./h_3d, 17,1);
    p3d(2,:,:) = bsxfun(@times, squeeze(p3d(2,:,:)), scale);
    pose3d_train = squeeze(reshape(p3d, 1, 51, size(pose3d_train,1)))';
    %%
    %     up_ind_2d = [13:32];up_ind_3d = [22:51];
    %     Input_u = pose2d_train(:,up_ind_2d);Target_u = pose3d_train(:,up_ind_3d);
    %     [InvIK_u, InvOK_u] = TGPTrain(Input_u, double(Target_u), Param);
    %     lb_ind_2d = [1:20];lb_ind_3d = [1:33];
    %     Input_l = pose2d_train(:,lb_ind_2d);Target_l = pose3d_train(:,lb_ind_3d);
    %     angles2d_val = calc_pose_angles(pose2d_val);
    %     angles2d_trn = calc_pose_angles(pose2d_train);
    
    TGPKNNError = zeros(1,N_val);
    
     pose3d_train_f = flip_3djoint(pose3d_train);
        pose2d_train_f = flip_2djoint_IEF(pose2d_train);
    pose3d_train_d = [pose3d_train; pose3d_train_f];
    pose2d_train_d =[pose2d_train; pose2d_train_f];
  
    
    Input = pose2d_train_d;
    Target = double(pose3d_train_d);
    Input = Input(:,21:26);
    Target = Target(:, 43:51);
    val_pose51 =val_pose51(:, 43:51);
    pose2d_val = double(pose2d_val(:,21:26));
    %         ind_t = find(train_orient == category );
    [InvIK, InvOK] = TGPTrain(Input(:,:), double(Target(:,:)), Param);
    est_3d = zeros(N_val, 9);
    %%
    parfor i = 1:1:N_val
        test_pose = val_pose51(i,:);
        
        Test_pose2d = double(pose2d_val(i,:));
        orientation = val.orient(i);
        TGPPred = TGPTest(Test_pose2d, Input(:,:), double(Target(:,:)), Param, InvIK, InvOK);
        [TGPKNNError(i), part_err] = JointError(TGPPred, test_pose);
        est_3d(i,:) = TGPPred;
        
        %% nn 2d
        %         eNN_2d = calc_err2d(Input ,Test_pose2d);
        %         [eNN_2d_sorted, ind_nn2d] = sort(eNN_2d);
        %         figure;
        %         R = 3;C=2;
        %         im_test = imread([CONF.exp_dir  val.names{i}]);
        %         subplot(R,C,1);imshow(im_test);
        %         title(['err2d= ', num2str(round(TGPKNNError(i))), ', c=', num2str(size(im_test,1)), ' r=', num2str(size(im_test,2)), ', h=', num2str(h_2d_val_n(i) )])
        %         for nn=1:R*C-1
        %             subplot(R,C,nn+1);
        %             name_neighbor=[training_data.imagePath,  training_data.names{ ind_nn2d(nn)}];
        %             im = imread(name_neighbor);imshow(im);
        %             title(['err2d= ', num2str(round(eNN_2d_sorted(nn))), ', c=', num2str(ind_nn2d(nn)), ', h=', num2str(h_2d_n(ind_nn2d(nn)))])
        %         end
        %         i
        %%
        %             if orientation == category
        %                 if TGPKNNError(i) > 100
        
        %         subplot(R,C,1);imshow(im_test);
        %         title(['orient: ', num2str(orientation),', err = ', num2str(round(TGPKNNError(i))), ...
        %             ', R-h:', num2str(val.orient_rHand(i))])
        %         subplot(R,C,2);  rb.render3D(convert_joint51_96(test_pose));title('gt')
        %         subplot(R,C,3);  rb.render3D(convert_joint51_96(TGPPred));title('estimation')
        %         subplot(R,C,4);plot(part_err, '*r');xlim([0,16])
        %         cnnF_test = (val.CNN_r_h_val(i,:))';
        %
        %         D = chi2_mex(cnnF_test, cnnF_train(:,:)');[tmpD, ind_body] = sort(D);
        %         name_neighbor=[training_data.imagePath,  training_data.names{ (ind_body(1))}];
        %         subplot(R,C,5);im = imread(name_neighbor);imshow(im)
        %         name_neighbor=[training_data.imagePath,  training_data.names{ (ind_body(2))}];
        %         subplot(R,C,6);im = imread(name_neighbor);imshow(im)
        %                 end
        %             end
        %         figure;R = 3;C = 2;
        %        subplot(R,C,1);imshow(im_test);title(['ot: ', num2str(orientation)])
        %
        %         [ind, dist]=knnsearch(angles2d_trn, angles2d_val(i,:),'K',10);
        %         for l=1:R*C-1
        %             name_neighbor = [ training_data.imagePath,  training_data.names{ind(l)}];im = imread(name_neighbor);
        %             subplot(R,C,l+1);
        %             err = JointError(pose3d_train(ind(l),:), test_pose);
        %             err_2d = sum(abs(Input(ind(l), :)- Test_pose2d));
        %             diff_angle = sum(abs(angles2d_val(i,:) - angles2d_trn(ind(l),:)));
        %             imshow(im);
        %             title(['ind =', num2str(ind(l)),' ,err= ', num2str(round(err)), ...
        %                 ', e-2d: ', num2str(round(err_2d)), ', d-a=', num2str(round(diff_angle)) ])
        %         end
        %                 rb.render3D(convert_joint51_96(TGPPred));
    end
    %
    activity_err(ii) = mean(TGPKNNError(1:N_val));
    [ii , activity_err(ii)]
    %         ind = find(TGPKNNError~=0);
    %         err_cat(category) = mean(TGPKNNError(ind));
    %         no_imgs_cat(category) = length(ind);
    
end


[mean(activity_err)  ]
[mean(TGPKNNError(val.orient==1)), mean(TGPKNNError(val.orient==2)), mean(TGPKNNError(val.orient== 3)), mean(TGPKNNError(val.orient== 4))]


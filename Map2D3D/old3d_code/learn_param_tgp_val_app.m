clc;
close all;
clear all;
load_files = 1
addpath('/home/tt/star/h80k/H80Kcode_v1/visualization');
addpath(genpath('/home/tt/star/human36m/code/'))
root_dir = '/home/tt/star/';
addpath(['../twinGaussian/']);
ind_joint_2d =  [1,2:4, 7:9, 13:16, 18:20, 26:28];
%{
orientations
'back'       1
'forward'    2
'right'      3
'left'       4
%}
show_img = 0;
small_4000;

if load_files
    load([CONF.exp_dir 'human36m_big.mat']);
    %     Param.kparam1 = 0.2;
    files = METADATA.file_names;
    load([CONF.exp_dir '/validation.mat']);
    load([CONF.exp_dir,'training_only.mat'])
    load('IEF_val.mat')
    load('IEF_training.mat')
    %     cnnF_train = training_only.cnnFeat'; cnnF_train_n = bsxfun(@rdivide, cnnF_train, sqrt(sum(cnnF_train.^2,1)));
    activity_err = zeros(1,length(files));
    %     load([CONF.exp_dir '/regModel_approx_all.mat'])
    load([CONF.exp_dir '/regressionModel_approx2.mat'])
end
pose2d_ind = [1:20,25:28];
% Param.kparam2 = 2*1e-6;
% Param.kparam1 = 0.2;
Param.lambda = 1e-3;
kernel_w = [10.^[-2, -3, -4,-5, -6], 2*1e-6];
[kwI, kwO] = meshgrid(kernel_w, kernel_w);
% Param.kparam3 = Param.kparam2;


%%
for ii = 1: length(files)
    
    val = validation{ii};
    val_ind = METADATA.val_indx{ii};
    N_val = length(val_ind);
    val_imPath = val.imagePath;
    
    pose2d = IEF_val{ii};
    tmp = reshape(pose2d', 2, 16, size(pose2d,1));
    m = bsxfun(@minus, tmp, tmp(:,7,:));
    pose2d_val = reshape(m, 32, size(pose2d,1))';
    
    pose2d = IEF_training{ii};
    tmp = reshape(pose2d', 2, 16, size(pose2d,1));
    m = bsxfun(@minus, tmp, tmp(:,7,:));
    pose2d_train = reshape(m, 32, size(pose2d,1))';
    
    train_orient = training_only{ii}.orient;
    cnnF_train =  training_only{ii}.cnnFeat;
    CNN_F_tst = validation{ii}.cnnFeat;
    pose51 = normalize_pose(training_only{ii}.pose96, skel);
    val_pose51 = normalize_pose(val.pose96, skel);
    angles2d_val = calc_pose_angles(IEF_val{ii});
    angles2d_trn = calc_pose_angles(IEF_training{ii});
    error_act = zeros(length(kernel_w), length(kernel_w));
    %%
    Input= pose2d_train;
    Target = pose51;
    for p =1:length(kernel_w)
        for q =1:length(kernel_w)
            Param.kparam1 = kwI(p,q);
            Param.kparam2 = kwO(p,q);
            
            Param.kparam1 = 1e-5; % best value
            Param.kparam2 = 1e-6; % best value, cross validation
            noise = 10.^[-1,-2,-3,-4];
            error_noise = zeros(1,length(noise));
            for e=1:length(noise)
                Param.lambda = noise(e);
                [InvIK, InvOK] = TGPTrain(Input, double(Target), Param);
                %     [InvIK, InvOK] = TGPTrain_orient(Input, double(Target), Param, train_orient);
                parfor i = 1:N_val
                    %         cnnF_test = (CNN_F_tst(i,:))';D = chi2_mex(cnnF_test, cnnF_train');[tmpD, ind] = sort(D);
                    test_pose = val_pose51(i,:);
                    orientation = val.orient(i);
                    %         ind_orient = find(train_orient==orientation);
                    
                    %         trn_f = [angles2d_trn, pose2d_train(:,pose2d_ind)];
                    %         tst_f = [angles2d_val(i,:), pose2d_val(i,pose2d_ind)];
                    
                    Test_input = double(pose2d_val(i,:));
                    
                    %         Input= pose2d_train(ind_orient,1:20);
                    %         Target = pose51(ind_orient,:);
                    %         Test_input = double(pose2d_val(i,1:20));
                    
                    %         if orientation==4
                    %             Input = Input(:, joint_l);
                    %             Test_input = Test_input(joint_l);
                    %         elseif orientation==3
                    %             Input = Input(:, joint_r);
                    %             Test_input = Test_input(joint_r);
                    %         end
                    
                    %         orient_sim = (train_orient==orientation);
                    %         TGPPred = TGPTest_orient(Test_input, Input, double(Target), Param, InvIK , InvOK, orient_sim);
                    TGPPred = TGPTest(Test_input, Input, double(Target), Param, InvIK , InvOK);
                    [TGPKNNError(i), ~] = JointError(TGPPred, test_pose);
                    
                    %%
                    if show_img == 1
                        %         if (TGPKNNError(i)> 83)
                        tmp = repmat(test_pose, size(pose51,1), 1);
                        [err_gt, ~] = JointError(pose51, tmp);
                        [~, ind_gt_match] = min(err_gt);
                        name = [CONF.exp_dir  val.names{i}];
                        im_test = imread(name);
                        %             project3D_2D(im_test,  val.pose96(i,:), skel2d, camera);
                        R = 3;C = R;
                        figure;
                        subplot(R,C,1);imshow(im_test);title(['cat: ', num2str(ii), ', frN: ', num2str(i) ]);title(['err nearest N: ', num2str( TGPKNNError(i))])
                        subplot(R,C,2);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); 
                        rb.render3D(val.pose96(i,:) );title('ground truth')
                        for n = 1:R*C-4
                            % name_neighbor = ['/home/tt/star/h80k/data/train_only/im', num2str(ii),'_', num2str(ind(n)),'.jpg'];
                            name_neighbor = [ training_only{ii}.imagePath,  training_only{ii}.names{ind(n)}];
                            im = imread(name_neighbor);
                            subplot(R, C,n+2);imshow(im);
                        end
                        
                        subplot(R,C,R*C-1);pose_IEF = reshape(pose2d_val(i,:),2,16); plot(pose_IEF(1,:), -pose_IEF(2,:), '*r');axis equal;
                        name_bestMatch = [ training_only{ii}.imagePath,  training_only{ii}.names{ind_gt_match}];
                        subplot(R,C,R*C);
                        %             imshow(imread(name_bestMatch));title(['Best matchInd: ', num2str(find(ind==ind_gt_match))])
                        rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); 
                        rb.render3D(convert_joint51_96(TGPPred));
                        title(['Joint-Err = ',num2str(round(TGPKNNError(i))), ', ind = ', num2str(find(ind==ind_gt_match))])
                    end
                end
                
                err = mean(TGPKNNError(1:N_val));
                error_noise(e) = err;
            end
            error_act(p,q)= err;
        end
    end
end
[min_error, ind_noise]= min(error_noise);
noise(ind_noise)
[min_val, I] = min(error_act(:));
[I_row, I_col]= ind2sub(size(error_act), I)
min_val
[ kwI(I_row,I_col), kwO(I_row,I_col)]


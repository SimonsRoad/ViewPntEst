clc;
close all;
clear all;
show_plots = 0;
addpath(['../twinGaussian/']);
extract_feat = 1;
N_match = 15;
N_match_top = 3;

small_4000;
addpath('./hog_human36m/')
addpath('/home/tt/star/vlfeat-0.9.20/toolbox/')
load([CONF.exp_dir '/name_trainOnly.mat'])
load([ CONF.exp_dir 'training_perActivity.mat']);
load([CONF.exp_dir '/validation.mat']);
root_dir = '/home/tt/star/';
% run([root_dir, '/matconvnet-1.0-beta18/matlab/vl_setupnn.m']);
% net = load([CONF.exp_dir, 'cnn_models/net-gray_standVSnot.mat']);
% w = net.meta.normalization.imageSize(1);
% avg_im = zeros(w,w,3);
% avgrage = net.meta.normalization.averageImage;
% avg_im(:,:,1) = avgrage(1)*ones(w,w);
% avg_im(:,:,2) = avgrage(2)*ones(w,w);
% avg_im(:,:,3) = avgrage(3)*ones(w,w);


ind_joint_bottom = 1:21;
ind_joint_top = 22:51;
Param.kparam1 = 0.2;Param.kparam2 = 2*1e-6;
Param.knn = 400;
Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
addpath('/home/tt/star/h80k/H80Kcode_v1/visualization');
addpath(genpath('/home/t Share/human36m_code/'));
% h_b = round(256*1/3);
h_b_r = 0.4;
% x_b1 = round(1/3*128);
% x_b2 = round(2/3*128);
h_crop = 30;
h_t = round(256*0.2);
x_crop_t = 10;
x_crop = 15;
hog_size = 765;
top_hog = 0;
if top_hog==1
    N_f_top = hog_size;
else
    N_f_top =  4096;
end
N_f_top = 0;
activity_err = zeros(1,15);

for ii= 9:15
    activity = ii;
    trn_path = name_trainOnly{activity}.path;
    train_names = name_trainOnly{activity}.names;
    val = validation{activity};
    N_trn = length(name_trainOnly{activity}.names);
    trn_pose51 = normalize_pose(training_only{activity}.pose96, skel);
    activity_path = ['/home/tt/star/h80k/data/val_imgs/activity_', num2str(activity), '/'];
    val_files = val.names;
    %     load([CONF.exp_dir, '/splitFeat/train_cnnF_topBot_', num2str(ii),'.mat']);
    
    N_val = length(val_files);
    TGPKNNError = zeros(1,N_val);
    val_pose51 = val.pose51;
    
    for tst_frno = 58:N_val
        im_test = imread([ CONF.exp_dir val_files{tst_frno}]);
        tmp = repmat(val_pose51(tst_frno,:), N_trn, 1);
        [err_gt, ~] = JointError(trn_pose51, tmp);
        [TGPKNNError(tst_frno), ind_gt_match] = min(err_gt);
        figure ;
        im_test = imresize(im_test, [128,64]);
        subplot(1,2,1); imshow(im_test);title('test')
        subplot(1,2,2);    im_match = imread([CONF.exp_dir, trn_path, num2str(ind_gt_match),'.jpg']);
        im_match = imresize(im_match, [128,64]);
        imshow(im_match);title('closest match')
        
        
        %{
        if show_plots
            r=4;c=4;
            figure ;
            subplot(r,c,1); imshow(test_crop_t);title('top match')
            for i = 1:r*c-1
                name_top = [CONF.exp_dir, trn_path, num2str(ind_topMatch(i)),'.jpg'];
                subplot(r,c,i+1); imshow(imread(name_top));title(['d= ', num2str( (dist_top(i)))])
            end
            
            figure;subplot(r,c,1); imshow(test_crop_b);title('bottom')
            for i = 1:r*c-1
                name_bottom= [CONF.exp_dir, trn_path, num2str(ind_bottomMatch(i)),'.jpg'];
                subplot(r,c,i+1);imshow(imread(name_bottom));title(['d = ', num2str( (dist_bottom(i)))]);
            end
            
            figure; subplot(r,c,1); imshow(im_test);title('hog')
            for i = 1:r*c-1
                name_hog= [CONF.exp_dir, trn_path, num2str(ind_hog(i)),'.jpg'];
                subplot(r,c,i+1);imshow(imread(name_hog));title(['d = ', num2str( (dist_hog(i)))]);
            end
            
         
            figure ;
            subplot(2,2,1); imshow(im_test);title('test')
            subplot(2,2,3); rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(convert_joint51_96(TGPPred) );
            im_match = imread([CONF.exp_dir, trn_path, num2str(ind_gt_match),'.jpg']);subplot(2,2,2); imshow(im_match);title('closest match')
            title(['estimated, err= ', num2str(round(TGPKNNError(tst_frno)))])
            %         subplot(2,2,2);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(val.pose96(tst_frno,:) );title('actual pose')
        end
        %}
    end
    
    activity_err(activity) = mean(TGPKNNError);
    [activity  activity_err(activity)]
end
mean(activity_err)

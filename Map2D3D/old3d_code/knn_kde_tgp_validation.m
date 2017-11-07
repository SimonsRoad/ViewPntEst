clc;
close all;
% clear all;
load_files = 0
addpath('/home/tt/star/h80k/H80Kcode_v1/visualization');
root_dir = '/home/tt/star/';
addpath(['../twinGaussian/']);
show_img = 0;
small_4000;

if load_files
    addpath(genpath('/home/t Share/human36m_code/'));
    net = load([CONF.exp_dir, 'net-gray_standVSnot.mat']);
    w = net.meta.normalization.imageSize(1);
    avg_im = zeros(w,w,3);
    avgrage = net.meta.normalization.averageImage;
    avg_im(:,:,1) = avgrage(1)*ones(w,w);
    avg_im(:,:,2) = avgrage(2)*ones(w,w);
    avg_im(:,:,3) = avgrage(3)*ones(w,w);
    
    load([CONF.exp_dir 'human36m_big.mat']);
    Param.kparam1 = 0.2;Param.kparam2 = 2*1e-6;Param.knn = 50;
    Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
    files = METADATA.file_names;
    %     load([CONF.exp_dir '/validation.mat']);
    load([CONF.exp_dir '/validation.mat']);
    
    %     load([CONF.exp_dir '/training_only_histEQ.mat']);
    load([CONF.exp_dir, 'training_only_gray.mat']);
    cnnF_train = training_only.cnnFeat';
    hogF_train = training_only.hogFeat;
    pose51 = normalize_pose(training_only.pose96, skel);
end
activity_err = zeros(1,length(files));
activity_err_kde= zeros(1,length(files));
%%
for ii = 1: length(files)
    val = validation{ii};
    val_ind = METADATA.val_indx{ii};
    N_val = length(val_ind);
    val_imPath = val.imagePath;
    TGPKNNError = zeros(1,N_val);
        kde_Error = zeros(1,N_val);
    %%
    parfor i = 1:1:N_val
        name = [CONF.exp_dir  val.names{i}];
        test_pose = val.pose51(i,:);
        im_test =  (imread(name));
        %         feat_test_cnn = val.cnnFeat(i,:)';
        feat_test_cnn = val.cnnFeat_gray(i,:)';
        
        %%
        D = chi2_mex(feat_test_cnn ,  (cnnF_train));[tmpD, ind] = sort(D);
        
        
        Input = hogF_train(ind(1:Param.knn), :);
        hogF_train_n = bsxfun(@times, Input, 1./sum(Input,2));
        
        %%% twin gaussian process
        hog_test = val.hogFeat(i, :);
        hog_test_n = hog_test/sum(hog_test);
        Target = pose51(ind(1:Param.knn), :);
%         [InvIK, InvOK] = TGPTrain(hogF_train_n, double(Target), Param);
%         TGPPred = TGPTest(double(hog_test_n), hogF_train_n, double(Target), Param, InvIK, InvOK);
%         [TGPKNNError(i), ~] = JointError(TGPPred, test_pose);
        
        %         %% kde
        %         tic
                model = H36MBLKde('dim',size(hogF_train_n,2),'IKType','exp_chi2','IKParam',1.7,'Ntex',size(hogF_train_n,1));
                model = model.update( {hogF_train_n}, {Target});
                model = model.train();
                [kde_Pred ~] = model.test({hog_test_n});
                kde_Pred = kde_Pred - repmat(kde_Pred(1:3), 1, 17); % center the prediction
                [kde_Error(i), ~] = JointError(kde_Pred, test_pose);
        %         kde_time = toc
        %%
        %         if show_img==1
        %             R = 3;C = 3;
        %             figure;subplot(R,C,1);imshow(im_test);title(['category: ', num2str(ii), ', frameNo: ', num2str(i), ', knn= ', num2str(Param.knn)])
        %             subplot(R,C,2);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(val.pose96(i,:) );
        %             error = zeros(1, R*C-1);
        %             for n = 1:R*C-3
        %                 name_neighbor = [CONF.exp_dir ,'train_clusters/all/', 'im',num2str(training_only.category(ind(n))), '_', num2str(training_only.im_ind(ind(n))) ,'.jpg'];im = imread(name_neighbor);
        %                 %                 name_neighbor = im_names_train{ind(n)};   im = imread([CONF.exp_dir ,'train_clusters/', name_neighbor]);
        %                 pose_neighbor = pose51(ind(n),:);
        %                 subplot(R, C,n+2);imshow(im);
        %             end
        %             subplot(R,C,R*C);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(convert_joint51_96(TGPPred));
        %             title(['Joint dist Err = ',num2str(round(TGPKNNError(i)))])
        %         end
        
    end
%     activity_err(ii) = mean(TGPKNNError(1:N_val));
    activity_err_kde(ii) = mean(kde_Error(1:N_val));
    
    
    [activity_err_kde(ii) , ii]
end
mean(activity_err_kde)

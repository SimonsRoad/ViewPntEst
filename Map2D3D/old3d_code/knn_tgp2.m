clc;close all;
clear all
root_dir = '/home/tt/star/';
addpath(['../twinGaussian/']);
load_files = 1;
show_img = 1;
small_4000; % config file
if load_files
    load([CONF.exp_dir, '/train_annot.mat']);
    load([CONF.exp_dir, '/train_3dposes_96.mat']);
    pose51 = train_annot.images.pose51;
    hog_feats = train_annot.images.hogFeat;
    trn_cnnF = train_annot.images.cnnFeat;
    im_names_train = train_annot.images.name;trn_cnnF = single(trn_cnnF);
    %%
    run([root_dir, '/matconvnet-1.0-beta18/matlab/vl_setupnn.m']);
    model_path = ['./matconvnet-vgg-f_fullImage/']; net = load([model_path, 'net-deployed.mat']);
    index_test = find(train_annot.images.set==2);
    index_train = find(train_annot.images.set==1);
    N_train = length(index_train);
    N_test = length(index_test);
    w = net.meta.normalization.imageSize(1);
    avg_im = zeros(w,w,3);
    avgrage = net.meta.normalization.averageImage;
    avg_im(:,:,1) = avgrage(1)*ones(w,w); avg_im(:,:,2) = avgrage(2)*ones(w,w); avg_im(:,:,3) = avgrage(3)*ones(w,w);
    %% Initialization
    Param.kparam1 = 0.2;Param.kparam2 = 2*1e-6;
    Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
    Param.knn = 100;
    N = length(index_test);
    TGPKNNError = zeros(1, N);
    %     TGPKNNError_96 = zeros(1, N);
    sub_pose51 = pose51; sub_pose51(index_test,:) = [];
    sub_trn_cnnF = trn_cnnF; sub_trn_cnnF(index_test,:)= [];
    sub_hog_feats = hog_feats;sub_hog_feats(index_test,:)= [];
    sub_names = im_names_train; sub_names(index_test) = [];
end

%%
for i = 190:N
    name = im_names_train{index_test(i)};
    test_pose = pose51(index_test(i),:);
%     im_test = imread([CONF.exp_dir, '/train_clusters/', name]);
    im_test = imread('/home/tt/star/h80k/data/val_imgs/activity_1/im_31.jpg');
    im_ =  single(imresize(im_test, [w, w]));im_ = bsxfun(@minus,im_, avg_im);
    res = vl_simplenn(net, im_) ;
    feat_test = squeeze(res(18).x)';
    scores = squeeze(gather(res(end).x)) ;[bestScore, best] = max(scores);
    
    D = chi2_mex(feat_test', sub_trn_cnnF');
    %     D = pdist2(feat_test, sub_trn_cnnF);
    [tmpD, ind] = sort(D);
    
    %% twin gaussian process
    Input = sub_hog_feats(ind(1:Param.knn), :);
    norm_in = sqrt(sum(Input.^2, 2));
    Input = bsxfun(@times, Input, 1./norm_in);
    feat_test = hog_feats(index_test(i), :);feat_test = feat_test/norm(feat_test);
    Target = sub_pose51(ind(1:Param.knn), :);
    [InvIK, InvOK] = TGPTrain(Input, double(Target), Param);
    TGPPred = TGPTest(double(feat_test), Input, double(Target), Param, InvIK, InvOK);
    [TGPKNNError(i), ~] = JointError(TGPPred, test_pose);
    
    %%
    if show_img
        %         subplot(132);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(train_3dposes_96(index_test(i),:));
        R = 3;C = 3;
        figure;subplot(R,C,1);imshow(im_test);
        title(sprintf('%s (%d), score %.3f',net.meta.classes.description{best}, best, bestScore), 'Interpreter', 'none') ;
        error = zeros(1, R*C-1);
        for n = 1:R*C-2
            name_neighbor = sub_names{ind(n)};
            im = imread([CONF.exp_dir ,'train_clusters/', name_neighbor]);
            pose_neighbor = sub_pose51(ind(n),:);
            Dm = zeros(size(pose_neighbor,1), size(test_pose,2)/3);
            for p=1:size(test_pose,2)/3
                Dm(p) = sqrt(sum((pose_neighbor(:,(p-1)*3+1:p*3) - test_pose(:,(p-1)*3+1:p*3) ).^2 ,2));
            end
            error(n) = mean(Dm,2);
            label= sprintf('Dist:%d, Err = %d ',  round(tmpD(n)),  round(error(n)));
            subplot(R, C,n+1);imshow(im);title(label)
        end
        subplot(R,C,R*C);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(convert_joint51_96(TGPPred));
        title(['Joint dist Err = ',num2str(TGPKNNError(i)), '(mm)'])
    end
end
mean(TGPKNNError(1:N))

clc;
close all;
root_dir = '/home/tt/star/';
addpath(['../twinGaussian/']);
load_files = 1;

if load_files
    load('./HOG/h80k_imdb.mat');
    run([root_dir, '/matconvnet-1.0-beta18/matlab/vl_setupnn.m']);
    model_path = ['./matconvnet-vgg-f_fullImage/'];
    net = load([model_path, 'net-deployed.mat']);
    load('./matFiles/imdb_h80k.mat');
    training = load('./matFiles/h80k_training_pose_name.mat');
    index_test = find(images.set==2);
    index_train = find(images.set==1);
    N_train = length(index_train);
    N_test = length(index_test);
    % test_names=load('h80k_test_names.mat', 'names');
    w = net.meta.normalization.imageSize(1);
    avg_im = zeros(w,w,3);
    avgrage = net.meta.normalization.averageImage;
    avg_im(:,:,1) = avgrage(1)*ones(w,w);
    avg_im(:,:,2) = avgrage(2)*ones(w,w);
    avg_im(:,:,3) = avgrage(3)*ones(w,w);
    small_4000; % config file
    load([CONF.exp_dir, '/train_CNN_feats.mat']);
    load([CONF.exp_dir, '/train_3dposes_96.mat']);
    load([CONF.exp_dir, '/train_3dposes_51.mat']);
    train_3dposes_51 = train_3dposes;
    clear train_3dposes;
    train_CNN_feats = single(train_CNN_feats);
end
% Initialization
Param.kparam1 = 0.2;
Param.kparam2 = 2*1e-6;
Param.kparam3 = Param.kparam2;
Param.lambda = 1e-3;
Param.knn = 1000;
% samples = randi([1,length(index_test)], 1,5)
N = length(index_test);
TGPKNNError = zeros(1, N);
TGPKNNError_96 = zeros(1, N);
show_img = 0;

for i = 1:N
    name = images.name{index_test(i)};
    tmp = ['../training_imgs', name(11:end)];
    index = find(strcmp(training.names ,tmp));
    if ~isempty(index)
        target_pose = training.pose_matrix(index,:);
    else
        tmp = ['../training_imgs/', name(13:end)];
        index = find(strcmp(training.names ,tmp));
        target_pose = training.pose_matrix(index,:);
        target_pose(1:3:51) = -target_pose(1:3:51);
    end
    target_pose_96 = train_3dposes_96(index_test(i),:);
    im_test = imread([CONF.exp_dir, '/train_clusters/', name]);
    im_ =  single(imresize(im_test, [w, w]));im_ = bsxfun(@minus,im_, avg_im);
    res = vl_simplenn(net, im_) ;
    feat_test = squeeze(res(18).x)';
    scores = squeeze(gather(res(end).x)) ;[bestScore, best] = max(scores) ;
    %     D = chi2_mex(feat_test', train_CNN_feats');
    D = pdist2(feat_test, train_CNN_feats);
    [tmpD, ind] = sort(D);
    
    %% twin gaussian process
    Input = hog_feats(index_train(ind(1:Param.knn)), :);
    norm_in = sqrt(sum(Input.^2, 2));
    Input = bsxfun(@times, Input, 1./norm_in);
    feat_test = hog_feats(index_test(i), :);feat_test = feat_test/norm(feat_test);
    Target = train_3dposes_51(ind(1:Param.knn), :);
    [InvIK, InvOK] = TGPTrain(Input, double(Target), Param);
    TGPPred = TGPTest(double(feat_test), Input, double(Target), Param, InvIK, InvOK);
    [TGPKNNError(i), ~] = JointError(TGPPred, target_pose);
    target_pose_96 = target_pose_96 - repmat(target_pose_96(:,1:3),[1 32]);
    [TGPKNNError_96(i), ~] = JointError(convert_joint51_96(TGPPred),  target_pose_96);
%     figure;subplot(131);imshow(im_test)
%     subplot(132);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(target_pose_96);
%     subplot(133);rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(convert_joint51_96(TGPPred));
    
    %%
    if show_img
        figure;subplot(331);imshow(im_test);title(sprintf('%s (%d), score %.3f',net.meta.classes.description{best}, best, bestScore), 'Interpreter', 'none') ;
        error = zeros(1, 8);
        for n = 1:8
            name_neighbor = images.name{index_train(ind(n))};
            im = imread(['/home/t/h80k/cnn_data/full_images/', name_neighbor]);
            tmp = ['../training_imgs', name_neighbor(11:end)]; index = find(strcmp(training.names ,tmp));
            if ~isempty(index)
                est_pose = training.pose_matrix(index,:);
            else
                tmp = ['../training_imgs/', name_neighbor(13:end)];
                index = find(strcmp(training.names ,tmp));
                est_pose = training.pose_matrix(index,:);
                est_pose(1:3:51) = -est_pose(1:3:51);
            end
            Dm = zeros(size(target_pose,1), size(target_pose,2)/3);
            for p=1:size(target_pose,2)/3
                Dm(p) = sqrt(sum((est_pose(:,(p-1)*3+1:p*3) - target_pose(:,(p-1)*3+1:p*3) ).^2 ,2));
            end
            error(n) = mean(Dm,2);
            
            label= sprintf('featDist:%d, Err = %d ',  round(tmpD(n)),  round(error(n)));
            subplot(3,3,n+1);imshow(im);title(label)
        end
    end
end
mean(TGPKNNError(1:N))
mean(TGPKNNError_96(1:N))

%{
clear all;
clc;close all;
addpath('/home/t Share/h80k/util/')
trn_extract = 1;val_extract = 1;
run(['/home/tt/star//matconvnet-1.0-beta18/matlab/vl_setupnn.m']);
root_dir = '/home/tt/star/h80k/data/';
category_name =  {'a_0', 'a_45', 'a_90', 'a_135', 'a_180', 'a_225', 'a_270', 'a_315'};
N_cat = length(category_name);
names_bin = cell(1, N_cat);
N_tr_cat = 200;N_tst_cat = 100;
% modelpath = '/imagenet-vgg-verydeep-16.mat';net = load([root_dir '/preTrainedNets/' modelpath]);
net = load('./net-trn_Only.mat');
l = 19;

if trn_extract
    im_folder = 'trn_Only_8bin_fullBody/';
    trn = extractDeepFeat(net, l, im_folder, category_name, N_tr_cat, root_dir);
    save([root_dir 'deepFeat_trnOnly.mat'], '-struct','trn')
else
    trn=load([root_dir 'deepFeat_trnOnly.mat']);
end

%% val
im_folder = 'val_8bin_fullBody/';
if val_extract
    val = extractDeepFeat(net, l, im_folder, category_name, N_tst_cat, root_dir);
    save([root_dir 'deepFeat_val.mat'], '-struct', 'val');
else
    val=load([root_dir 'deepFeat_val.mat']);
end
%}
%%
R = 3; C=2;k=10;ind = randperm(800);
for i =1:10
    mm = ind(i);
    D = chi2_mex(val.deepFeat(mm,:)', trn.deepFeat');[tmpD, ind_cnn] = sort(D);
    est_label = mode(trn.label(ind_cnn(1:k)));
    im = imread([   val.names{mm}]);
    figure;subplot(R,C,1);imshow(im);title(['gt: ', num2str(val.label(mm)), 'est: ', num2str(est_label)])
    %%
    n=1;
    subplot(R,C,n+1)
    name_neighbor=[  trn.names{ind_cnn(n)}];im_n = imread(name_neighbor);imshow(im_n);
    n =2;
    subplot(R,C,n+1)
    name_neighbor=[  trn.names{ind_cnn(n)}];
    im_n = imread(name_neighbor);imshow(im_n);
    
    n =3;
    subplot(R,C,n+1)
    name_neighbor=[ trn.names{ind_cnn(n)}];
    im_n = imread(name_neighbor);imshow(im_n);
    
    %%
        D_s = chi2_mex(val.deepFeat_s(mm,:)', trn.deepFeat_s');[tmpD, ind_cnn_s] = sort(D_s);
    est_label_s = mode(trn.label(ind_cnn_s(1:k)));
        n = 4;
    subplot(R,C,n+1)
    name_neighbor=[ trn.names{ind_cnn_s(n)}];
    im_n = imread(name_neighbor);imshow(im_n);title(['est: ', num2str(est_label_s)])
    
            n = 5;
    subplot(R,C,n+1)
    name_neighbor=[ trn.names{ind_cnn_s(n)}];
    im_n = imread(name_neighbor);imshow(im_n);
end

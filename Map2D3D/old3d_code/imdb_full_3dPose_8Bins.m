clc;close all;
clear all
% load('Z_ward_max_leg_neck_feet.mat');
% load('h80k_training_pose_name.mat');
w = 128; h = 256;
load_resize = 1;

% root_dir = '/home/t/h80k/cnn_data/';
root_dir = '/home/tt/star/h80k/data/';
category_name =  {'a_0', 'a_45', 'a_90', 'a_135', 'a_180', 'a_225', 'a_270', 'a_315'};
N_cat = 1;%length(category_name);
names_bin = cell(1, N_cat);
names_train=[];label_train = [];
label_test = [];
names_test=[];
% N_tr_cat = 2000;
% N_tst_cat = 43;
load('../cluster_8bin_pose.mat')%, '-struct', 'annot')
N_tr_cat = 2500;
N_tst_cat = size(pose_all{1},1)- N_tr_cat-1;


for c =1:N_cat
    %         dir_path = [root_dir, 'trn_lowerB_8bins/' category_name{c}];
    %         files = dir( [dir_path ,'/*.jpg']);
    %         N = length(files);
    %         names = cell(1,N);
    %         for i = 1:N
    %             names{i} = fullfile('/trn_lowerB_8bins/', category_name{c}, files(i).name);
    %         end
    ind = randperm(counter(c)-1);
    names_all{c} = names_all{c}(ind);
    pose_all{c} = pose_all{c}(ind,:);
    names_train = [names_train; names_all{c}(1:N_tr_cat)];
    label_train = [label_train; pose_all{c}(1:N_tr_cat,:)];
    
    names_test = [names_test; names_all{c}(N_tr_cat+1:N_tr_cat+ N_tst_cat)];
    label_test = [label_test; pose_all{c}(N_tr_cat+1:N_tr_cat+ N_tst_cat,:)];
end




%% create imdb

N_tr = N_cat*N_tr_cat;
ind_permute = randperm(N_tr);
names_train = names_train(ind_permute);
label_train = label_train(ind_permute,:);

%% test
N_tst = N_cat*N_tst_cat;
ind_permute = randperm(N_tst);
names_test = names_test(ind_permute);
label_test = label_test(ind_permute,:);

imdb.meta.sets = {'train', 'val'} ;
imdb.images.set = cat(2, ones(1, length(names_train)), 2*ones(1, length(names_test)));
imdb.images.label = cat(1,label_train, label_test);
imdb.images.name = cat(1, names_train, names_test);
imdb.classes.name = category_name;
imdb.imageDir= '/home/t/h80k/cnn_data/';
% save([  '../imdb_h80k_fullReg.mat'] ,'-struct', 'imdb')
save([  '../imdb_h80k_3dPose_view1.mat'] ,'-struct', 'imdb')



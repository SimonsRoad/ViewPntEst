clc;close all;
clear all
% load('Z_ward_max_leg_neck_feet.mat');
% load('h80k_training_pose_name.mat');
w = 128; h = 256;
load_resize = 1;

root_dir = '/home/t/h80k/cnn_data/';
% root_dir = '/home/tt/star/h80k/data/';
category_name =  {'a_0', 'a_45', 'a_90', 'a_135', 'a_180', 'a_225', 'a_270', 'a_315'};
N_cat = length(category_name);
names_bin = cell(1, N_cat);
names_train=[];label_train = [];
label_test = [];
names_test=[];
N_tr_cat = 862;
% N_tr_cat = 892;
N_tst_cat = 400;
category=[1, 3, 5, 7];
 trn_folder = 'trn_Only_8bin_fullBody/';
tst_folder = 'reduced_val_8bin_fullBody/';

for c = 1:length(category)
    dir_path = [root_dir, trn_folder category_name{category(c)}];
    files = dir( [dir_path ,'/*.jpg']);
    N = length(files);
    names = cell(1,N+15);
    for i = 1:N
        names{i} = fullfile(trn_folder, category_name{category(c)}, files(i).name);
    end
      for i = N:N+15
        names{i} = fullfile(trn_folder, 'sample' category_name{category(c)}, files(i).name);
    end
    names_bin{c} = names(randperm(length(names)));
    names_train = [names_train names_bin{c}(1:N_tr_cat)];
    label_train = [label_train c*ones(1,N_tr_cat)];
end

%%val
for c = 1:length(category)
    dir_path = [root_dir, tst_folder category_name{category(c)}];
    files = dir( [dir_path ,'/*.jpg']);
    N = length(files);
    names = cell(1,N);
    for i = 1:N
        names{i} = fullfile(tst_folder, category_name{category(c)}, files(i).name);
    end
    names_bin{c} = names(randperm(length(names)));
    names_test = [names_test names_bin{c}(1: N_tst_cat)];
    label_test = [label_test c*ones(1, N_tst_cat)];
end
%% create imdb
% N_tr = N_cat*N_tr_cat;
N_tr = length(category)*N_tr_cat;
ind_permute = randperm(N_tr);
names_train = names_train(ind_permute);
label_train = label_train(ind_permute);

%% test
% N_tst = N_cat*N_tst_cat;
N_tst = length(category)*N_tst_cat;
ind_permute = randperm(N_tst);
names_test = names_test(ind_permute);
label_test = label_test(ind_permute);

imdb.meta.sets = {'train', 'val'} ;
imdb.images.set = cat(2, ones(1, length(names_train)), 2*ones(1, length(names_test)));
imdb.images.label = cat(2,label_train, label_test);
imdb.images.name = cat(2, names_train, names_test);
imdb.classes.name = category_name;
imdb.imageDir= '/home/t/h80k/cnn_data/';
save([  '../imdb4v_sampleVal_center_trnVal.mat'] ,'-struct', 'imdb')
disp([  '../imdb4v_h80k_center_trnVal.mat'])



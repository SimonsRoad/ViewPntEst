clc;close all;
clear all
root_dir = '/home/t/h80k/cnn_data/';
% root_dir = '/home/tt/star/h80k/data/';
category_name =  {'a_0', 'a_45', 'a_90', 'a_135', 'a_180', 'a_225', 'a_270', 'a_315'};
N_cat = length(category_name);
names_bin = cell(1, N_cat);
names_train=[];label_train = [];label_test = [];names_test=[];
N_tr_cat = 120;
% N_tr_cat = 760;
N_tst_cat = 100;
category=[1:8];
trn_folder = [  'old_nets/trn_Only_8bin_fullBody/'] ;
% trn_folder = 'trn_Only_crop_8bin_fb/';
% tst_folder = 'val_8bin_crop_fb/';
tst_folder =  'old_nets/val_8bin_fullBody/';  
path_ext1 = 'synth_NonCentred/fem1/';
path_ext2 = 'synth_NonCentred/male1/';
for c = 1:length(category)
    dir_path = [root_dir, trn_folder category_name{category(c)}];
    files = dir( [dir_path ,'/*.jpg']);
    N = length(files);     names = cell(1,N);
    for i = 1:N
        names{i} = fullfile(trn_folder, category_name{category(c)}, files(i).name);
    end
    names_bin{c} = names(randperm(length(names)));
    
    %%
    files_ext = dir( [root_dir, path_ext1, category_name{category(c)} ,'/*.jpg']);
    M = length(files_ext);  
    names_ext = cell(1,M);
    for i = 1:M
        names_ext{i} = fullfile( path_ext1 , category_name{category(c)}, files_ext(i).name);
    end
    names_bin_ext{c} = names_ext(randperm(length(names_ext)));
    
        %%
    files_ext2 = dir( [root_dir, path_ext2, category_name{category(c)} ,'/*.jpg']);
    M = length(files_ext2);  
    names_ext2 = cell(1,M);
    for i = 1:M
        names_ext2{i} = fullfile( path_ext2 , category_name{category(c)}, files_ext2(i).name);
    end
    names_bin_ext2{c} = names_ext2(randperm(length(names_ext2)));
    
    %%
    M = 700;
    %     names_train = [names_train names_bin{c}(1:N_tr_cat)];
    names_train = [names_train [names_bin{c}(1:N_tr_cat) names_bin_ext{c}(1:M) names_bin_ext2{c}(1:M) ]];
    label_train = [label_train c*ones(1,N_tr_cat + 2*M)];
end

%%val
for c = 1:length(category)
    dir_path = [root_dir, tst_folder category_name{category(c)}];
    files = dir( [dir_path ,'/*.jpg']);N = length(files);names = cell(1,N);
    for i = 1:N
        names{i} = fullfile(tst_folder, category_name{category(c)}, files(i).name);
    end
    names_bin{c} = names(randperm(length(names)));
    
    names_test = [names_test names_bin{c}(1: N_tst_cat)];
    label_test = [label_test c*ones(1, N_tst_cat)];
end
%% create imdb
N_tr = length(names_train);
% N_tr = length(category)*N_tr_cat;
ind_permute = randperm(N_tr);
names_train = names_train(ind_permute);
label_train = label_train(ind_permute);

%% test
N_tst = length(names_test);
% N_tst = length(category)*N_tst_cat;
ind_permute = randperm(N_tst);
names_test = names_test(ind_permute);
label_test = label_test(ind_permute);

imdb.meta.sets = {'train', 'val'} ;
imdb.images.set = cat(2, ones(1, length(names_train)), 2*ones(1, length(names_test)));
imdb.images.label = cat(2,label_train, label_test);
imdb.images.name = cat(2, names_train, names_test);
imdb.classes.name = category_name;
imdb.imageDir= '/home/t/h80k/cnn_data/';
% save([  '/home/t/h80k/cnn_data/imdb2_Male_8bin_fB_trnVal.mat'] ,'-struct', 'imdb')
% save([  '/home/t/h80k/cnn_data/imdb_8bin_trn_CVal.mat'] ,'-struct', 'imdb')
save([  '/home/t/h80k/cnn_data/imdb_lessD_synFM_valFM.mat'] ,'-struct', 'imdb')




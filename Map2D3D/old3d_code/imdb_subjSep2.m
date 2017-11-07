clc;close all;
clear all
root_dir = '/home/t/h80k/cnn_data/';
category_name =  {'a_0', 'a_45', 'a_90', 'a_135', 'a_180', 'a_225', 'a_270', 'a_315'};
N_cat = length(category_name);
names_bin = cell(1, N_cat);
names_train=[];label_train = [];label_test = [];names_test=[];
N_tr_cat = 800;
N_tst_cat = 100;

trn_folder = 'imgs/trn_Only_crop_8bin_fb/';
tst_folder = 'imgs/val_8bin_crop_fb/';

% tst_folder =  'imgs/val_8bin_fullBody/';
% trn_folder = [  'imgs/trn_Only_8bin_fullBody/'] ;
path_synth = 'imgs/synth_centred/';
for c = 1: N_cat
    dir_path = [root_dir, trn_folder category_name{c}];
    files = dir( [dir_path ,'/*.jpg']);
    N = length(files);     names = cell(1,N);
    for i = 1:N
        names{i} = fullfile(trn_folder, category_name{c}, files(i).name);
    end
    names_bin{c} = names(randperm(length(names)));
    
    names_train = [names_train [names_bin{c}(1:N_tr_cat)   ]];
    label_train = [label_train c*ones(1,N_tr_cat)];
end

subjs = dir([root_dir path_synth]);
dirFlags = [subjs.isdir];
subjs = subjs(dirFlags);
for s =1:length(subjs)
    if subjs(s).name(1)=='.'
        continue;
    end
    path_ext = [path_synth, subjs(s).name ,'/' ]
    for c = 1:N_cat
        files_ext = dir( [root_dir, path_ext, category_name{c} ,'/*.jpg']);
        M = length(files_ext);
        names_ext = cell(1,M);
        for i = 1:M
            names_ext{i} = fullfile( path_ext , category_name{c}, files_ext(i).name);
        end
        names_bin_ext{c} = names_ext(randperm(length(names_ext)));
        M = 20;
        names_train = [names_train names_bin_ext{c}(1:M)];
        label_train = [label_train c*ones(1,M)];
    end
end


%%val
M_val = 300;

for c = 1: N_cat
    dir_path = [root_dir, tst_folder category_name{c}];
    files = dir( [dir_path ,'/*.jpg']);N = length(files);names = cell(1,N);
    for i = 1:N
        names{i} = fullfile(tst_folder, category_name{c}, files(i).name);
    end
    names_bin{c} = names(randperm(length(names)));
    
    names_test = [names_test names_bin{c}(1: N_tst_cat)];
    label_test = [label_test c*ones(1, N_tst_cat)];
    
    names_train = [names_train names_bin{c}(N_tst_cat+1:N_tst_cat+M_val)];
    label_train = [label_train c*ones(1,M_val)];
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
save([  '/home/t/h80k/cnn_data/imdb_Cent_subjSep_synth.mat'] ,'-struct', 'imdb')




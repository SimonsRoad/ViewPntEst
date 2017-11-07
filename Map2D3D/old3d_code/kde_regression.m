clc;close all;
addpaths;
load('feature_Example.mat'); %'hog_train' ,'pose_train'
hog_train_n =  bsxfun(@rdivide, hog_train, sum(hog_train,2));  %nx765

model = H36MBLKde('dim',size(hog_train_n,2),'IKType','exp_chi2','IKParam',1.7,'Ntex',size(hog_train_n,1));
model = model.update( {hog_train_n}, {pose_train});
model = model.train();
% model.save([directory filename '.mat']);
% 'H36MBLKde__alpha_test__trial_0001's
load('test_feature.mat'); % 'hog_test', 'pose_target'
hog_test_n =  bsxfun(@rdivide, hog_test, sum(hog_test,2));  %nx765
[Pred model] = model.test({hog_test_n});



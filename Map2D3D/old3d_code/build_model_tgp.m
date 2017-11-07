close all;clc;
clear all;

small_4000; % config file

load([CONF.exp_dir 'human36m_big.mat'])
load([CONF.exp_dir '/training_only.mat']);
label = {'back', 'forward', 'right', 'left'};
 
addpath(['../twinGaussian/']);
load([CONF.exp_dir '/training_only.mat']);
% Param.kparam1 = 0.2;
Param.kparam2 = 2*1e-6;
Param.kparam3 = Param.kparam2; Param.lambda = 1e-3;
Param.kparam1 = Param.kparam2;
TGP = cell(1, length(METADATA.file_names));
for ii= 1:length(METADATA.file_names)
    
    activity= sprintf('ActivitySpecific_%02d.mat', ii);
    orient = training_only{ii}.orient;
    pose2d = training_only{ii}.pose2d;
    tmp = reshape(pose2d', 2, 32, size(pose2d,1));
    m = bsxfun(@minus, tmp, tmp(:,1,:));
    pose2d_n = reshape(m,64, size(pose2d,1))';
    pose2d_n = pose2d_n(:,ind_joint_2d);
    
    pose3d = normalize_pose(training_only{ii}.pose96, skel);
     [InvIK, InvOK] = TGPTrain(pose2d_n, double(pose3d), Param);
%     InvIK = cell(1,4);
%     InvOK = cell(1,4);
%     for i = 1:4
%         ind = find(orient==i);
%         X = pose2d_n(ind,:);
%         Y = pose3d(ind,:);
%         [InvIK{i}, InvOK{i}] = TGPTrain( X, double(Y), Param);
%     end
   TGP{ii}.InvIK_all = InvIK;
    TGP{ii}.InvOK_all = InvOK; 
end

save([CONF.exp_dir '/regModel_all.mat'], 'TGP');
disp(' regressionModel done :)')


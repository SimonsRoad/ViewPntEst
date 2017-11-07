% uncomment and adapt the line below depending on where you want your data
% directory = '../H80K/';
% if ~exist('directory','var')
%   directory = './H80K/';
% end
clc;close all;
% setup the dataset
% if ~exist('expdir.txt','file'); setup_dataset(directory); end
small_4000; % config file
addpath('/home/t Share/h80k/util');
% % ind_joint_2d = [1:8, 13:18, 25:28, 31:32, 35:40, 51:56];
% addpaths;
CONF.exp_dir = '/home/tt/star/previous_code/h80k/data/'
small_4000;
%% load some files
rgb = matfile([CONF.exp_dir 'DenseFeatures' filesep 'RGB' filesep 'ActivitySpecific_01.mat']);
gtpl = matfile([CONF.exp_dir 'DenseFeatures' filesep 'GTPL' filesep 'ActivitySpecific_01.mat']);
gtfgm = matfile([CONF.exp_dir 'DenseFeatures' filesep 'GTFGM' filesep 'ActivitySpecific_01.mat']);
gtd3p = matfile([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep 'ActivitySpecific_01.mat']);
gtd2p = matfile([CONF.exp_dir 'DenseFeatures' filesep 'GTD2P' filesep 'ActivitySpecific_01.mat']);
%% show a frame
frno = 10;
figure;
im = cell2mat(rgb.Ftrain(frno,1));
pose3D = gtd3p.Ftrain(frno,:);
%%
pose2D = gtd2p.Ftrain(frno,:);
pose2D = pose2D(ind_joint_2d);
pose2D_ief = convert2IEF(pose2D);
pose2D_centered = bsxfun(@minus, pose2D_ief, pose2D_ief(:,7,:));

%%
figure
subplot(131);imshow(im);
% subplot(142); imshow(ind2rgb(cell2mat(gtpl.Ftrain(frno,1)),CONF.cmap));
subplot(132);plot_pose_stickmodel(pose2D_centered');axis equal; axis off;title('2D')
% subplot(143); plot(pose2D_ief(1,:), -pose2D_ief(2,:), '*r');axis equal; axis off;
% subplot(143); imshow(cell2mat(gtfgm.Ftrain(frno,1))); axis equal; axis off;
subplot(133); rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right'); rb.render3D(pose3D); axis equal; axis off;title('3D')
%% flip image
im_flip = fliplr(im);
pose_flip = pose3D; pose_flip(1:3:end) = -pose_flip(1:3:end);
figure;
subplot(121); imshow(im_flip);
subplot(122);  rb.render3D(pose_flip);


%% generate a submission file
% first generate basic results files like the average
files = get_metadata('human36m_big','file_names');
Poses = [];
for i = 1: length(files)
    load([CONF.exp_dir 'GlobalFeatures' filesep 'GTD3P' filesep files{i}],'Ftrain');
    Poses = [Poses; Ftrain];
end
size(Poses,1)
% center the poses then compute the average of the training set
Poses = Poses - repmat(Poses(:,1:3),[1 32]); Pred = mean(Poses);

% compute a prediction feature 'Average' in the format for Human80KSumit
mkdir([CONF.exp_dir 'GlobalFeatures' filesep 'Average']);
for i = 1: length(files)
    Ftest = repmat(Pred,[get_metadata('human36m_big','test_frame_count',i),1]);
    Ftest(1,1:10)
    save([CONF.exp_dir 'GlobalFeatures' filesep 'Average' filesep files{i}],'Ftest','-v7.3');
end

% WARNING! Please do not change the file name! __trial_0001.results needs
% to be there for our evaluation to interpret the file correctly!
H80KSubmit('Average');
% The server submission result should be 231.60

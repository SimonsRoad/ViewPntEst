clc;close all;
% clear all
% small_4000;
% % load([CONF.exp_dir 'h80k_trnOnly_P23.mat']);
% load([CONF.exp_dir 'h80k_trnVal_P23Name.mat'])
% %kmeans on poses
% tic; % Start stopwatch timer
% [idx,C,sumd,D] = kmeans(pose3d_matrix(:,4:end),50,'Options',statset('UseParallel',1),'MaxIter',10000,...
%     'Display','final','Replicates',10);
% toc % Terminate stopwatch timer
% save('clusters.mat', 'idx', 'C')
% addpath('./util/')
% rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right');
k=50;
no_pnts = zeros(1,k);
for i=1:k
    no_pnts(i) = length(find(idx==i));
end
figure
for i=1:16
    subplot(4,4,i)
    rb.render3D(convert_joint51_96(C(i,:)));title(num2str(no_pnts(i)))
%     a = C(1,:)-C(3,:);d = sum(a.^2)
end
figure
for i=1:16
    subplot(4,4,i)
    rb.render3D(convert_joint51_96(C(i+16,:)));title(num2str(no_pnts(i+16)))
end
n=2
figure
for i=1:16
    subplot(4,4,i)
    rb.render3D(convert_joint51_96(C(i+n*16,:)));title(num2str(no_pnts(i+n*16)))
end

n=3
figure
for i=1:2
    subplot(4,4,i)
    rb.render3D(convert_joint51_96(C(i+n*16,:)));title(num2str(no_pnts(i+n*16)))
end

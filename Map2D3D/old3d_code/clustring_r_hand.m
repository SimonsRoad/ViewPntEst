clc;close all;
clear all;
% [ind, tmpD] = knnsearch( pose_matrix_sel(11:end,:), pose_matrix_sel(10,:)  ,'k', 100, 'distance', JointError2);
small_4000;
addpath('/home/tt/star/spectral_Buhler/')
load([CONF.exp_dir, 'h80k_training_pose_name.mat']);load([CONF.exp_dir 'Z_ward_max_leg_neck_feet.mat']);
id_standing = find(idx == 3);
name_standing = names(id_standing);
% find(~isempty(strfind(names, '../training_imgs/im1_2.jpg')))
pose_standing = pose_matrix(id_standing,:);
H = pose_standing(:,11) - pose_standing(:,32); H= H/10;
H_n = 140;  ratio = H_n./H;
% pose_standing = bsxfun(@times, pose_standing, ratio);
H2 = pose_standing(:,11) - pose_standing(:,32); H2= H2/10;
pose_standing = round(pose_standing);
joints = [4:51];    R=4;C=R;
pose_matrix_sel = pose_standing(:,joints);
N = size(pose_matrix_sel,1);
N_c = 7;
%%
% D = pdist(pose_matrix_sel, @JointError2);
% W = squareform(1./D); 
% W_t =  sparse(double(W));
% [clusters, cuts, cheegers] = OneSpectralClustering(W_t, 'ncc', N_c);
%% cluster the data--> kmeans
close all
[clusters, centers] = kmeans(pose_matrix_sel, N_c); 
for cluster_no = 1:N_c
    ind = find(clusters==cluster_no);
    [cluster_no, length(ind)]
% tmp = repmat(centers(cluster_no,:) , N, 1 ); D = JointError2(pose_matrix_sel , tmp);[tmpD, ind] = sort(D);
    figure;
    for i=1:R*C
        im_name = name_standing{ind(i)};
        subplot(R,C,i);
        imshow(imread([CONF.exp_dir im_name(3:end)]));%     title(['H = ', num2str(H(ind(100)+10)), ', d=', num2str(tmpD(i))])
    end
end
%%
Z = linkage(pose_standing,'single', '@JointError2');
% Z = linkage(pose_standing,'ward','euclidean');
close all
NC = 3;
% load('Z_cosine.mat')
c = cluster(Z, 'maxclust', NC);idx = c;
R=4;C=4;
for i =1:NC
    group = find(idx== i);
    figure(i)
    for j=1:R*C
        index = randi([1, length(group)], 1, R*C);
        name = name_standing{group(index(j))};name = name(3:end);subplot(R,C,j);imshow(imread([CONF.exp_dir name]))
        title(num2str(length(group)))
    end
end



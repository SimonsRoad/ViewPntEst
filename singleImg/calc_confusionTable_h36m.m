clear all
clc;close all;
run(fullfile(fileparts(mfilename('fullpath')), ...
    '..', '..', 'matlab', 'vl_setupnn.m'))
% net = load('/home/h80k/cnn_data/net_noBN_f_8B/net_noBN_fast_8B.mat');
% net = load('/home/h80k/cnn_data/net_upB_8bin_fast/net-up8_8bin_fast.mat');
net = load('/home/h80k/cnn_data/net_8bins_full_lrn.mat');
% net = load('/home/h80k/cnn_data/imdb_syncTanAll30.mat');
w = net.meta.normalization.imageSize(1);
avg_im = zeros(w,w,3);
avgrage = net.meta.normalization.averageImage;
avgrage = reshape(avgrage, 1,1,3);

% imdb = load('/home/h80k/cnn_data/imdb_h80k_8Bins_full.mat');
% imdb = load('/home/h80k/cnn_data/imdb_h80k_8bin_upB.mat');
% ind_val = find(imdb.images.set==2);
% val_names = imdb.images.name(ind_val);
% val_label = imdb.images.label(ind_val);
im_path = '../../../h80k/cnn_data/';%imdb.imageDir;
src_path = '/home/h80k/data/';
% M = length(unique(val_label));M = 8;
M=8;
confusionT = zeros(M);

file_tst = sprintf('/home/Dropbox/h80k/rnn/data/h36m_tst_2d3dNaOrAngle.h5');hinfo_tst = hdf5info(file_tst);

for a=1:5
    names1 = hdf5read(hinfo_tst.GroupHierarchy.Groups(1).Groups(a).Datasets(3));
    names2 = hdf5read(hinfo_tst.GroupHierarchy.Groups(2).Groups(a).Datasets(3));
    N_t = length(names1)+ length(names2);
    error = zeros(1, N_t);c=1;
    for s=1:2
        
        names = hdf5read(hinfo_tst.GroupHierarchy.Groups(s).Groups(a).Datasets(3));N=length(names);
        orient = hdf5read(hinfo_tst.GroupHierarchy.Groups(s).Groups(a).Datasets(4));
        
        est_orient = zeros(1,N);
        for i = 1:1:N
            im = imread([im_path names(i).Data]);
            im_ = single(im);
            im_ = imresize(im_, [w, w]);
            im_ = bsxfun(@minus,im_, avgrage) ;
            res = vl_simplenn(net, im_) ;
            scores = squeeze(gather(res(end).x)) ;
            [bestScore, est_orient(i)] = max(scores) ;
            
            if (est_orient(i) ~= orient(i)+1 )
                error(c) = 1;
                %                         figure
                %                         imagesc(im) ; axis equal off ;
                %                         title(sprintf('%s, , gt:%s ', net.meta.classes.description{best}, net.meta.classes.description{val_label(ind(i))}));
                %                         scores'
            end
            c=c+1;
        end
    end
    err = sum(error)/N_t*100
end
figure;image(confusionT, 'CDataMapping','scaled')
colorbar
colormap jet
%% visualize the weights

figure(2);clf;colormap gray;
filter = squeeze(net.layers{18}.weights{1});
im = reshape(filter(:,1), 64,64);
imshow(im*255)
axis equal
title('filter in the first layer')


function [net, info] = viewPntEst(varargin)
close all;clc;
run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'matlab', 'vl_setupnn.m')) ;
h8k_root = '/home/h80k/cnn_data/';addpath(genpath('../imagenet'))
opts.dataDir = h8k_root;opts.networkType = 'simplenn' ;
modelpath = '/home/matconvnet-1.0-beta18/preTrained/imagenet-vgg-f.mat';
opts.batchNormalization = false ;if opts.batchNormalization, sfx = [ 'BN'] ; end
[opts, varargin] = vl_argparse(opts, varargin) ;
opts.numFetchThreads = 12;opts.lite = false ;
imdb_name = '/imdb_syncAll20_valFM.mat';

opts.imdbPath = [ h8k_root imdb_name];
% opts.expDir = fullfile(h8k_root, [ 'net2_',imdb_name(7:end-4)]) 
opts.expDir = fullfile(h8k_root, [ 'net_cent_subjSep_Synth']);
opts.train = struct() ;opts = vl_argparse(opts, varargin) ;
if ~isfield(opts.train, 'gpus'), opts.train.gpus = [1]; end;
opts.train.continue= 0;

net = load(modelpath);
net.layers = net.layers(1:end-2);
% net.layers{end+1} = struct('type', 'conv','weights', {{0.005*randn(1, 1, 4096, 8, 'single'), zeros(1,8,'single')}}, 'learningRate', [0.0005 0.0002], 'stride', [1 1],'pad', [0 0 0 0]) ;
 net.layers{end+1} = struct('type', 'conv','weights', {{0.005*randn(1, 1, 4096, 8, 'single'), zeros(1,8,'single')}}, 'stride', [1 1],'pad', [0 0 0 0]) ;

net.meta.trainOpts.learningRate = [0.01*ones(1, 20) 0.005*ones(1, 20) 0.001*ones(1, 20) 0.0001*ones(1, 20)]/10;
net.meta.trainOpts.numEpochs = 10; 
net.meta.trainOpts.batchSize = 100;

net.layers{end+1} = struct('type', 'softmaxloss') ;
net.meta.augmentation.rgbVariance=zeros(0,3); %rgbVariance: [0x3 double]
% net.meta.augmentation.transformation = 'stretch';
net.meta.classes.description = {'a_0', 'a_45', 'a_90', 'a_135', 'a_180', 'a_225', 'a_270', 'a_315'};

% -------------------------------------------------------------------------
%                                                              Prepare data
% -------------------------------------------------------------------------
if ~exist(opts.expDir)
    mkdir(opts.expDir) ;
end
imdb = load(opts.imdbPath) ;

%%
% net.meta.normalization.averageImage = zeros(size( net.meta.normalization.averageImage));
% Compute image statistics (mean, RGB covariances, etc.)
imageStatsPath = fullfile(opts.expDir, 'imageStats.mat') ;
if exist(imageStatsPath)
    load(imageStatsPath, 'averageImage', 'rgbMean', 'rgbCovariance') ;
else
    net.meta.normalization.rgbMean = zeros(3,1);
    [averageImage, rgbMean, rgbCovariance] = getImageStats(opts, net.meta, imdb) ;
    save(imageStatsPath, 'averageImage', 'rgbMean', 'rgbCovariance') ;
end

%set the image average (use either an image or a color)
net.meta.normalization.averageImage = averageImage;
net.meta.normalization.rgbCovariance = rgbCovariance;
net.meta.normalization.rgbMean = rgbMean;

% Set data augmentation statistics
[v,d] = eig(rgbCovariance) ;
net.meta.augmentation.transformation = 'none';
net.meta.augmentation.rgbVariance = 0.1*sqrt(d)*v' ;
clear v d ;
% -------------------------------------------------------------------------
%                                                                     Learn
% -------------------------------------------------------------------------

switch opts.networkType
    case 'simplenn', trainFn = @cnn_train ;
    case 'dagnn', trainFn = @cnn_train_dag ;
end

[net, info] = trainFn(net, imdb, getBatchFn(opts, net.meta), ...
    'expDir', opts.expDir, ...
    net.meta.trainOpts, ...
    opts.train) ;
% -------------------------------------------------------------------------
%                                    errorLabels                                Deploy
% -------------------------------------------------------------------------

net = cnn_imagenet_deploy(net) ;
modelPath = fullfile(opts.expDir, 'net-deployed.mat');
% save([opts.expDir, '/info-noBN.mat'], 'info');
save([opts.expDir, '/info.mat'], 'info');

switch opts.networkType
    case 'simplenn'
        save(modelPath, '-struct', 'net') ;
    case 'dagnn'
        net_ = net.saveobj() ;
        save(modelPath, '-struct', 'net_') ;
        clear net_ ;
end

% -------------------------------------------------------------------------
function fn = getBatchFn(opts, meta)
% -------------------------------------------------------------------------
useGpu = numel(opts.train.gpus) > 0 ;

bopts.numThreads = opts.numFetchThreads ;
bopts.imageSize = meta.normalization.imageSize ;
bopts.border = meta.normalization.border ;
bopts.averageImage = meta.normalization.averageImage ;
bopts.rgbMean = meta.normalization.rgbMean ;
bopts.rgbVariance = meta.augmentation.rgbVariance ;
% bopts.transformation = meta.augmentation.transformation ;
bopts.transformation = 'none'; 

switch lower(opts.networkType)
    case 'simplenn'
        fn = @(x,y) getSimpleNNBatch(bopts,x,y) ;
    case 'dagnn'
        fn = @(x,y) getDagNNBatch(bopts,useGpu,x,y) ;
end
% -------------------------------------------------------------------------
function [im,labels] = getSimpleNNBatch(opts, imdb, batch)
% -------------------------------------------------------------------------
images = strcat([imdb.imageDir filesep], imdb.images.name(batch)) ;
isVal = ~isempty(batch) && imdb.images.set(batch(1)) ~= 1 ;

if ~isVal
    % training
    im = cnn_imagenet_get_batch(images, opts, ...
        'prefetch', nargout == 0) ;
else
    % validation: disable data augmentation
    im = cnn_imagenet_get_batch(images, opts, ...
        'prefetch', nargout == 0, ...
        'transformation', 'none') ;
end

if nargout > 0
    labels = imdb.images.label(batch) ;
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function [averageImage, rgbMean, rgbCovariance] = getImageStats(opts, meta, imdb)
% -------------------------------------------------------------------------
train = find(imdb.images.set == 1) ;
train = train(1: 101: end);
bs = 256 ;
opts.networkType = 'simplenn' ;
fn = getBatchFn(opts, meta) ;
avg = {}; rgbm1 = {}; rgbm2 = {};

for t=1:bs:numel(train)
    batch_time = tic ;
    batch = train(t:min(t+bs-1, numel(train))) ;
    fprintf('collecting image stats: batch starting with image %d ...', batch(1)) ;
    temp = fn(imdb, batch) ;
    z = reshape(permute(temp,[3 1 2 4]),3,[]) ;
    n = size(z,2) ;
    avg{end+1} = mean(temp, 4) ;
    rgbm1{end+1} = sum(z,2)/n ;
    rgbm2{end+1} = z*z'/n ;
    batch_time = toc(batch_time) ;
    fprintf(' %.2f s (%.1f images/s)\n', batch_time, numel(batch)/ batch_time) ;
end
averageImage = mean(cat(4,avg{:}),4) ;
rgbm1 = mean(cat(2,rgbm1{:}),2) ;
rgbm2 = mean(cat(3,rgbm2{:}),3) ;
rgbMean = rgbm1 ;
rgbCovariance = rgbm2 - rgbm1*rgbm1' ;

%% --------------------------------------------------------------------
function net = insertBnorm(net, l)
% --------------------------------------------------------------------
assert(isfield(net.layers{l}, 'weights'));
ndim = size(net.layers{l}.weights{1}, 4);
layer = struct('type', 'bnorm', ...
    'weights', {{ones(ndim, 1, 'single'), zeros(ndim, 1, 'single')}}, ...
    'learningRate', [1 1 0.05], ...
    'weightDecay', [0 0]) ;
net.layers{l}.biases = [] ;
net.layers = horzcat(net.layers(1:l), layer, net.layers(l+1:end)) ;

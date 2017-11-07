addpath(genpath('/home/tt/star/h80k/H80Kcode_v1/'))
addpath('visualization/');
if exist('src','dir')
  addpath('src/');
  addpath('external_src/');
  addpath('external_src/randfeat/');
  addpath('external_src/RF_Class_C/');
  addpath('external_src/minFunc/');
  addpath('external_src/HoG/');
  addpath('external_src/o2p-release1/external_src');
  addpath('external_src/o2p-release1/src');
  addpath('external_src/o2p-release1/external_src/vlfeats/toolbox/')
  addpath('external_src/o2p-release1/external_src/vlfeats/toolbox/sift/');
  addpath('external_src/o2p-release1/external_src/vlfeats/toolbox/misc/');
  addpath('external_src/o2p-release1/external_src/vlfeats/toolbox/mex/mexa64/');
  addpath('external_src/liblinear-1.5-dense-float-warm-start-weights/matlab/');
end
if exist('train_src','dir'), addpath('train_src/'); end

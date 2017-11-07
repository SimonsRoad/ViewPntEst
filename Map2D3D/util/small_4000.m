% small_4000
% standard configuration file. Mostly setting up the filepaths and loading
% some of the meta-data like cameras, skeletons and colormaps.

global CONF;
global FEATDB;
global ind_joint_2d;
global joint_r;
global joint_l;
% ind_joint_2d =  [1:8, 13:18, 25:32, 35:40, 51:56];
ind_joint_2d =   [1:8, 13:18, 25:28, 31:32, 35:40, 51:56];
 
joint_r = [1:6, 15:20, 21:26];
joint_l = [7:12, 15:20, 27:32];
FEATDB = containers.Map;
CONF.exp_dir = '/home/tt/star/h80k/data/';
% if exist('expdir.txt','file')
%   hf = fopen('expdir.txt'); d = textscan(hf,'%s'); CONF.exp_dir = d{1}{1}; fclose(hf);
% else
%   CONF.exp_dir = [CONF.base_dir CONF.subset '/'];
% end
tag = '';

% load skeleton and setup the relevant joints
load([CONF.exp_dir '/skel']);
CONF.skel3d = skel;
CONF.skel2d = skel2d;

load([CONF.exp_dir '/camera']);
CONF.camera = camera;

load([CONF.exp_dir '/part_cmap.mat']);
CONF.cmap = cmap;
CONF.numchunks          = 5;

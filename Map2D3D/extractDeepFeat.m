function all_img_struct = extractDeepFeat(net, l, im_folder, category_name, N_class, root_dir)
w = net.meta.normalization.imageSize(1);avgrage = net.meta.normalization.averageImage;
trn_names=[];trn_label = [];
trn_allV_feat = [];trn_allV_feat_s = [];
for c =1:8
    dir_path = [root_dir, im_folder, category_name{ (c)}];
    files = dir( [dir_path ,'/*.jpg']);
    N = length(files);
    [c N]
    N = N_class;
    names = cell(1,N);
    cnnFeat = zeros(N, 4096);  cnnFeat_s = zeros(N, 4096);
    parfor i = 1:N
        names{i} = fullfile([root_dir im_folder], category_name{ (c)}, files(i).name);
        im = imread(names{i});
        im_ = single(imresize(im, [w, w]));
        im_ = bsxfun(@minus,im_, reshape(avgrage,1,1,3));
        res = vl_simplenn(net, im_);
        cnnFeat(i,:)= squeeze(res(l).x);
        cnnFeat_s(i,:)= squeeze(res(l-2).x);
    end
    %         ind = randperm(length(names));
    names_bin{c} = names ;
    trn_names = [trn_names names_bin{c}(1:N_class)];
    trn_label = [trn_label c*ones(1,N_class)];
    trn_allV_feat = [trn_allV_feat  ;cnnFeat ];
    trn_allV_feat_s = [trn_allV_feat_s  ;cnnFeat_s ];
end
all_img_struct.deepFeat = trn_allV_feat;
all_img_struct.deepFeat_s = trn_allV_feat_s;
all_img_struct.label = trn_label;
all_img_struct.names = trn_names;

clc;close all;
no = 1;
for no=1:3
    dir_path = ['/home/t/h80k/cnn_data/full_images/category_', num2str(no),'/']
    files = dir([dir_path,'*.jpg']);
    N = length(files)
    for i =1:N
        im_path = [dir_path, files(i).name];
        im = imread(im_path);
%         imshow(im)
         imwrite(rgb2gray(im), im_path)
    end
end
no

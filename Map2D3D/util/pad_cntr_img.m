function im2 = pad_cntr_img(im, center)
% close all;
x0 = round(center(1));

scale = 224/size(im,1);
im0 =imresize(im, scale);
o = 60;
pad1 = round(o-x0*scale);
im1 = im0;
if pad1>0
    im1 = padarray(im0, [0, pad1], 'pre');
elseif pad1<0
    im1=im0(:,abs(pad1):end,:);
end

% figure;
% subplot(321);imshow(im);hold on;plot(center(1), center(2), '*r')
% subplot(322);imshow(im0)
% subplot(323);imshow(im1)

pad2 = o-round(size(im1,2)- (x0*scale+pad1));
if pad2>0
    im1 = padarray(im1, [0, pad2], 'post');
elseif pad2 < 0
    im1=im1(:,1:2*o,:);
end

im2 = im1;

% pad3 = round((224- size(im1,2))/2);
% im2 = padarray(im1, [0, pad3], 'pre');
% im2 = padarray(im2, [0, pad3], 'post');

% subplot(324);imshow(im1)
% subplot(325);imshow(im2)
% Y0 = 40;
% pad= Y0-y0;
% if pad>0
% im1_y = padarray(im1, [pad, 0], 'pre');
% else
%     im1_y = im1(abs(pad):end,:,:);
% end
%     subplot(324);imshow(imy)
% pad2 = 224-Y0-(size(im0,1)-y0);
%
% if pad2 >0
% im1_y = padarray(im1, [pad2, 0], 'post');
% else
%     im1_y = im1(1:224,:,:);
% end
%
% % im1_y =padarray(im0, [224-y0, 0], 'pre');
%
% subplot(325);imshow(im1_y)

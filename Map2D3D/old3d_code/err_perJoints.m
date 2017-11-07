 clc;close all;
% [sorted_err, ind_sort] = sort(TGPKNNError, 'descend');

% pr = pose3d_train(:,[43,45]);
% ph = pose3d_train(:,[31,33]);
% pl = pose3d_train(:,[34,36]);
% rotation = atan2(pl(:,2)-pr(:,2) ,pl(:,1)-pr(:,1))*180/pi;
% Y=[pr(:,2), ph(:,2), pl(:,2)];
% X=[pr(:,1), ph(:,1), pl(:,1)];
% ind_0 =find((rotation<-5)& (-10<rotation));
% ind_180 =find(-170<rotation<=180);
% %%
% for j=1:length(ind_0)
%     i=ind_0(j)
%      name = [CONF.exp_dir  val.names{i}];
%     figure;
%     im_test = imread(name);imshow(im_test);
%     title(['i = ', num2str(i), ', angle = ', num2str(rotation(i))])    
% end
  %%  
 i=16;  ind_j =  i*3+1:i*3+1+2;
a= est_3d(:,ind_j) - val_pose51(:,ind_j);
err_leftHand = sqrt(sum(a.^2,2));
[sorted_err, ind_sort] = sort(err_leftHand, 'descend');

R = 2;C=2;
rb = H36MRenderBody(CONF.skel3d,'Style','sketch','ColormapType','left-right');
H_val = (val_pose51(:,11) - val_pose51(:,32))/10;
H_trn = (pose3d_train(:,11) - pose3d_train(:,32))/10;
for m = 1:5
    figure;subplot(R,C,1);
    name = [CONF.exp_dir  val.names{ind_sort(m)}];
    im_test = imread(name);imshow(im_test);
    title(['i = ',num2str(ind_sort(m)), ', orient = ',  num2str(val_orient(ind_sort(m)))])

    subplot(R,C,2);
    rb.render3D(convert_joint51_96(val_pose51(ind_sort(m),:)));title('GroundT')
    title(['Groundtruth'])
    %%
    subplot(R,C,3);
    rb.render3D(convert_joint51_96(est_3d(ind_sort(m),:)));
    title(['Estimation'])
    %%
    tmp = repmat(val_pose51(ind_sort(m),:), size(pose3d_train,1), 1);
    [err_gt, ~] = JointError(pose3d_train, tmp);
    [min_err, ind_gt_match] = min(err_gt);
    name = [training_only{ii}.imagePath, training_only{ii}.names{ind_gt_match}];
    im_best = imread(name);
    subplot(R,C,4);
    imshow(im_best);title(['H= ', num2str(round(H_trn(ind_gt_match))) ,', best err= ', num2str(round(min_err))])
end
%%
% joints = zeros(1,16);
% for i=1:16
%     ind_j =  i*3+1:i*3+1+2;
%     a= est_3d(:,ind_j) - val_pose51(:,  ind_j);
%     joints(i) = mean(sqrt(sum(a.^2,2)));
% end
% figure;plot(joints, '*');
% title(['estimation: activity:', num2str(ii)])
% xlabel('Body part')
% ylabel('Error')
%%

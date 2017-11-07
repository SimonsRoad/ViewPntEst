pose2d_trn_gt = training_only{ii}.pose2d(:,ind_joint_2d);
pose2d_IEF_trn = convert2IEF(pose2d_trn_gt);
pose2d_IEF_trn = bsxfun(@minus, pose2d_IEF_trn, pose2d_IEF_trn(:,9,:));
pose2d_train = reshape(pose2d_IEF_trn, 32, size(pose2d_IEF_trn,3))';

r_hand_elbow = sqrt(sum(( pose2d_train(:,ind2d_r(1:2))- pose2d_train(:,ind2d_r(3:4)) ).^2, 2 ));
r_hand_elbow_n = r_hand_elbow./abs(pose2d_train(:,16));
r_elbow_depth_n = pose3d_train(:, 45) - pose3d_train(:, 48);

r_hand_wrist = sqrt(sum((pose2d_train(:,ind2d_r(5:6),:)- pose2d_train(:,ind2d_r(3:4),:) ).^2, 2 ));
r_hand_wrist_n = r_hand_wrist./abs(pose2d_train(:,16));
r_wrist_depth_n = pose3d_train(:, 48) - pose3d_train(:, 51);

close all
figure;
[s_r_hand_elbow, ind] = sort(r_hand_elbow_n, 'descend');
subplot(221);plot(s_r_hand_elbow);xlabel('n (example)');ylabel('Upper arm len')
subplot(223);plot(abs(r_elbow_depth_n(ind)));hold on;plot(200*ones(1,length(ind) ),':r');ylabel('Elbow depth')

% x = tan(s_r_hand_elbow);
% X = [ones(length(x),1) x]; 
% y = abs(r_elbow_depth_n(ind));figure;plot(y)
% b = X\y;
% est = b(1)*x + b(2);
% figure;plot(est,':r');hold on;plot(y)
figure;plot(s_r_hand_elbow, abs(r_elbow_depth_n(ind)))
suptitle('Effect of depht on hand length');

[s_r_hand_wrist, ind_w] = sort(r_hand_wrist_n, 'descend');
subplot(222);plot(s_r_hand_wrist);xlabel('n (example)');ylabel('Lower arm len')
subplot(224);plot(abs(r_wrist_depth_n(ind_w)));hold on;plot(200*ones(1,length(ind_w) ),':r');ylabel('Wrist depth')
%%

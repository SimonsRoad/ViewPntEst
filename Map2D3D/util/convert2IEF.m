function pose2d_IEF = convert2IEF(pose2d_gt)

pose2d_gt = reshape(pose2d_gt', 2, 16, size(pose2d_gt,1));

pose2d_IEF = zeros(size(pose2d_gt));

pose2d_IEF(:,1:3,:)  = pose2d_gt(:,4:-1:2,:);
pose2d_IEF(:,4:6,:) = pose2d_gt(:,5:7,:);
pose2d_IEF(:,7,:) = pose2d_gt(:,1,:);
pose2d_IEF(:,10,:) = pose2d_gt(:,10,:);
% pose2d_IEF(:,8:9,:) = pose2d_gt(:,9:-1:8,:);
pose2d_IEF(:,8:9,:) = pose2d_gt(:,8:1:9,:); %new
% pose2d_IEF(:,8:10,:) = pose2d_gt(:,8:10,:);
pose2d_IEF(:,11:13,:) = pose2d_gt(:,16:-1:14,:);
pose2d_IEF(:,14:16,:) = pose2d_gt(:,11:13,:);
end

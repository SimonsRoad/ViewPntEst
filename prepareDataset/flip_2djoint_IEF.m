function pose32_flip = flip_2djoint_IEF(joint_2d)
N = size(joint_2d,3);
pose32_flip = zeros(size(joint_2d));

for i=1:N
%     joint = joint_2d(i,:);
%     joints = reshape(joint, 2, 16);
%     joint_flip(:,1:3) = joints(:,4:6);
%     joint_flip(:,4:6) = joints(:,1:3);
%     joint_flip(:,14:16) = joints(:,11:13);
%     joint_flip(:,11:13) = joints(:,14:16);
    joints = joint_2d(:,:,i);
    joint_flip = joints;
    joint_flip(:,1:3) = joints(:,6:-1:4);
    joint_flip(:,4:6) = joints(:,3:-1:1);
    joint_flip(:,14:16) = joints(:,13:-1:11);
    joint_flip(:,11:13) = joints(:,16:-1:14);
    joint_flip(1,:) = -joint_flip(1,:);
    pose32_flip(:,:,i) = joint_flip;
end

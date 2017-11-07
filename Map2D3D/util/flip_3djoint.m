function pose51_flip= flip_3djoint(joint_3d)
N = size(joint_3d,1);
pose51_flip = zeros(N,51);
for i=1:N
    joint = joint_3d(i,:);
    joints = reshape(joint, 3, 17);
    joint_flip = joints;
    joint_flip(:,12:14) = joints(:,15:17);
    joint_flip(:,15:17) = joints(:,12:14);
    joint_flip(:,2:4) = joints(:,5:7);
    joint_flip(:,5:7) = joints(:,2:4);
    joint_flip(1,:) = -joint_flip(1,:);
    pose51_flip(i,:) = reshape(joint_flip, 1, 51);
end

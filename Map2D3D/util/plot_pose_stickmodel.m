function plot_pose_stickmodel(pose)
pose = double(pose);
connected = [1 2; 2 3; ... % right leg
    11 12; 12 13; ... % right arm
    9 13;  %8 13; ... % thorax - right arm
    3 7; ... % right hip    - pelvis
    14 15; 15 16; ... % left arm 
    9 14; %8 14; ... % thorax - left arm
    4 5; 5 6; ... % left legc
    4 7; ... % left hip    - pelvis
    7 8; ... % pelvis      - thorax
    8 9; ... % thorax      - upper neck
    9 10]; % upper neck - head



%     colors = {'r', 'r', ... % right leg
%               'r', 'r', ... % right arm
%               'r', ... % thorax - right arm
%               'r', ... % right hip - pelvis
%               'g', 'g', ... % left arm
%               'g', ... % thorax - left arm
%               'g', 'g' ... % left leg
%               'g', ... % left hip - pelvis
%               'y', ... % pelvis - thorax
%               'm', ... % thorax - upper neck
%               'y'}; % upper neck head


colors = {'g', 'g', ... % right leg
    'g', 'g', ... % right arm
    'g', ... % thorax - right arm
    'g', ... % right hip - pelvis
    'r', 'r', ... % left arm
    'r', ... % thorax - left arm
    'r', 'r' ... % left leg
    'r', ... % left hip - pelvis
    'k', ... % pelvis - thorax
    'm', ... % thorax - upper neck
    'y'}; % upper
for i=1:size(pose,1)
    h = plot(pose(i,1),pose(i,2));
end

for j=1:size(connected,1)
    hold on;
    line([pose(connected(j,1),1) pose(connected(j,2),1)], [pose(connected(j,1),2) pose(connected(j,2),2)], 'color', colors{j}, 'Linewidth', 3);
end

axis ij;
axis equal;
%     axis tight;
end

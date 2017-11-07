function angles = calc_pose_angles(pose_vec)
N = size(pose_vec,1);
angles = zeros(N, 13);
for i=1:N
    tmp = reshape(pose_vec(i,:), 2,16);
    head = tmp(:,10) - tmp(:,9);
    r_leg_up = tmp(:,2) - tmp(:,3); r_leg_down = tmp(:,2) - tmp(:,1);hig_rLeg = tmp(:,7) - tmp(:,3);
    r_arm = tmp(:,12) - tmp(:,13);r_hand = tmp(:,12) - tmp(:,11);right_shoulder = tmp(:,13) - tmp(:,9);
    
    phi_r_hand =  calc_angle_d(r_arm, r_hand);
    phi_r_shoulder = calc_angle_d(-r_arm, right_shoulder);
    phi_head = calc_angle_d(head,right_shoulder);
    
    phi_r_leg = calc_angle_d(r_leg_up, r_leg_down);
    phi_r_hip= calc_angle_d(-r_leg_up, hig_rLeg);
    
    l_leg_up = tmp(:,5) - tmp(:,4); l_leg_down = tmp(:,5) - tmp(:,6);hig_LLeg = tmp(:,7) - tmp(:,4);
    torso_hip = tmp(:,7) -tmp(:,9);
    l_arm = tmp(:,15) - tmp(:,14);l_hand = tmp(:,15) - tmp(:,16);left_shoulder = tmp(:,14) - tmp(:,9);
    
    phi_l_hand =  calc_angle_d(l_arm, l_hand);
    phi_l_shoulder = calc_angle_d(-l_arm, left_shoulder);
    
    phi_l_leg = calc_angle_d(l_leg_up, l_leg_down);
    phi_l_hip = calc_angle_d(-l_leg_up, hig_LLeg);
    
    phi_l_torso = acosd(dot(torso_hip, hig_LLeg)/ norm(hig_LLeg)/norm(torso_hip));
    phi_r_torso = acosd(dot(torso_hip, hig_rLeg)/ norm(hig_rLeg)/norm(torso_hip));
    
    head = [phi_head];
    R_side = [phi_r_leg, phi_r_hip, phi_r_torso, phi_r_shoulder, phi_r_hand, calc_angle_d(-r_arm, torso_hip)];
    L_side = [phi_l_leg, phi_l_hip, phi_l_torso, phi_l_shoulder, phi_l_hand, calc_angle_d(-l_arm, torso_hip)];
    angles(i,:) = [head,R_side,L_side];
end

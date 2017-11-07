function angle = calc_angle_d(a_vec, b_vec)
angle = acosd(dot(a_vec, b_vec)/norm(a_vec)/norm(b_vec));  

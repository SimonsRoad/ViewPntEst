function  sincos = calc_sincos_angle(a_vec, b_vec)
cos = dot(a_vec, b_vec)/norm(a_vec)/norm(b_vec); 
outer_product = cross([a_vec; 0], [b_vec; 0]);
sin = norm(outer_product)/norm(a_vec)/norm(b_vec)*sign(outer_product(3)); 
sincos = [cos;sin];

function calc_angle_err(gt_orient, val_orient)
 
N = length(val_orient);
error = zeros(1,N);
for i=1:N
    if abs(val_orient(i)-gt_orient(i))==7
        error(i) = 1;
    else
        error(i) =abs(val_orient(i)-gt_orient(i));
    end
end
hist(error, 6)
 sum(error)/N

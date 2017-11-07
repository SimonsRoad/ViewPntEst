function orient = estimate_gt_orient4Bins(rotation)
offset = 45;
N = length(rotation);
orient = zeros(1,N);
o=0;
for i=1:N
    if -offset < rotation(i) && rotation(i)<= offset
        orient(i) = 2;
        
    elseif offset < rotation(i) && rotation(i)<= 90+offset+o
        orient(i) =3;     
        
    elseif  90+offset < rotation(i) || rotation(i)<= -90 -offset
        orient(i) = 1;
        
        
    elseif -90 - offset < rotation(i) && rotation(i)<= -offset
        orient(i) = 4;
    else
        error('range is wrong!')
    end
end

function orient = estimate_gt_orient(rotation)
offset = 22.5;
N = length(rotation);
orient = zeros(1,N);
o=0;
for i=1:N
    if -offset < rotation(i) && rotation(i)<= offset
        orient(i) = 1;
        
    elseif offset < rotation(i) && rotation(i)<= 45+offset+o
        orient(i) = 2;
        
    elseif 45+offset+o < rotation(i) && rotation(i) <= 90+offset-o
        orient(i) = 3;
        
    elseif  90+offset-o < rotation(i) && rotation(i)<= 135+offset
        orient(i) = 4;
        
    elseif  135+offset < rotation(i) || rotation(i)<= -135 -offset
        orient(i) = 5;
        
    elseif -135 -offset < rotation(i) && rotation(i)<= -135 +offset+ o
        orient(i) = 6;
        
    elseif -90 -offset + o < rotation(i) && rotation(i)<= -90+offset-o
        orient(i) = 7;
        
    elseif -45 - offset -o < rotation(i) && rotation(i)<= -45+offset
        orient(i) = 8;
    else
        error('range is wrong!')
    end
end

function orinet = calc_orient(rotation)
N = size(rotation,1);
orinet = zeros(N,1);
x = 22.5;

for i=1:N
    
    if -x-5 <= rotation(i) && rotation(i)<= x+5
        orinet(i) = 1;
        
    elseif 45-x <= rotation(i) && rotation(i)<= 45+x
        orinet(i) = 2;
        
    elseif 90-x <= rotation(i) && rotation(i) <= 90+x
        orinet(i) = 3;
        
    elseif 135-x <= rotation(i) && rotation(i)<= 135+x
        orinet(i) = 4;
        
    elseif  180-x-11 <= rotation(i) || rotation(i)<= -180+x+11
        orinet(i) = 5;
        
    elseif -135-x <= rotation(i) && rotation(i)< -135+x
        orinet(i) = 6;
        
    elseif -90-x <= rotation(i) && rotation(i)< -90+x
        orinet(i) = 7;
        
    elseif -45-x <= rotation(i) && rotation(i)< -45+x
        orinet(i) = 8;
    end
end

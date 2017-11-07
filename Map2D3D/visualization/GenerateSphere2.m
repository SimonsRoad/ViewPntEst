function Sph = GenerateSphere2( parts )
rings = parts;
sectors = parts*2;

R = 1/(rings-1);
S = 1/(sectors-1);

Sph.Vertices = zeros(rings * sectors, 3);
ix = zeros(rings * sectors, 1);
i = 0;
for r = 1:(rings-2)
    for s = 0:(sectors-1)
        i = i + 1;
        y = sin( -pi/2 + pi * r * R );
        x = cos(2*pi * s * S) * sin( pi * r * R );
        z = sin(2*pi * s * S) * sin( pi * r * R );
        
        Sph.Vertices(i, :) = [x, y, z] + [0 0 0.5];
        ix(r + 1, s + 1) = i;
    end
end
ixUp = i+1;
Sph.Vertices(ixUp, :) = [0 1 0] + [0 0 0.5];
ixDwn = i+2;
Sph.Vertices(ixDwn, :) = [0 -1 0] + [0 0 0.5];
ix(1, :) = ixDwn;
ix(rings, :) = ixUp;

Sph.Vertices = Sph.Vertices(1 : i + 2, :);


Sph.Indices = zeros(rings * sectors * 2, 3,'uint32');
F = ones(rings*sectors*2, 1);

i = 0;
for r = 0:(rings-2)
    for s = 0:(sectors-1)
        i = i + 1;
        i1 = ix(r + 1, s + 1);
        i2 = ix(perm(r + 1, 1, rings), perm(s + 2, 1, sectors));
        i3 = ix(perm(r + 2, 1, rings), perm(s + 2, 1, sectors));
        i4 = ix(perm(r + 2, 1, rings), s+1);
        
        Sph.Indices(i, :) = [i1 i2 i3];
        if(Sph.Vertices(Sph.Indices(i, 1), 3) < 0.5 || ...
                Sph.Vertices(Sph.Indices(i, 2), 3) < 0.5 || ...
                Sph.Vertices(Sph.Indices(i, 3), 3) < 0.5)
            F(i) = 0;
        else
            F(i) = 1;
        end
        if(length(unique([i1 i2 i3])) < 3)
            i = i - 1;
        end
        i = i + 1;
        Sph.Indices(i, :) = [i3 i4 i1];
        if(Sph.Vertices(Sph.Indices(i, 1), 3) < 0.5 || ...
                Sph.Vertices(Sph.Indices(i, 2), 3) < 0.5 || ...
                Sph.Vertices(Sph.Indices(i, 3), 3) < 0.5)
            F(i) = 0;
        else
            F(i) = 1;
        end
         if(length(unique([i3 i4 i1])) < 3)
            i = i - 1;
        end
    end
end

F = F(1 : i, :);
Sph.Indices = Sph.Indices(1 : i, :);
% i = 1;
% mI = size(Sph.Vertices, 1);
% for r = 0:(rings-1)
%     for s = 1:sectors
%         Sph.Indices(i, :) = [r * sectors + s, r * sectors + (s+1), (r+1) * sectors + s];
%         Sph.Indices(i, :) = clampMax(Sph.Indices(i, :), 1, mI);
%         if(Sph.Vertices(Sph.Indices(i, 1), 3) < 0.5 || ...
%                 Sph.Vertices(Sph.Indices(i, 2), 3) < 0.5 || ...
%                 Sph.Vertices(Sph.Indices(i, 3), 3) < 0.5)
%             F(i) = 0;
%         end
%         
%         Sph.Indices(i+1, :) = [r * sectors + (s+1), (r+1) * sectors + (s+1), (r+1) * sectors + s];
%         Sph.Indices(i+1, :) = clampMax(Sph.Indices(i+1, :), 1, mI);
%         if(Sph.Vertices(Sph.Indices(i+1, 1), 3) < 0.5 || ...
%                 Sph.Vertices(Sph.Indices(i+1, 2), 3) < 0.5 || ...
%                 Sph.Vertices(Sph.Indices(i+1, 3), 3) < 0.5)
%             F(i+1) = 0;
%         end
%         i = i + 2;
%     end
% end
% Sph.Indices(Sph.Indices > rings * sectors) = rings * sectors;
Sph.IndicesL = Sph.Indices(find(F == 0), :);
Sph.IndicesU = Sph.Indices(find(F == 1), :);
end

function x = clampMax(x, a, b)

for i = 1 : length(x)
    if(x(i) < a)
        x(i) = a;
    elseif(x(i)>b)
        x(i) = b;
    end
end

end
function x = perm(x, a, b)
if(x > b)
    x = a;
elseif(x < a)
    x = b;
end
end
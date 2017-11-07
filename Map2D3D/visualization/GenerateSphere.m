function Sph = GenerateSphere( parts )

rings = parts;
sectors = parts*2;

R = 1/(rings-1);
S = 1/(sectors-1);

Sph.Vertices = zeros(rings * sectors, 3);
i = 1;
for r = 0:(rings-1)
    for s = 0:(sectors-1)
        y = sin( -pi/2 + pi * r * R );
        x = cos(2*pi * s * S) * sin( pi * r * R );
        z = sin(2*pi * s * S) * sin( pi * r * R );
        
        Sph.Vertices(i, :) = [x, y, z];
        i = i + 1;
    end
end

Sph.Indices = zeros(rings * sectors * 2, 3,'uint8');
i = 1;
for r = 0:(rings-1)
    for s = 1:sectors
        Sph.Indices(i, :) = [r * sectors + s, r * sectors + (s+1), (r+1) * sectors + s];
        Sph.Indices(i+1, :) = [r * sectors + (s+1), (r+1) * sectors + (s+1), (r+1) * sectors + s];
        i = i + 2;
    end
end
Sph.Indices(Sph.Indices > rings * sectors) = rings * sectors;


end


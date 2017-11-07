function Cyl = GenerateCylinder2(sides, alpha, beta)
% tappered cyl
% alpha is the ratio of one end to the other

Cyl1 = GenerateCylinder(sides);
Cyl1.Vertices(:, 3) = Cyl1.Vertices(:, 3)/2;
Cyl.Vertices = [Cyl1.Vertices; Cyl1.Vertices + repmat([0 0 0.5], [size(Cyl1.Vertices, 1) 1])];
Cyl.Indices =  [Cyl1.Indices; Cyl1.Indices + max(Cyl1.Indices(:))];
Cyl.HalfSize = 2 * sides;

end


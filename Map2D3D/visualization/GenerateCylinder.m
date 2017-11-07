function Cyl = GenerateCylinder(sides, alpha, beta)
% tappered cyl
% alpha is the ratio of one end to the other

Cyl.Vertices = zeros(2*sides+2,3);
Cyl.Indices = zeros(2*sides+2*sides,3,'uint8');
%Creating the side triangles
if nargin == 1
  alpha=1; beta=1;
end

if nargin == 2
  beta=1;
end

for i=1:sides-1
    angle = double(i)/sides*(2*pi);
    Cyl.Vertices(i,1:2) = [alpha*sin(angle) alpha*cos(angle)];
    Cyl.Vertices(sides+i,1:3) = [beta*sin(angle) beta*cos(angle) 1];
    Cyl.Indices(2*i-1:2*i,1:3) = [i i+1 i+sides; i+1 i+sides+1 i+sides]; 
end
% i=sides
angle = double(sides)/sides*(2*pi);
Cyl.Vertices(sides,1:2) = [alpha*sin(angle) alpha*cos(angle)];
Cyl.Vertices(2*sides,1:3) = [beta*sin(angle) beta*cos(angle) 1];
Cyl.Indices(2*sides-1:2*sides,1:3) = [sides 1 2*sides; 1 sides+1 2*sides];
%Creating bottom and top cap
Cyl.Vertices(2*sides+2,3) = 1; %2 vertices in (0,0,0) and (0,0,1)
for i=1:sides-1
    Cyl.Indices(2*sides+2*i-1,1:3) = [i+1 i 2*sides+1];
    Cyl.Indices(2*sides+2*i,1:3) = [sides+i+1 sides+i 2*sides+2];
end
%i=sides
Cyl.Indices(4*sides-1:4*sides,1:3) = [1 sides 2*sides+1 ; sides+1 2*sides 2*sides+2];
end


function RenderMesh( Mesh , col, Camera)
  if exist('Camera','var') && isa(Camera,'H36MCamera')
    [PX,D] = Camera.project(Mesh.Vertices);
    Mesh.Vertices = [PX(1:2:end) PX(2:2:end) D'];
  end

  if isinf(col)
      if ~isempty(Mesh.Indices), trisurf(Mesh.Indices,Mesh.Vertices(:,1),Mesh.Vertices(:,2),Mesh.Vertices(:,3),'FaceColor','interp','EdgeColor','interp','EdgeAlpha',0); end
  else
      if ~isempty(Mesh.Indices), trisurf(Mesh.Indices,Mesh.Vertices(:,1),Mesh.Vertices(:,2),Mesh.Vertices(:,3),'FaceColor',col,'edgecolor','none','ambientstrength',.7); material dull; end
  end
end


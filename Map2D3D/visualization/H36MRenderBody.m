classdef H36MRenderBody
    properties (Access=public)
        Skeleton;
        Camera;
        ColormapType; % uniform, left-right, depth, custom
        Colormap; %
        Style;    % sketch, flesh
        Lighting;
        CamLight;
        JointVisibility;
        PartVisibility;
        TextVisibility;
        TextProperties;
        Parts;
        BGcolor;
        GlobalScaling;
        DataType;
    end
    
    methods (Access=public)
        function obj = H36MRenderBody(skel, varargin)
            obj.Skeleton = skel;
            obj.ColormapType = 'left-right';
            obj.Colormap = [.5 .5 .5];
            obj.Style = 'flesh'; % flesh, sketch, sketch2, flesh2
%             obj.Style = 'sketch'; % flesh, sketch, sketch2, flesh2
            obj.Lighting = 'gouraud';
            obj.CamLight = 'headlight';%headlight
            obj.JointVisibility = true;
            obj.PartVisibility = true;
            obj.TextVisibility = false;
            obj.TextProperties = {'HorizontalAlignment','center'};
            obj.DataType = 'h36m';% poselets
            
            if mod(length(varargin),2)~=0
                error('Wrong parameters!');
            end
            
            for i = 1: 2: length(varargin)
                obj.(varargin{i}) = varargin{i+1};
            end
            
            switch obj.DataType
                case 'poselets'
                    obj.GlobalScaling = .1;
                case 'h36m'
                    obj.GlobalScaling = 1;
                otherwise
                    error('Unknown data type!');
            end
            
            obj = getParts(obj);
            obj.BGcolor = obj.Colormap(1,:);
        end
        
        function render3D(obj, pose, Camera)
            if exist('Camera','var')
              setupScene(obj,pose,Camera);
              campos(Camera.T); view(0,-90);
              light('position',[0 0 -6000],'style','infinite');
              lighting(obj.Lighting);
            else
              setupScene(obj,pose);
              light('position',[0 0 6000],'style','infinite');
              lighting(obj.Lighting);
            end          
            
            set(gca,'zdir','reverse')
            %       light('position',[0 2000 4000],'style','infinite','visible','on')
            axis equal; axis off; axis ij;
            
        end
        
        % render 3d
        function setupScene(obj, pose, Camera)
            % actual setting up of the scene based on the objects from getParts
            if ~exist('Camera','var'), Camera = []; end
            hold on;
            for i = 1: length(obj.Parts)
                part = obj.Parts(i);
                switch part.type
                    case 'line'
                        X1 = getCoords(obj,pose,part.joint_idx(1));
                        X2 = getCoords(obj,pose,part.joint_idx(2));
                        hf = line([X1(1) X2(1)],[X1(2) X2(2)],[X1(3) X2(3)]);
                        set(hf,'linewidth',part.diam,'color',part.color);
                        if obj.TextVisibility
                            XX = (X1+X2)/2;
                            text(XX(1),XX(2),XX(3),part.name,obj.TextProperties{:});
                        end
                        
                    case 'point'
                        X1 = getCoords(obj,pose,part.joint_idx(1));
                        hf = scatter3(X1(1),X1(2),X1(3),part.diam,part.color,part.props{:});
                        
                        if obj.TextVisibility
                            text(X1(1),X1(2),X1(3),part.name,obj.TextProperties{:});
                        end
                        
                        
                    case 'ball'
                        X1 = getCoords(obj,pose,part.joint_idx(1));
                        for j=1:size(part.mesh.Vertices,1)
                            part.mesh.Vertices(j,:) = part.mesh.Vertices(j,:) * part.diam + X1;
                        end
                        RenderMesh(part.mesh,part.color,Camera);
                        if obj.TextVisibility
                            text(X1(1),X1(2),X1(3),part.name,obj.TextProperties{:});
                        end
                        
                    otherwise
                        error('Part type not supported!');
                end
            end
            
        end
    end
    
    methods (Access=private)
        function obj = getParts(obj)
            % just creating the volumes and setting properties for the surf obj
            skel = obj.Skeleton;
            connect = zeros(length(skel.tree));
            for i = 1:length(skel.tree);
              for j = 1:length(skel.tree(i).children)    
                connect(i, skel.tree(i).children(j)) = 1;
              end
            end
            
            indices = find(connect);
            [I, J] = ind2sub(size(connect), indices);
            
            switch obj.ColormapType
                case 'uniform'
                    obj.Colormap = ones(64,1)*obj.Colormap;
                    obj.Colormap(1,:) = obj.BGcolor;
                    
                case 'left-right'
                    if obj.JointVisibility
                        for i = 1: length(obj.Skeleton.tree)
                            obj.Colormap(i+1,:) = [0 0 0];
                        end
                    end
                    
                    if obj.PartVisibility
                        if ~obj.JointVisibility, obj.Colormap = obj.BGcolor; end
                        for i =1 : length(I)
                            if (obj.Skeleton.tree(I(i)).name(1)=='L')
                                obj.Colormap(end+1,:) = [1 0 0];
                            elseif (obj.Skeleton.tree(I(i)).name(1)=='R')
                                obj.Colormap(end+1,:) = [0 1 0];
                            else
                                obj.Colormap(end+1,:) = [0 0 1];
                            end
                        end
                    end
                    
                case 'distinct'
                  % each part has a different color
                  obj.Colormap = jet(64);
                  
                case 'custom'
                    % set by user
                    
                otherwise
                    error('Unkown colormap type!');
            end
            
            % this is where we setup the part geometry
            switch obj.Style
                case 'sketch'
                    parts = [];
                    
                    % joints
                    if obj.JointVisibility
                        for i = 1: length(obj.Skeleton.tree)
                            parts(i).type = 'point';
                            parts(i).diam = 30;
                            parts(i).color = obj.Colormap(i+1,:);
                            parts(i).props = {'filled'};
                            parts(i).joint_idx = i;
                            parts(i).name = obj.Skeleton.tree(i).name;
                        end
                    end
                    
                    % limbs
                    if obj.PartVisibility
                        if ~obj.JointVisibility, aa = 1; else, aa =length(parts)+1; end
                        for i = 1: length(I)
                            parts(end+1).type = 'line';
                            parts(end).diam = 3;
                            parts(end).color = obj.Colormap(aa+i,:);
                            parts(end).joint_idx = [I(i),J(i)];
                            parts(end).name = '';
                        end
                    end
                    
                case 'sketch2'
                    parts = [];
                    % joints
                    if obj.JointVisibility
                        for i = 1: length(obj.Skeleton.tree)
                            parts(i).type = 'ball';
                            parts(i).mesh = GenerateSphere(7);
                            parts(i).diam = 20;
                            parts(i).color = obj.Colormap(i+1,:);
                            parts(i).joint_idx = i;
                            parts(i).name = obj.Skeleton.tree(i).name;
                        end
                    end
                    
                    % limbs
                    if obj.PartVisibility
                        for i = 1: length(I)
                            parts(end+1).type = 'sphere';
                            parts(end).mesh = GenerateCylinder(10);
                            parts(end).width = [25,25];
                            parts(end).color = obj.Colormap(length(parts),:);
                            parts(end).joint_idx = [I(i),J(i)];
                            parts(end).name = '';
                        end
                    end
                    
                otherwise
                    error('a');
            end
            
            obj.Parts = parts;
        end
        
        function x = getCoords(obj, pose, i)
            % FIXME add axis order here if needed
            x = pose(obj.Skeleton.tree(i).posInd);
        end
    end
end

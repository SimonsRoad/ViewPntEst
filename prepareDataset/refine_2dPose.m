close all
load('IEF_val1.mat')
load('IEF_training1.mat')
for ii = 1: length(files)
    
    orient = val.orient;
    pose2d_IEF_val = IEF_val{ii};
    pose2d_IEF_val = reshape(pose2d_IEF_val', 2, 16, size(pose2d_IEF_val,1));
    pose_2d = pose2d_IEF_val;
    
    %     orient = training_data.orient;
    %     pose2d_IEF_trn = IEF_training{ii};
    %     pose2d_IEF_trn = reshape(pose2d_IEF_trn', 2, 16, size(pose2d_IEF_trn,1));
    %     pose_2d = pose2d_IEF_trn;
    
    frontal = pose_2d(1,14,:) - pose_2d(1,13,:);  % 14:right shoulder, 13:left shoulder     
    frontal2 = pose_2d(1,15,:) - pose_2d(1,12,:); 
    
    for j=1:size(pose_2d,3)
        if(abs(frontal(j)) < 5 )
            continue
        end
        if ((orient(j) ==1 || orient(j) == 2 ||orient(j) == 8) && frontal(j) <0) || ((orient(j) == 4 || orient(j) == 5 || orient(j) == 6) && frontal(j) >0)
            figure; subplot(131);
            %             name_neighbor=[training_data.imagePath,  training_data.names{j}];
            %             im = imread(name_neighbor);
            im = imread([CONF.exp_dir  val.names{j}]);
            imshow(im)
            subplot(1,3,2);
            plot_pose_stickmodel(pose_2d(:,:,j)');
            title(['val: j= ', num2str(j),', orient = ', num2str(orient(j)), ', frontal = ', num2str(round(frontal(j)))])
            pose = pose_2d(:,:,j);
            pose_2d(:,1:3,j)= pose(:,6:-1:4);
            pose_2d(:,4:6,j)= pose(:,3:-1:1);
            pose_2d(:,14:16,j)= pose(:,13:-1:11);
            pose_2d(:,11:13,j)= pose(:,16:-1:14);
            subplot(1,3,3);
            plot_pose_stickmodel(pose_2d(:,:,j)');
        end
    end
    IEF_val{ii} = reshape(pose_2d, 32, size(pose_2d,3))';
    save('IEF_val_refine.mat', 'IEF_val')
    %     IEF_training{ii} = reshape(pose_2d, 32, size(pose_2d,3))';
    %     save('IEF_training_refine.mat', 'IEF_training')
end

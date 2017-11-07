function reducedAngle3D = convert3D2fullB(predicted)
reducedAngle3D = zeros(size(predicted));
%predicted = F{1};
% ind = [1:3, 13:18, 25:30,37:39, 52:60, 70:78];
%predicted(:,ind) = [];

reducedAngle3D(:,1:2) = -100;
reducedAngle3D(:,3) = 1000; % x translation
for ii=1:size(predicted,1)
    reducedAngle3D(ii,4:12) = predicted(ii,1:9);
    reducedAngle3D(ii,13:18) =0;
    
    reducedAngle3D(ii,19:24) = predicted(ii, 10:15);
    reducedAngle3D(ii, 25:30) =0;
    
    reducedAngle3D(ii, 31:36) = predicted(ii, 16:21);
    reducedAngle3D(ii, 37:39) =0;
    
    reducedAngle3D(ii,19:24) = predicted(ii, 10:15);
    reducedAngle3D(ii, 25:30) =0;
    
    reducedAngle3D(ii, 31:36) = predicted(ii, 16:21);
    reducedAngle3D(ii, 37:39) =0;
    
    reducedAngle3D(ii, 40:51) = predicted(ii, 22:33);
    reducedAngle3D(ii, 52:60) = 0;
    
    reducedAngle3D(ii, 61:69) = predicted(ii, 34:42);
    reducedAngle3D(ii, 70:78) = 0;
    
end



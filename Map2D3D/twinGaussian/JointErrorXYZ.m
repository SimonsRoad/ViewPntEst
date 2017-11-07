function [Err, ex, ey, ez] = JointErrorXYZ(TGPTarget, TestTarget)
% Compute the 3d joint position error

CNum = 3;
D = size(TestTarget,2);
diffvalue = (TGPTarget - TestTarget).^2;
Errvec = zeros(size(TestTarget,1), D/CNum);
for i = 1:(D/CNum)
    ErrvecX(:,i) = sqrt(sum(diffvalue(:,(i-1)*CNum+1 ),2));
    ErrvecY(:,i) = sqrt(sum(diffvalue(:,(i-1)*CNum+2 ),2));
    ErrvecZ(:,i) = sqrt(sum(diffvalue(:,(i-1)*CNum+3),2));
    Errvec(:,i) = sqrt(sum(diffvalue(:,(i-1)*CNum+1 : i*CNum),2));
end
ex = mean(ErrvecX);
ey = mean(ErrvecY);
ez = mean(ErrvecZ);
Err = CNum*sum(Errvec,2)/D;


function [Err, Errvec] = JointError(TGPTarget, TestTarget)
% Compute the 3d joint position error

CNum = 3;
D = size(TestTarget,2);
diffvalue = (TGPTarget - TestTarget).^2;
Errvec = zeros(size(TestTarget,1), D/CNum);
for i = 1:(D/CNum)
    Errvec(:,i) = sqrt(sum(diffvalue(:,(i-1)*CNum+1 : i*CNum),2));
end
Err = CNum*sum(Errvec,2)/D;
 
% for i = 1:(D/CNum)
%     Errvec(:,i) = Errvec + sqrt(sum(diffvalue(:,(i-1)*CNum+1 : i*CNum),2));
% end
% Errvec = CNum*Errvec/D;
% Err = Errvec;
 

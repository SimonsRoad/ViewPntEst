function [Err] = JointError2(TestTarget, TGPTarget)
% Compute the 3d joint position error
% X = TestTarget;
% Y = TGPTarget;
% % mean per joint position distance
% Dm = zeros(size(X,1), size(X,2)/3);
% for i = 1: size(X,2)/3
%     Dm(:,i) = sqrt(sum((X(:,(i-1)*3+1:i*3)-Y(:,(i-1)*3+1:i*3)).^2,2));
% end
% Errvec = mean(Dm,2);




CNum = 3;
Errvec = zeros(size(TGPTarget,1),1);
diffvalue = bsxfun(@minus, TGPTarget,TestTarget).^2;
 D= size(TestTarget,2)/3;
for i = 1:D
    Errvec = Errvec + sqrt(sum(diffvalue(:,(i-1)*CNum+1 : i*CNum),2));
end

Err = Errvec/D;



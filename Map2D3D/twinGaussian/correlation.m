function [FY, DFr] = correlation(Y,r, Input, Target, Param, InvOK, InvIK, dzdy)

IR = EvalKernel(Input, r,'rbf',Param.kparam1);
alpha = InvIK*IR;
beta = EvalKernel(r, r,'rbf',Param.kparam1) + Param.lambda - IR'*InvIK*IR;

kvec = EvalKernel(Target, Y,'rbf', Param.kparam2);

InvOKkvec = InvOK*kvec;
ybeta = 1+ Param.lambda - kvec'*InvOKkvec;
FY = -2*alpha'*kvec - beta*log(ybeta);
DFr = zeros(size(r,2),1);
if dzdy
%     TTT = 2*(beta/ybeta*InvOKkvec - alpha);
    % DFY = 2*Param.kparam2.*((TTT.*kvec)'*Target - (TTT'*kvec)*Y')';
    tmp = bsxfun(@minus, r, Input);
    dKr = -2*Param.kparam1* bsxfun(@times, tmp, IR);
    % t2 = 2*log(ybeta)*bsxfun(@times, dKr, InvIK*IR);
    t2 = 2*log(ybeta)*IR'*InvIK*dKr;
    t1 = -2*(InvIK*dKr)'*kvec;
    DFr = -(t1' + t2);
end

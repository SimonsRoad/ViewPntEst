function TGPTarget = TGPTest(TestInput, Input, Target, Param, InvIK, InvOK)
% Make the prediction using Twin Gaussian Processess

T = size(TestInput,1);
TGPTarget = zeros(T,size(Target,2));
Weight = LinearRegressor(Input, Target);
for frame = 1:T
    % Initialize
    OneTestInput = TestInput(frame,:);
    EOneTestInput = [1 OneTestInput];
    InitTarget = (EOneTestInput*Weight)';
    %        TGPTarget(frame,:) = InitTarget';
    %     % optimize
    IR = EvalKernel(Input,OneTestInput,'rbf',Param.kparam1);
    alpha = InvIK*IR;
    beta = EvalKernel(OneTestInput,OneTestInput,'rbf',Param.kparam1) + Param.lambda - IR'*InvIK*IR;
    [Y] = ComputeOutput(InitTarget, Target, Param.kparam2, Param.lambda, alpha, beta, InvOK);
    TGPTarget(frame,:) = Y';
end

function [Y, fval] = ComputeOutput(Y, Target, kernelparam, lambda, alpha, beta, InvOK)

%% Compute the output

options = optimset('GradObj','on');
options = optimset(options,'LargeScale','off');
options = optimset(options,'DerivativeCheck','off');
options = optimset(options,'Display','off');
options = optimset(options,'MaxIter',50);
options = optimset(options,'TolFun',1e-6);
options = optimset(options,'TolX',1e-6);
% options = optimset(options,'LineSearchType','cubicpoly');
% options = optimoptions(@fminunc,'Algorithm','quasi-newton');
aaa = sum(Target.^2,2);
% options = optimoptions('Display','iter' );
% Optimization
%  ll=reshape(Y',3, 3);[norm(ll(:,1)-ll(:,2)), norm(ll(:,3)-ll(:,2))]
[Y, fval] = fminunc(@correlation,Y, options, Target, kernelparam, lambda, alpha, beta, InvOK, aaa);

% if body
%     [Y, fval] = fminunc(@correlation,Y, options, Target, kernelparam, lambda, alpha, beta, InvOK, aaa);
% else
%     options.MaxIter=100;
%     [Y, fval] = fmincon(@(x)correlation(x,Target, kernelparam, lambda, alpha, beta, InvOK, aaa),Y,[],[],[],[],[],[], @confuneq, options);
% end

% Cost function of twin Gaussian processes and its derivatives.
function [FY, DFY] = correlation(Y,Target,kernelparam, lambda, alpha, beta, InvOK, aaa)
bbb = sum(Y.^2);
kvec = exp(-kernelparam*(aaa + bbb - 2*Target*Y));
InvOKkvec = InvOK*kvec;
ybeta = 1+lambda - kvec'*InvOKkvec;
FY = -2*alpha'*kvec - beta*log(ybeta);
TTT = 2*(beta/ybeta*InvOKkvec - alpha);
DFY = 2*kernelparam.*((TTT.*kvec)'*Target - (TTT'*kvec)*Y')';

function [c,ceq] = confuneq(Y)
joints = reshape(Y',3, length(Y)/3);
upperArm = norm(joints(:,1) - joints(:,2));
lowArm = norm(joints(:,3) - joints(:,2));
% Nonlinear inequality constraints
% c = -x(1)*x(2) - 10;
% c = 150 -upperArm;
% Nonlinear equality constraints
% ceq = x(1)^2 + x(2) - 1;
% ceq = lowArm - 140;
c = [lowArm - upperArm; 230- lowArm];
ceq = [];

function Weight = LinearRegressor(Input, Target, Lambda)
%% Linear regression

[N, d] = size(Input);
BiasVec = ones(N,1);
Hessian = [BiasVec'*BiasVec BiasVec'*Input; Input'*BiasVec Input'*Input];
InputTarget = [sum(Target); Input'*Target];

if nargin < 3
    Lambda = 1e-5*mean(diag(Hessian));
else
    Lambda = Lambda*min(diag(Hessian));
end

Weight = (Hessian + Lambda*eye(d+1))\InputTarget;


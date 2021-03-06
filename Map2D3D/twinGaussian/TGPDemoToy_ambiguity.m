clear ;clc;close all
% demonstrate TGP on S data
% load data
load('./data/SData');
theta = 45:1:135;
  Target= [10-cos(theta*pi/180); sin(theta*pi/180)]';
Input = sin(theta*pi/180)';
ind = find(theta > 90);
a = ones(length(Input),1);
a(ind) = -1;
plot(a)
Input_a = [Input, a];
theta2 = 45;
TestInput = [sin(theta2*pi/180) 0]; %[1-cos(theta2*pi/180)  sin(theta2*pi/180)];
TestTarget = sin(theta2*pi/180);

%% Twin Gaussian Process
Param.kparam1 = 0.2;
Param.kparam2 = 0.2;
Param.lambda = 1e-4;
[InvIK, InvOK] = TGPTrain(Input_a, Target, Param);
TGPPred = TGPTest(TestInput, Input_a, Target, Param, InvIK, InvOK);
disp(['Error of TGP is: ' num2str(mean(abs(TGPPred(:)-TestTarget(:))))]);


%%
 plot([10, Target(1,1)], [0, Target(1,2)])
hold on;plot([10, Target(end,1)], [0, Target(end,2)],':r')
hold on
hold on;plot([10, TGPPred(end,1)], [0, TGPPred(end,2)],'-k')
axis equal
%%
figure(1)
plot(TestInput,TestTarget,'.','Markersize',10);
hold on
[aaa,index] = sort(TestInput);
plot(aaa,TGPPred(index),'r+','Markersize',8);
set(gca,'FontSize',16,'XLim',[-0.2 1.2],'YLim',[-0.2 1.2]);
legend('Ground Truth','Prediction','Location','NorthWest');
xlabel('Input');
ylabel('Output');
title('TGP (\gamma_{r} = 0.2, \gamma_{x} = 20 and Err = 0.116)');

%% Gaussian Process Regression
kparam = 20;
lambda = 1e-5;
K = EvalKernel(Input,Input,'rbf',kparam);
alpha = (K+lambda*eye(size(K)))\Target;
testK = EvalKernel(TestInput,Input,'rbf',kparam);
GPPred = testK*alpha;
disp(['Error of GP is: ' num2str(mean(abs(GPPred(:)-TestTarget(:))))]);

figure(2)
plot(TestInput,TestTarget,'.','Markersize',10);
hold on
[aaa,index] = sort(TestInput);
plot(aaa,GPPred(index),'r+','Markersize',8);
set(gca,'FontSize',16,'XLim',[-0.2 1.2],'YLim',[-0.2 1.2]);
legend('Ground Truth','Prediction','Location','NorthWest');
xlabel('Input');
ylabel('Output');
title('Gaussian Processes,\gamma = 2 and Err = 0.127');

%% Weighted K-Nearest Neighbour Regression
WKNNPred = WKNNRegressor(TestInput, Input, Target, 1);
disp(['Error of WKNN is: ' num2str(mean(abs(WKNNPred(:)-TestTarget(:))))]);
figure(3)
plot(TestInput,TestTarget,'.','Markersize',10);
hold on
[aaa,index] = sort(TestInput);
plot(aaa,WKNNPred(index),'r+','Markersize',8);
set(gca,'FontSize',16,'XLim',[-0.2 1.2],'YLim',[-0.2 1.2]);
legend('Ground Truth','Prediction','Location','NorthWest');
xlabel('Input');
ylabel('Output');
title('Weighted KNN, K = 1 and Err = 0.174');


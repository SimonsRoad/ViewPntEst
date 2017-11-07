function [InvIK, InvOK] = TGPTrain_orient(Input, Target, Param, cnn_feat)
% Train Twin Gaussian Processes

IK = EvalKernel(Input, Input, 'rbf', Param.kparam1);
OrientK = EvalKernel(cnn_feat, cnn_feat, 'rbf', Param.kparam1);
InvIK = inv(IK.*OrientK + Param.lambda*eye(size(IK)));

OK = EvalKernel(Target, Target, 'rbf', Param.kparam2);
InvOK = inv(OK.*OrientK + Param.lambda*eye(size(OK)));

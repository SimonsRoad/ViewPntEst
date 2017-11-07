function Input_aug = augment_cnnFeat(Input, cnn_feat)
dim = size(Input,2);
N = size(cnn_feat, 2);
Input_aug = zeros(size(Input,1), N + dim);
Input_aug(:,1:dim) = Input;
Input_aug(:,dim+1:end) = cnn_feat;

% for i=1:size(Input,1)
%     %     Input_aug(i, dim+orient(i)) = 1;
%     %     Input_aug(i, dim+1) = orient(i);
%     angle = (orient(i)-1)*pi/4;
%     Input_aug(i, dim+1) = cos(angle);
%     Input_aug(i, dim+2) = sin(angle);
% end
end

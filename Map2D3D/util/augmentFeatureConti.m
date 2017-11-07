function Input_aug = augmentFeatureConti(Input, angle)
dim = size(Input,2);
% Input_aug = zeros(size(Input,1), dim+8);
Input_aug = zeros(size(Input,1), dim+2);
Input_aug(:,1:dim) = Input;

for i=1:size(Input,1)
    Input_aug(i, dim+1) = angle(i);
%     Input_aug(i, dim+1) = cos(angle(i));
%     Input_aug(i, dim+2) = sin(angle(i));
end
 

function Input_aug = augmentFeature(Input, orient)
dim = size(Input,2);
% Input_aug = zeros(size(Input,1), dim+8);
Input_aug = zeros(size(Input,1), dim+2);
Input_aug(:,1:dim) = Input;

for i=1:size(Input,1)
    %     Input_aug(i, dim+orient(i)) = 1;
    %     Input_aug(i, dim+1) = orient(i);
    angle = (orient(i)-1)*pi/4;
    Input_aug(i, dim+1) = cos(angle);
    Input_aug(i, dim+2) = sin(angle);
end
%%
% Input_aug = zeros(size(Input,1), 32+2+6*2);
% Input_aug(:,1:32) = Input;
% for i=1:size(Input,1)
%     if orient(i) ==1
%         Input_aug(i,32+1) = 1;
%     elseif orient(i) == 5
%         Input_aug(i,32+2) = 1;
%     elseif (orient(i) ==2 || orient(i) ==3 || orient(i) ==4)
%         if right_hand_orient((i)) == 1
%             Input_aug(i,32+2+ orient(i)-1) = 1;
%         else
%             Input_aug(i,32+2+ 3 + orient(i)-1) = 1;
%         end
%
%     elseif (orient(i) == 6 || orient(i) == 7 || orient(i) == 8)
%         if left_hand_orient((i)) == 1
%             Input_aug(i,32+2+6+ orient(i)-5) = 1;
%         else
%             Input_aug(i,32+2+6+3 + orient(i)-5) = 1;
%         end
%     end
% end

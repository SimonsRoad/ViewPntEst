function err = calc_err2d(target, test)
% diff_2d = target - repmat(test, size(target,1), 1);
diff_2d = target -  test;
err = zeros(size(target,1),1);

for i=1:2:size(diff_2d,2)
    err = err + sqrt(sum(diff_2d(:,i:i+1).^2, 2));
end
err = err/(size(diff_2d,2)/2);

 

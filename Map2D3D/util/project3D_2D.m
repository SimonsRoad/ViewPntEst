function pose = project3D_2D(X, skel, obj, im)
X = reshape(X, 3,length(X)/3)';
[PX D] = ProjectPointRadial(X, obj.R, obj.T, obj.f, obj.c, obj.k, obj.p);
PX = PX';
PX = PX(:);
vals = bvh2xy(skel, PX);
 
 figure;
hold on;plot(vals(16,1),   vals(16,2), 'r*')
hold on;plot(vals(14,1),   vals(14,2), '*m')
hold on;plot(vals(2:4,1),  vals(2:4,2), '*g')
hold on;plot(vals(26:28,1),vals(26:28,2), 'sg')

hold on;plot(vals(7:9, 1), vals(7:9,2), '*r')
hold on;plot(vals(18:20,1), vals(18:20,2), 'sr')
hold on;imshow(im)
pose = [vals(2:4,:); vals(7:9,:); [0,0] ; vals(13:16,:); vals(26:28,:); vals(18:20,:)];

% 1: hip (middle) (12=1)
%  13, spine middle
% 14: neck
% 15: neck2
% 16: head
%18,19,20: L shoulder, L hand
%26,27,28: Right shoulder
%7,8, 9: l leg  
%2,3, 4: r leg

% (5,6) ---> r-feet
% (10,11)--> l feet
%12 same as hip
% 17 is like 14
% 21:24  (the same)? left fingure
% 25 is like neck
% 29:32?
% ind = [1,2:4, 7:9, 13:16, 18:20, 26:28]
end

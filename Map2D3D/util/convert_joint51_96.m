function p96 = convert_joint51_96(p51)
p96 = zeros(1,96);
p96(1:12) = p51(1:12);
p96(13:15) = p96(10:12);
p96(16:18) = p96(10:12);
% % p96(13:18) = ? --> N = 6 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p96(19:27) = p51(13:21);
p96(28:30) = p51(19:21);
p96(31:33) = p51(19:21);
p96(34:36) = p51(1:3);       %-should be hip ?
% p96(28:36) = ?             N = 9/3   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p96(37:48) = p51(22:33);    %12/3=4--> spine
p96(49:51) = p96(40:42);    % repeat Neck
% p96(49:51) = ?            %N = 3/3 ? :(    col: 16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p96(52:60) = p51(34:42);    % N = 3 r hand
p96(61:72) = repmat(p96(58:60), 1,4);
p96(73:75) = p96(40:42);    % repeat Neck
% p96(61:75)                N = 15/3 = 5     col: 21:25?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p96(76:84) = p51(43:end);   % N = 3 left hand
p96(85:96) = repmat(p96(82:84), 1, 4);
% p96(85:96)                %N = 12/3 = 4 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

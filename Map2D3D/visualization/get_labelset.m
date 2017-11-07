function [lind, names, ind] = get_labelset(type)
% gets the right label ids and their names

all_labels =  [0    1    2    3    4    6    7    8    9   17   18   19   25   26   27 ...
  32 33   34   35   38   39   40   43   44   46   49   50   52   56   58 59 60 64];
all_label_names = {'Background','RHip', 'RKnee', 'RAnkle','RToe', 'LHip', 'LKnee', 'LAnkle','LToe', ...
  'LShoulder','LElbow','LWrist', 'RShoulder','RElbow','RWrist', ...
  'Pelvis', 'RThigh', 'RTibia', 'RFoot', 'LThigh', 'LTibia', 'LFoot', ...
  'LowBack','Chest', 'Head','LHumerus', 'LRadius','LHand', 'RHumerus', 'RRadius','None','RHand','GTMask'};
all_label_names = {'Background','RHip', 'RKnee', 'RAnkle','RToe', 'LHip', 'LKnee', 'LAnkle','LToe', ...
  'LShoulder','LElbow','LWrist', 'RShoulder','RElbow','RWrist', ...
  'Pelvis', 'RThigh', 'RTibia', 'RFoot', 'LThigh', 'LTibia', 'LFoot', ...
  'Abdomen','Chest', 'Head','LUpArm', 'LLowArm','LHand', 'RUpArm', 'RLowArm','None','RHand','GTMask'};

% alt_labels =  [0     2     3     4     6     7     8     9    17    18    19    25    26    27 ...
%   33    34    35    38    39    40    43    44    46    49    50    56    59  60 64];

switch type
  case {'background','BG'}
    ind = 1;
    
  case {'foreground','FG'}
    ind = all_labels==64;
   
  case 'all'
    ind = 1: length(all_labels);
    
  case 'ours'
    ind = [2 3 4 6 7 8 10 11 12 13 14 15 16 17 18 20 21 23 24 25 26 27 29 30];
    
  case {'joints','J'}
    ind = all_labels>0&all_labels<31;
    
  case 'parts'
    ind = all_labels>31&all_labels<61;
    
  case 'relevant'
%     ind = 2:length(all_labels)-1;
    ind = [2 3 4 6 7 8 10 11 12 13 14 15 16 17 18 20 21 23 24 25 26 27 29 30];
  
  case 'irelevant'
    ind = [1 length(all_labels)];
  
  case {'leftarm','LA'}
    ind = [10 11 12 26 27 28];
  
  case {'LUA'}
    ind = [10 26 11];
    
  case {'LLA'}
    ind = [11 12 27 28];
    
  case {'rightarm','RA'}
    ind = [13 14 15 29 30 31];
    
  case 'RUA'
    ind = [13 14 29];
    
  case 'RLA'
    ind = [14 15 30 31];
    
  case {'leftleg','LL'}
    ind = [6 7 8 9 20 21 22];
    
  case 'LUL'
    ind = [6 7 20];
    
  case 'LLL'
    ind = [7 8 9 21 22];
    
  case {'rightleg','RL'}
    ind = [2 3 4 5 17 18 19];
  
  case 'RUL'
    ind = [2 3 17];
    
  case 'RLL'
    ind = [3 4 5 18 19];
    
  case {'torsohead','TH'}
    ind = [2 6 10 13 23 24 25];
    
  case 'T'
    ind = [2 6 10 13 23 24];
    
  case 'UT'
    ind = [10 13 24];
    
  case 'LT'
    ind = [2 6 23];
    
  case 'H'
    ind = [25];
    
  case {'upperbody','UB'}
    ind = [2 6 10 11 12 13 14 15 23 24 25 26 27 28  29 30 31];
    
  case {'lowerbody','LB'}
    ind = [2 3 4 5 6 7 8 9 16 17 18 19 20 21 22];
    
  case {'fullbody','FB'}
    ind = 2:length(all_labels)-1;
  
  case all_label_names
    for ind = 1: length(all_label_names)
      if strcmp(all_label_names{ind},type)
        break;
      end
    end
    
  otherwise
end

lind = all_labels(ind);

if nargout >= 2
  names = all_label_names(ind);
end
end
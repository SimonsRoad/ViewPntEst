function NFeat = normalize_pose(Feat, skel, ref)

if strcmp(ref, 'hip')
%     Relative to hip
    Feat(:,1:end) = Feat(:,1:end) - repmat(Feat(:,1:3),[1 length(skel.tree)]);
end

skel.tree(14).children = [skel.tree(14).children 18 26];
skel.tree(18).parent = 14;
skel.tree(26).parent = 14;
skel.tree(1).children = [skel.tree(1).children 13];
skel.tree(13).parent = 1;
part = 'body';
switch part
    case 'rootpos'
        joints = 1;
    case 'rootrot'
        joints = 1;
    case 'leftarm'
        joints = 18:24;% p/p2/a fine
    case 'rightarm'
        joints = 26:32;% p/p2/a fine
    case 'head'
        joints = 14:16;% p/p2/a fine
    case 'rightleg'
        joints = 2:6;% p/p2/a fine
    case 'leftleg'
        joints = 7:11;% p/p2/a fine
    case 'upperbody'
        joints = [14:32];% p/p2/a fine
    case 'arms'
        joints = [16:32];% p/p2/a fine
    case 'legs'
        joints = 1:11;% p/p2/a fine
    case 'body'
        joints = [1 2 3 4 7 8 9 13 14 15 16 18 19 20 26 27 28];% p/p2/a fine
    otherwise
        error('Unknown');
end

skel2 = skel;
skel2.tree = skel.tree(1);
p = 1;
for i = 1: length(joints)
    % take node corresponding to joint
    skel2.tree(i) = skel.tree(joints(i));
    skel2.tree(i).children = [];
    
    % update the channels
    skel2.tree(i).posInd = p:p+length(skel.tree(joints(i)).posInd)-1;
    p = p + length(skel.tree(joints(i)).posInd);
    
    % update parents and children
    skel2.tree(i).rotInd = [];
    skel2.tree(i).parent = find(skel.tree(joints(i)).parent==joints);
    
    for j = 1: length(skel.tree(joints(i)).children)
        a = find(skel.tree(joints(i)).children(j)==joints);
        if ~isempty(a)
            skel2.tree(i).children = [skel2.tree(i).children a];
        end
    end
    if isempty(skel2.tree(i).parent)
        skel2.tree(i).parent = 0;
    end
end
idx = [skel.tree(joints).posInd];
NFeat = Feat(:,idx);
if strcmp(ref, 'neck')
    % Relative to head
    NFeat = NFeat(:,1:end) - repmat(NFeat(:,25:27),[1 17]);
end

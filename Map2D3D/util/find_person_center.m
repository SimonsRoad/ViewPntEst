clc;clear all;close all
small_4000;
load([CONF.exp_dir '/validation.mat']);
load([CONF.exp_dir 'human36m_big.mat']);

for ii= 1:length(METADATA.file_names)
    activity = sprintf('ActivitySpecific_%02d.mat', ii)
    load(['/home/tt/star/h80k/data/DenseFeatures/GTFGM/',activity]);
    val_ind = METADATA.val_indx{ii};
    activity= sprintf('ActivitySpecific_%02d.mat', ii);
    dirname = ['/val_imgs/activity_', num2str(ii), '/'];
    no_frms = length(val_ind);
    names = validation{ii}.names;
    center = zeros(2, no_frms);
    ii
    tic
    for i = 1:no_frms
        im =  imread([CONF.exp_dir ,names{i}]);
        mask = Ftrain{val_ind(i)};
        h = round(size(mask,1)*0.3);
        sel_row = mask(h,:);
        ind = find(sel_row~=0);
        center(2,i) = h;
        count = zeros(1,length(ind));
        start_ind = zeros(1,length(ind));
        end_ind = zeros(1,length(ind));
        for m = 1:length(ind)
            start_ind(m) = ind(m);
            count(m) = 0;
            mm = start_ind(m);
            while mask(h,mm)==1
                count(m) = count(m) + 1;
                mm =mm+1;
                if mm > size(mask,2)
                    break
                end
            end
            end_ind(m) = mm-1;
        end
        [max_c, ind_max] = max(count);
        center(1,i) = round(0.5*(end_ind(ind_max)+ start_ind(ind_max)));
        %         figure;subplot(121);imshow(im)
        %         subplot(122);imshow(mask)
        %         subplot(121); hold on;plot(center(1,i), center(2,i), '*r')
    end
    validation{ii}.body_cntr = center;
    toc
end
save([CONF.exp_dir '/validation_center.mat'], 'validation');
disp('validation done :)')


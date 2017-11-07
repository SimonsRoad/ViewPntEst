function center = calc_mask_center(mask)
h = round(size(mask,1)*0.3);
sel_row = mask(h,:);
ind = find(sel_row~=0);
center(2) = h;
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
center(1) = round(0.5*(end_ind(ind_max)+ start_ind(ind_max)));

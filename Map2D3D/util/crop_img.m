function crop_I = crop_img(orig_img, torso_pt, img_side, scales)
    crop_I = cell(numel(scales),1);
    for j=1:numel(scales) % iterate over scales
        lambda = scales(j);
        
        width = size(orig_img,2)*lambda;
        height = size(orig_img,1)*lambda;

        side = min(width, height);

        mean_x = torso_pt(1);
        mean_y = torso_pt(2);
        if 1 > torso_pt(2)
            torso_pt(2) = 1;
            mean_y = 1;
        end

        min_x = floor(mean_x - side/2);
        max_x = ceil(mean_x + side/2);
        min_y = floor(mean_y - side/2);
        max_y = ceil(mean_y + side/2);

        padd_y_1 = abs(min(0,min_y));
        padd_y_2 = max(0, max_y - size(orig_img,1));
        padd_x_1 = abs(min(0,min_x));
        padd_x_2 = max(0,max_x - size(orig_img,2));

        padd_img = orig_img;
        padd_img = padarray(padd_img, [padd_y_1 0], 'pre');
        padd_img = padarray(padd_img, [padd_y_2 0], 'post');
        padd_img = padarray(padd_img, [0 padd_x_1], 'pre');
        padd_img = padarray(padd_img, [0 padd_x_2], 'post');

        new_img = padd_img(min_y+padd_y_1+1:max_y+padd_y_1,min_x+padd_x_1+1:max_x+padd_x_1,:);

        img = imresize(new_img, [img_side img_side]);        
        
        crop_I{j} = img;        
    end
end

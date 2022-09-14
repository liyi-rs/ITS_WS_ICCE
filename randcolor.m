function color_value=randcolor(cmap)%Random color selection based on the ribbon
   [cmap_r,~] = size(cmap);
   radm_index = randi(cmap_r);
   color_value = cmap(radm_index,:);

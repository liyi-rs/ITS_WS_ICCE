function [tree_Metrics,rgb_color]=get_tree_metric_color(treelabel,treenum,segtree)% Extraction of tree result parameters and rendering
tree_Metrics = zeros(treenum,7);
cmap = [166,206,227;
        31,120,180;
        178,223,138;
        51,160,44;
        251,154,153;
        227,26,28;
        253,191,111;
        255,127,0;
        202,178,214;
        106,61,154;
        255,255,153;
        177,89,40] ./ 255;
[point_r,~] = size(segtree);
color_trees = zeros(point_r,3);
for i = 1:treenum
    subsegtrees = segtree(treelabel==i,:);
    [tree_Height,rows] = max(subsegtrees(:,3));
    tree_Crown = (max(subsegtrees(:,1))-min(subsegtrees(:,1))+max(subsegtrees(:,2))-min(subsegtrees(:,2)))/2;
    tree_Crown_X = max(subsegtrees(:,1))-min(subsegtrees(:,1));
    tree_Crown_Y = max(subsegtrees(:,2))-min(subsegtrees(:,2));
    tree_X = subsegtrees(rows,1);
    tree_Y = subsegtrees(rows,2);
    tree_color = randcolor(cmap);
    color_trees(treelabel==i,1) = tree_color(1);
    color_trees(treelabel==i,2) = tree_color(2);
    color_trees(treelabel==i,3) = tree_color(3);
    tree_Metrics(i,:) = [double(i),tree_X,tree_Y,tree_Crown,tree_Height,tree_Crown_X,tree_Crown_Y];
end
rgb_color = uint16(color_trees.*65535);

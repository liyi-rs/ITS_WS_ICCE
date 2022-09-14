% Code Name：Individual tree segmentation by improved connection center evolution clustering——batch V 1.0
% Author: Yee Lee(yili@mail.bnu.edu.cn), State Key Laboratory of Remote Sensing Science,China
% Data: 2022/09/11
%% Start
clc
clear
%% Directory of the data
%Input data path
las_input_dir = '~\*.las';%Segmented point clouds by the watershed algorithm (*.las) 
addpath('~');
bandwidth_file = importdata('~\bandwidth.txt');%Bandwidth file required by the Meanshift.
%Output Path
las_output_dir = '~\';%Please note that the backslash needs to be preserved
metrics_output_dir = '~\';%Please note that the backslash needs to be preserved
%List and length of data
filenamelist = dir(las_input_dir);
len = length(filenamelist);
%Process each file in turn
for f = 1:len
    %% Step1; read file
    file_name = filenamelist(f).name;
    pc = LASread(file_name);
    file_name_pre = file_name(1:end-11);
    file_name_index = strcmp(bandwidth_file.textdata,file_name);
    bandwidth = bandwidth_file.data(file_name_index);
    %% Step2: Extraction of the structural parameters obtained by the watershed algorithm.
    % Extraction location, tree height, and crown diameter.
    treelabel = pc.record.treeid;
    treelabel = get_treelabel_new(treelabel);
    treenum = max(pc.record.treeid);
    segtree = [pc.record.x, pc.record.y, pc.record.z,double(treelabel)];
    tree_Metrics_title = {'FID','Position_X','Position_Y','Crown','Height'};
    [tree_Metrics,rgb_color] = get_tree_metric_color(treelabel,treenum,segtree);
    tree_table = table(tree_Metrics(:,1),tree_Metrics(:,2),tree_Metrics(:,3),tree_Metrics(:,4),tree_Metrics(:,5),'VariableNames',tree_Metrics_title);
    writetable(tree_table,strcat(metrics_output_dir,file_name_pre,'_ws.csv'));
    % save point clouds
    pc.record.treeid = treelabel;
    pc.record.red = rgb_color(:,1);
    pc.record.green = rgb_color(:,2);
    pc.record.blue = rgb_color(:,3);
    LASwrite(pc,strcat(las_output_dir,file_name_pre,'_ws.las'));
    %% Individual tree segmentation by the improved CCE algorithm
    treenum = max(treelabel);
    treenumorign = treenum - 1;
    segtree_factor = segtree;
    segtree_factor(:,3) = segtree_factor(:,3)./6;%Vr:the vertical distance correction factor
    sigSq2 = 10;%Gaussian kernel
    [treelabel] = cce_seg(treenum,treenumorign,segtree_factor,bandwidth,treelabel,sigSq2);
    % Extraction location, tree height, and crown diameter.
    treenum = max(treelabel);
    segtree = [pc.record.x, pc.record.y, pc.record.z,double(treelabel)];
    [tree_Metrics,rgb_color] = get_tree_metric_color(treelabel,treenum,segtree);
    tree_table = table(tree_Metrics(:,1),tree_Metrics(:,2),tree_Metrics(:,3),tree_Metrics(:,4),tree_Metrics(:,5),'VariableNames',tree_Metrics_title);
    writetable(tree_table, strcat(metrics_output_dir,file_name_pre,'_ws_icce.csv'));
    % Save point clouds
    pc.record.treeid = treelabel;
    pc.record.red = rgb_color(:,1);
    pc.record.green = rgb_color(:,2);
    pc.record.blue = rgb_color(:,3);
    LASwrite(pc,strcat(las_output_dir,file_name_pre,'_ws_icce.las'));
%     %% Post-processing (optional, for plantations)
%     % Extraction of average tree height and crown diameter
%     sort_tree_height = sort(tree_Metrics(:,5));
%     [tree_size,~] = size(sort_tree_height);
%     mean_tree_height = mean(sort_tree_height(int32(tree_size*0.3):int32(tree_size*0.7)));
%     sort_tree_crown = sort(tree_Metrics(:,4));
%     mean_tree_crown = mean(sort_tree_crown(int32(tree_size*0.3):int32(tree_size*0.7)));
%     % Calculate horizontal distance
%     tree_xy_distance = sqrt(distance2matrix(tree_Metrics(:,2:3)));
%     %Combine the nearest neighboring trees with horizontal distance less than the average crown diameter and vertical distance less than 10m
%     tree_xy_distance(tree_xy_distance>=mean_tree_crown) = 0;
%     [~,indexl] = find(tree_xy_distance>0);
%     can_row_total = unique(indexl);
%     [can_indexr,~] = size(can_row_total);
%     tree_xy_distance(tree_xy_distance==0) = 10;
%     for i = 1:can_indexr
%         [min_d,min_d_index] = min(tree_xy_distance(can_row_total(i),:));
%         if abs(tree_Metrics(can_row_total(i),5) - tree_Metrics(min_d_index(1),5)) < 10 && min_d_index> can_row_total(i) && min_d < 10
%             treelabel(treelabel==can_row_total(i)) = min_d_index(1);
%         end
%     end
%     %Tree renumbering
%     newtreelabel = get_treelabel_new(treelabel);
%     treelabel = newtreelabel;
%     % Extraction location, tree height, and crown diameter.
%     treenum = max(treelabel);
%     segtree = [pc.record.x, pc.record.y, pc.record.z,double(treelabel)];
%     [tree_Metrics,rgb_color] = get_tree_metric_color(treelabel,treenum,segtree);
%     tree_table = table(tree_Metrics(:,1),tree_Metrics(:,2),tree_Metrics(:,3),tree_Metrics(:,4),tree_Metrics(:,5),'VariableNames',tree_Metrics_title);
%     writetable(tree_table, strcat(metrics_output_dir,file_name_pre,'_ws_icce_merge.csv'));
%     % Save point clouds
%     pc.record.treeid = treelabel;
%     pc.record.red = rgb_color(:,1);
%     pc.record.green = rgb_color(:,2);
%     pc.record.blue = rgb_color(:,3);
%     LASwrite(pc,strcat(las_output_dir,file_name_pre,'_ws_icce_merge.las'));
end
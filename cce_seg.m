function [treelabel1] = cce_seg(treenum,treenumorign,segtree_factor,bandwidth,treelabel,sigSq2)
    for i = 1:treenum
        subsegtrees_factor = segtree_factor(treelabel==i,1:3);
        [subsegtrees_factor_r,~] = size(subsegtrees_factor);
        %meanshift voxelization
        [clustCent,point2cluster,clustMembsCell] = MeanShiftCluster(subsegtrees_factor',bandwidth);
        [clustMembsCell_r,~]=size(clustMembsCell);
        clust_number = zeros(clustMembsCell_r,1);
        for m = 1:clustMembsCell_r
            [~,subclustMembsCell] = size(clustMembsCell{m,1});
            clust_number(m,1) = subclustMembsCell;
        end
        clust_number = clust_number./max(clust_number);
        if isempty(clust_number)
            continue
        end
        clustCent_factor = clust_number*clust_number';
        %CCE Cluster
        clustCent_xyz = clustCent';
        clustCent_xyz(:,1) = clustCent_xyz(:,1) - min(clustCent_xyz(:,1));
        clustCent_xyz(:,2) = clustCent_xyz(:,2) - min(clustCent_xyz(:,2));
        [cc_set,label_set,cost_set] = CCE(clustCent_xyz,sigSq2,1,100,clustCent_factor);%cce parameters
        if ~isempty(cc_set)
            [label_set_r,~]=size(label_set);
            label_all_case = ones(label_set_r,subsegtrees_factor_r);
            for v = 1:label_set_r
                cce_lable = label_set(v,:);
                [~,cce_lable_c] = size(cce_lable);
                point2cluster_copy = point2cluster;
                for u = 1:cce_lable_c
                    a = find(point2cluster_copy==u);
                    point2cluster_copy(a) = cce_lable(u);
                end
                label_all_case(v,:)=point2cluster_copy;
            end
            % Calculate whether the tree partitioned by the cce meets the requirements
            different_tree_result = zeros(label_set_r,1);
            subsegtrees_sub = subsegtrees_factor;
            subsegtrees_sub(:,3)=subsegtrees_sub(:,3).*6;
            for m = 1:label_set_r
                subsegtrees_label = label_all_case(m,:)';
                subsegtrees_label_u = unique(subsegtrees_label);
                [subsegtrees_label_u_r,~] = size(subsegtrees_label_u);
                tree_Metrics_sub = zeros(subsegtrees_label_u_r,1);
                for n = 1:subsegtrees_label_u_r
                    subsegtrees_sub_sub = subsegtrees_sub(subsegtrees_label==subsegtrees_label_u(n),:);
                    [subsegtrees_sub_sub_r,~] = size(subsegtrees_sub_sub);
                    [tree_Height,rows] = max(subsegtrees_sub_sub(:,3));
                    tree_Crown = (max(subsegtrees_sub_sub(:,1))-min(subsegtrees_sub_sub(:,1))+max(subsegtrees_sub_sub(:,2))-min(subsegtrees_sub_sub(:,2)))/2;
                    tree_Crown_X = max(subsegtrees_sub_sub(:,1))-min(subsegtrees_sub_sub(:,1));
                    tree_Crown_Y = max(subsegtrees_sub_sub(:,2))-min(subsegtrees_sub_sub(:,2));
                    % Whether the location of the highest point of the tree is reasonable
                    tree_height_x = subsegtrees_sub_sub(rows,1);
                    x_low = (max(subsegtrees_sub_sub(:,1)) + 7*min(subsegtrees_sub_sub(:,1)))/8;
                    x_high = (7*max(subsegtrees_sub_sub(:,1)) + min(subsegtrees_sub_sub(:,1)))/8;
                    tree_height_y = subsegtrees_sub_sub(rows,2);
                    y_low = (max(subsegtrees_sub_sub(:,2)) + 7*min(subsegtrees_sub_sub(:,2)))/8;
                    y_high = (7*max(subsegtrees_sub_sub(:,2)) + min(subsegtrees_sub_sub(:,2)))/8;
                    %Is the difference between east-west canopy width and north-south canopy width greater than the average canopy width?
                    crown_difference = abs(tree_Crown_X - tree_Crown_Y) - tree_Crown;
                    if  crown_difference < 0 & tree_height_x >x_low & tree_height_x<x_high & tree_height_y >y_low & tree_height_y<y_high
                        tree_Metrics_sub(n,1) = 1;
                    end
                end
                if sum(tree_Metrics_sub)==subsegtrees_label_u_r
                    different_tree_result(m,1) = 1;
                end
            end
            different_tree_result_index = find(different_tree_result==1);
            if ~isempty(different_tree_result_index)
                different_tree_result_index_1 = different_tree_result_index(1);
                end_label = label_all_case(different_tree_result_index_1,:);
                A = unique(end_label);
                [labelr,labell] = size(unique(end_label));
                for m = 1:labell
                    end_label(end_label == A(m)) = m;
                end
                newlabel = int32(end_label);
                labeladdstep = max(newlabel);
                newlabel = newlabel + treenumorign;
                newlabel(newlabel == (treenumorign+1)) = i;
                treelabel(treelabel==i) = newlabel;
                treenumorign = treenumorign + labeladdstep - 1;
                disp('已优化'+string(i)+'/'+string(treenum));
            end
        end
    end 
 treelabel1 = treelabel;
end


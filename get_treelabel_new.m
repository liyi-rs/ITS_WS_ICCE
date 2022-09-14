function newtreelabel=get_treelabel_new(treelabel)%Tree Re-numbering
treelabel_unique = unique(treelabel);
[labelr,~] = size(treelabel_unique);
for i = 1:labelr
    treelabel(treelabel == treelabel_unique(i)) = i-1;
end
newtreelabel = treelabel;
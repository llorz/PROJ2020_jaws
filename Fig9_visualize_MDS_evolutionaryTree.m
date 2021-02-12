clc; close all; clear;

opts.MaxIter = 1e4;
res = load('res_original.mat');

dist = res.dist_nn + res.dist_nn';
mesh_names = res.mesh_names;

figure(1); clf;
X = mdscale(squareform(dist),2,'Options',opts);
X = X - min(X) + 0.05;
scatter(X(:,1), X(:,2),60,'filled'); hold on; 
for i = 1:length(mesh_names)
        text(X(i,1),X(i,2),['  ',mesh_names{i}],'HorizontalAlignment','left','FontSize',12)
end
title('rigid alignment');
axis square;


%%
figure(2);
dist = res.dist_edge + res.dist_edge';
X = mdscale(squareform(dist),2,'Options',opts);
X = X - min(X) + 0.05; 
scatter(X(:,1), X(:,2),60,'filled'); hold on; 
for i = 1:length(mesh_names)
        text(X(i,1),X(i,2),['  ',mesh_names{i}],'HorizontalAlignment','left','FontSize',12)
end
title('Edge distortion');
axis square;

%%
%close all;
figure(3);
dist = res.dist_nn + res.dist_nn';
Z = linkage(squareform(dist),'average');
dendrogram(Z,'Orientation','left');
xl = yticklabels;

t = {};
for i = 1:10
    t{end+1} = mesh_names{str2double(xl(i,:))};
end
yticklabels(t);
xlabel('distances');
title('rigid alignment')

%%
figure(4);
dist = res.dist_edge + res.dist_edge';
Z = linkage(squareform(dist),'average');
dendrogram(Z,'Orientation','left');
xl = yticklabels;

t = {};
for i = 1:10
    t{end+1} = mesh_names{str2double(xl(i,:))};
end
yticklabels(t);
xlabel('distances');
title('Edge distortion')
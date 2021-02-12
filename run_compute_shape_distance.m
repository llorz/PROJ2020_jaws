clc; close all; clear;
proj_dir = '../PROJ2020_jaws/';
mesh_dir = [proj_dir, '/Dataset/original/vtx_5k/'];
maps_dir = [mesh_dir, 'maps_lmkini/'];
cache_dir = [mesh_dir, 'cache/'];
addpath(genpath('utils'))
addpath(genpath('func_main/'));
log_dir = [mesh_dir, 'deformation/'];
%%
fid = fopen([proj_dir,'Dataset/test_pairs.txt']);
test_pairs = textscan(fid,'%s\t%s');
fclose(fid);
test_pairs = horzcat(test_pairs{:});
mesh_names = unique(test_pairs(:));
%% compute pairwise shape difference
num = length(mesh_names);
dist_edge = zeros(num); % from edge distortion
dist_nn = zeros(num); % from rigid alignment error
for i = 1:num
    s1_name = mesh_names{i};
    S1 = load([cache_dir, s1_name,'.mat']);
    for j = setdiff(1:num,i)
        clc; fprintf('%d \t %d\n', i, j)
        s2_name = mesh_names{j};
        
        S2 = load([cache_dir, s2_name,'.mat']);
        
        T12 = dlmread([maps_dir, s1_name, '_', s2_name, '.map']);
        
        S1.area=sum(MESH.calc_tri_areas(S1.surface));
        S1.Elist = MESH.get_edge_list(S1);
        S1_final = MESH.MESH_IO.read_shape([log_dir,s1_name,'_',s2_name,'/meshes/100.obj']);
        S1_ini = MESH.MESH_IO.read_shape([log_dir,s1_name,'_',s2_name,'/meshes/001.obj']);
        X = S1.surface.VERT;
        Z = S1_final.surface.VERT;
        
        weight = compute_weight_from_corres(S1,S2, S1_ini.surface.VERT, S2.surface.VERT,T12);
        
        % edge distortion
        edge = S1.Elist;
        l1 = sqrt(sum((X(edge(:,1),:) - X(edge(:,2),:)).^2,2));
        l2 = sqrt(sum((Z(edge(:,1),:) - Z(edge(:,2),:)).^2,2));
        
        edge_weight = mean(weight(edge),2);
        err_edge = (edge_weight'*(l2./l1-1).^2)/sqrt(S1.area);
        
        % rigid alignement error
        X = S1_ini.surface.VERT;
        Y = S2.surface.VERT;
        nn12 = knnsearch(Y,X);
        err_nn = norm(diag(weight)*(X - Y(nn12, :)),'fro')/sqrt(S1.area);
        
        
        dist_edge(i,j) = err_edge;
        dist_nn(i,j) = err_nn;
    end
end
%% visualize the evolutionary true
figure(1)
dist = dist_edge + dist_edge';
% dist = dist_nn + dist_nn';
figure(1);
Z = linkage(squareform(dist),'average');
dendrogram(Z,'Orientation','left');
xl = yticklabels;

t = {};
for i = 1:10
    t{end+1} = mesh_names{str2double(xl(i,:))};
end
yticklabels(t);
xlabel('distances');
%% save the results
% save([save_dir, 'res_original.mat'],'dist_nn','dist_edge','mesh_names')

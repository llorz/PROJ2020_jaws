clc; close all; clear;
proj_dir = '../PROJ2020_jaws/';
mesh_dir = [proj_dir, '/Dataset/original/vtx_5k/'];
maps_dir = [mesh_dir, 'maps_lmkini/'];
cache_dir = [mesh_dir, 'cache/'];
addpath(genpath('utils'))
addpath(genpath('func_main/'));
%%
fid = fopen([proj_dir,'Dataset/test_pairs.txt']);
test_pairs = textscan(fid,'%s\t%s');
fclose(fid);
test_pairs = horzcat(test_pairs{:});
mesh_names = unique(test_pairs(:));
%%
log_dir = [mesh_dir, 'deformation/'];
num = length(mesh_names);
dist_edge = zeros(num);
dist_nn = zeros(num);
mesh_diff = cell(10,1);
for i = 1:10
    all_err = {};
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
        
        %weight = compute_weight_from_corres(S1,S2, S1_ini.surface.VERT, S2.surface.VERT,T12);
        % rigid alignement error
        X = S1_ini.surface.VERT;
        Y = S2.surface.VERT;
        nn12 = knnsearch(Y,X);
        [~, err1] = compute_weight_from_corres(S1,S2, S1_ini.surface.VERT, S2.surface.VERT,nn12);
        err2 = dlmread([mesh_dir, 'maps_consistency_error/',s1_name,'.err']);
        err = max(err1, err2*max(err1)/max(err2));
        tmp = exp(-err);
        weight = (tmp - min(tmp))/(max(tmp) - min(tmp));
        err_nn = sqrt(sum((diag(weight)*(X - Y(nn12, :))).^2,2))/sqrt(S1.area);
        all_err{end+1} = err_nn;
    end
    
    err = mean(cell2mat(all_err),2);
    mesh_diff{i} = err;
end
%%
figure(1)
for i = 1:10
    s1_name = mesh_names{i};
    S1 = MESH.MESH_IO.read_shape([mesh_dir, s1_name]);
    subplot(2,5,i); plot_func_on_mesh(S1, mesh_diff{i}); caxis([0,0.05]);
end
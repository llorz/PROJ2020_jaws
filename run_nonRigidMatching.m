clc; clear; clf;
proj_dir = '../PROJ2020_jaws/';
mesh_dir = [proj_dir, '/Dataset/original/vtx_5k/'];
maps_dir = [mesh_dir, 'maps_lmkini/'];
cache_dir = [mesh_dir, 'cache/'];
addpath(genpath('utils'))
addpath(genpath('func_main/'));
%% read the test_pair list
fid = fopen([proj_dir,'Dataset/test_pairs.txt']);
test_pairs = textscan(fid,'%s\t%s');
fclose(fid);
test_pairs = horzcat(test_pairs{:});
mesh_names = unique(test_pairs(:));
%%
s1_name = 'Arago89';
s2_name = 'SH5';
% S1 = MESH.MESH_IO.read_shape([mesh_dir, s1_name]);
% S2 = MESH.MESH_IO.read_shape([mesh_dir, s2_name]);
S1 = load([cache_dir, s1_name,'.mat']);
S2 = load([cache_dir, s2_name,'.mat']);
T12 = dlmread([maps_dir, s1_name, '_', s2_name, '.map']);
MESH.PLOT.visualize_map_colors(S1,S2,T12);
%% run non-rigid alignment
save_dir = [proj_dir, 'log/log0814_original/'];
nonRigidMatching_proj2BCICP_weighted_test(S1,S2,T12,save_dir);
return
%% for all shape pairs
for s1_id = 1:10
    s1_name = mesh_names{s1_id};
    S1 = load([cache_dir, s1_name,'.mat']);
    for s2_id = setdiff(1:10, s1_id)
        s2_name = mesh_names{s2_id};
        S2 = load([cache_dir, s2_name,'.mat']);
        T12 = dlmread([maps_dir, s1_name, '_', s2_name, '.map']);
        nonRigidMatching_proj2BCICP_weighted_test(S1,S2,T12,save_dir);
    end
end
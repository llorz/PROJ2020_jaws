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
figure(1);
for iMesh = 2:10
    s1_name = mesh_names{iMesh};
    s2_name = mesh_names{1};
    T12 = dlmread([maps_dir, s1_name,'_',s2_name,'.map']);
    S1 = MESH.MESH_IO.read_shape([mesh_dir, s1_name]);
    S2 = MESH.MESH_IO.read_shape([mesh_dir, s2_name]);
    subplot(2,5,iMesh)
    visualize_map_on_target(S1,S2,T12); title(s1_name)
end
subplot(2,5,1); visualize_map_on_source(S1,S2,T12); title(s2_name)
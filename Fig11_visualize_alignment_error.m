clc; close all; clear;
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
figure(2)
for s1_id = 1:10
    s1_name = mesh_names{s1_id};
    S1 = MESH.MESH_IO.read_shape([mesh_dir, s1_name]);
    err = dlmread([mesh_dir, 'alignment_error/',s1_name,'.txt']);
    subplot(2,5,s1_id);
    plot_func_on_mesh(S1, err); 
    caxis([quantile(err,0.5),quantile(err, 0.9)])
end

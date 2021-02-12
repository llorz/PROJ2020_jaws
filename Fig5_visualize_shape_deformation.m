clc; close all; clear;
proj_dir = '../PROJ2020_jaws/';
mesh_dir = [proj_dir, '/Dataset/original/vtx_5k/'];
maps_dir = [mesh_dir, 'maps_lmkini/'];
cache_dir = [mesh_dir, 'cache/'];
addpath(genpath('utils'))
addpath(genpath('func_main/'));
%%
s1_name = 'SH5';
s2_name = 'Sapien';

log_dir = [mesh_dir, 'deformation/',s1_name, '_', s2_name,'/meshes/'];
%%
S1 = MESH.MESH_IO.read_shape([log_dir, 'source_shape.obj']);
S2 = MESH.MESH_IO.read_shape([log_dir, 'target_shape.obj']);
S1_rigid = MESH.MESH_IO.read_shape([log_dir, '001.obj']); % rigid-alignment
S1_nonrigid = MESH.MESH_IO.read_shape([log_dir, '100.obj']); % non-rigid deformation after 100 iterations
%%
color_blue = [14,77,146]/255;
color_orange = [213,94,0]/255;

figure(1); 
MESH.PLOT.visualize_mesh(S2,'MeshVtxColor',repmat(color_blue,S2.nv,1)); hold on;
MESH.PLOT.visualize_mesh(S1,'MeshVtxColor',repmat(color_orange, S1.nv, 1)); hold off;
view([-80,-90])
title('Initial alignment');


figure(2);
MESH.PLOT.visualize_mesh(S2,'MeshVtxColor',repmat(color_blue,S2.nv,1)); hold on;
MESH.PLOT.visualize_mesh(S1_rigid,'MeshVtxColor',repmat(color_orange, S1_rigid.nv, 1)); hold off;
view([-80,-90])
title('rigid alignment');

figure(3);
MESH.PLOT.visualize_mesh(S2,'MeshVtxColor',repmat(color_blue,S2.nv,1)); hold on;
MESH.PLOT.visualize_mesh(S1_nonrigid,'MeshVtxColor',repmat(color_orange, S1_nonrigid.nv, 1)); hold off;
view([-80,-90])
title('non-rigid deformation');

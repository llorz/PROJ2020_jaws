clc; close all; clear;
proj_dir = '../PROJ2020_jaws/';
dt_type = 'original';
mesh_dir = [proj_dir, '/Dataset/',dt_type,'/vtx_5k/'];
cache_dir = [mesh_dir, 'cache/'];
addpath(genpath('utils'))
addpath(genpath('func_main/'));
%% read the test_pair list
fid = fopen([proj_dir,'Dataset/test_pairs.txt']);
test_pairs = textscan(fid,'%s\t%s');
fclose(fid);
test_pairs = horzcat(test_pairs{:});
%%
iPair = 1;
s1_name = test_pairs{iPair,1};
s2_name = test_pairs{iPair,2};
fprintf('%d: %s\t%s\n',iPair,s1_name,s2_name);
%
S1 = MESH.preprocess([mesh_dir, s1_name],'cacheDir',cache_dir);
S2 = MESH.preprocess([mesh_dir, s2_name],'cacheDir',cache_dir);

S1 = MESH.preprocess(S1, 'IfComputeNormals',true);
S2 = MESH.preprocess(S2, 'IfComputeNormals',true);

%% some parames
k1 = 20; k2 = 20;
numTimes = 100; numSkip = 20;

B1 = S1.evecs(:,1:k1); Ev1 = S1.evals(1:k1);
B2 = S2.evecs(:,1:k2); Ev2 = S2.evals(1:k2);
%% compute the descriptors
switch dt_type
    case 'remodelled' % without landmarks
        fct1 = waveKernelSignature(B1, Ev1, S1.A, numTimes);
        fct2 = waveKernelSignature(B2, Ev2, S2.A, numTimes);
        fct1 = fct1(:,1:numSkip:end);
        fct2 = fct2(:,1:numSkip:end);
        
    case 'original' % with manually selected landmarks
        lmk_dir = [mesh_dir, 'corres/'];
        lmk1 = dlmread([lmk_dir,s1_name,'.vts']);
        lmk2 = dlmread([lmk_dir,s2_name,'.vts']);
        fct1 = fMAP.compute_descriptors_with_landmarks(S1,k1,lmk1,numTimes,numSkip);
        fct2 = fMAP.compute_descriptors_with_landmarks(S2,k2,lmk2,numTimes,numSkip);
end
%%
% Initialization
[C12_ini] = compute_fMap_new(S1,S2,B1,B2,Ev1,Ev2,fct1,fct2);
C12_ini = fMAP.icp_refine(B1,B2,C12_ini,5);
T21_ini = fMAP.fMap2pMap(B1,B2,C12_ini);

[C21_ini] = compute_fMap_new(S2,S1,B2,B1,Ev2,Ev1,fct2,fct1);
C21_ini = fMAP.icp_refine(B2,B1,C21_ini,5);
T12_ini = fMAP.fMap2pMap(B2,B1,C21_ini);

figure(1);
subplot(1,2,1); MESH.PLOT.visualize_map_colors(S1,S2,T12_ini);
subplot(1,2,2); MESH.PLOT.visualize_map_colors(S2,S1,T21_ini);
return
%% run bcicp
tic
[T21_bcicp, T12_bcicp] = bcicp_refine(S1,S2,B1,B2,T21_ini, T12_ini,10);
t_bcicp = toc;
%%
figure(2);
subplot(1,2,1); MESH.PLOT.visualize_map_colors(S1,S2,T12_bcicp);
subplot(1,2,2); MESH.PLOT.visualize_map_colors(S2,S1,T21_bcicp);

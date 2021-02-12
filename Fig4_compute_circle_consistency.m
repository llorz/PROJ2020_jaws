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
%% compute circle consistency
% the errors are saved in "maps_consistency_error"
allRes = cell(10,1);
for s1_id = 1:10
    s1_name = mesh_names{s1_id};
    
    S1 = MESH.preprocess([mesh_dir, s1_name],'cacheDir',cache_dir);
    all_res = cell(72,4);
    all_err = zeros(72,1);
    id = 1;
    for s2_id = setdiff(1:10, s1_id)
        s2_name = mesh_names{s2_id};
        S2 = MESH.MESH_IO.read_shape([mesh_dir, s2_name]);
        for s3_id = setdiff(1:10, [s1_id, s2_id])
            s3_name = mesh_names{s3_id};
            S3 = MESH.MESH_IO.read_shape([mesh_dir, s3_name]);
            T12 = dlmread([maps_dir,S1.name,'_',S2.name,'.map']);
            T23 = dlmread([maps_dir,S2.name,'_',S3.name,'.map']);
            T31 = dlmread([maps_dir,S3.name,'_',S1.name,'.map']);
            
            T11 = T31(T23(T12));
    
            err = get_mat_entry(S1.Gamma,(1:S1.nv)',T11);
            all_res{id, 1} = s2_name;
            all_res{id, 2} = s3_name;
            all_res{id, 3} = T11;
            all_res{id, 4} = err/S1.sqrt_area;
            all_err(id) = mean(err);
            id = id + 1;
        end
    end
    allRes{s1_id} = all_res;
end
%%
err_all = cellfun(@(x) mean(cell2mat(x(:,4)'),2), allRes, 'un', 0);
%% visualize the error
figure(1)
for s1_id = 1:10
    s1_name = mesh_names{s1_id};
    S1 = MESH.MESH_IO.read_shape([mesh_dir, s1_name]);
    all_res = allRes{s1_id};
    tmp = all_res(:,4);
    err_ave = mean(cell2mat(tmp'),2);
    subplot(2,5,s1_id);
    plot_func_on_mesh(S1, err_ave); caxis([0,0.05])
end


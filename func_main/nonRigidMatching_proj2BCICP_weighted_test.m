function [] = nonRigidMatching_proj2BCICP_weighted_test(S1,S2,T12,log_dir)
save_dir = [log_dir,S1.name,'_',S2.name,'/'];
mkdir(save_dir);
mkdir([save_dir,'meshes/']);
w1 = 10; w2 = 10; w3 = 1000;
%% global registration first
X1_new = ICP_svd(S1.surface.VERT,S2.surface.VERT,T12);
%%
Z = X1_new'; Y = S2.surface.VERT';
X_neigh = S1.vtx_neigh;
weight12 = compute_weight_from_corres(S1,S2,Z',Y',T12);

%% consturct the Laplacian
A = -double(S1.W ~=0);
A(eye(size(A,1)) == 1) = 0;
W = A - diag(sum(A));
%% non-rigid shape  matching
max_iter1 = 10;
max_iter2 = 10;
all_Z = cell(max_iter1*max_iter2,1);
loss_iter = zeros(max_iter1*max_iter2,4);
iter_count = 1;

for iter1 = 1:max_iter1
    X = Z;
    for iter2 = 1:max_iter2

        MESH.MESH_IO.writeOBJ([save_dir,'meshes/',num2str(iter_count,'%03d'),'.obj'],Z', S1.surface.TRIV);       
        all_Z{iter_count,1} = Z;
        % local registration
        R_local = cellfun(@(neigh, i)svd_rigid_matching(X(:,neigh) - X(:,i), Z(:,neigh) - Z(:,i)),...
            X_neigh, num2cell(1:length(X_neigh))','un',0);
        % global registration
        X_hat = X - mean(X,2);
        Z_hat = Z - mean(Z,2);
        R_global = svd_rigid_matching(X_hat,Z_hat);
        t = mean(Z,2) - R_global*mean(X,2);
        
        n = length(X_neigh);
        B = zeros(3,n);
        for k = 1:n
            v = zeros(3,1);
            for j = reshape(X_neigh{k},1,[])
                v = v+(R_local{k} + R_local{j})*(X(:,k) - X(:,j));
            end
            B(:,k) = v;
        end
        Z = (w1*Y(:,T12)*diag(weight12) + w2*(R_global*X +t) + w3*B)/(w1*diag(weight12)+w2*eye(n) + 2*w3*W);
        %% compute the energy
        E1 = @(Z) norm((Z - Y(:,T12))*diag(weight12),'fro')^2;
        E2 = @(Z) 0.5*norm(Z -(R_global*X + t*ones(1,n)),'fro')^2;
        E3 = @(Z) 0.5*sum(cellfun(@(neigh_id,Ri,i) norm((Z(:,neigh_id) - Z(:,i)) - Ri*(X(:,neigh_id) - X(:,i)),'fro')^2,...
            X_neigh,R_local,num2cell(1:n)'));
        
        E = @(Z) w1*E1(Z) + w2*E2(Z) + w3*E3(Z);
        
        loss_iter(iter_count,:) = [E1(Z), E2(Z), E3(Z), E(Z)];
        iter_count = iter_count + 1;
        T12 = knnsearch(Y', Z');
        weight12 = compute_weight_from_corres(S1,S2,Z',Y',T12);
    end
end
%% save the mesh

MESH.MESH_IO.writeOBJ([save_dir,'meshes/','source_shape.obj'],S1.surface.VERT, S1.surface.TRIV);
MESH.MESH_IO.writeOBJ([save_dir,'meshes/','target_shape.obj'],S2.surface.VERT, S2.surface.TRIV);
%% log the energy per iteration
fid = fopen([save_dir,'energy_perIter.txt'],'w');
fprintf(fid,'%.5e\t%.5e\t%.5e\t%.5e\n',loss_iter');
fclose(fid);
end

function [err1, err2] = compute_self_map_error(S1,S2,X1,X2)
get_mat_entry = @(M,I,J) M(sub2ind(size(M),I,J));
nn12 = knnsearch(X2, X1);
nn21 = knnsearch(X1, X2);
T11 = nn21(nn12);
T22 = nn12(nn21);
err2 = get_mat_entry(S2.Gamma,(1:S2.nv)', T22);
err1 = get_mat_entry(S1.Gamma,(1:S1.nv)', T11);
end

function weight = compute_weight_from_corres(S1,S2,X1,X2,T12)
[err1, err2] = compute_self_map_error(S1,S2,X1,X2);
err = err1 + err2(T12);
err = (err - min(err))/(max(err) - min(err));
tmp = exp(-err);
weight = (tmp - min(tmp))/(max(tmp) - min(tmp));
end
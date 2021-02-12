% 2018-01-10
function [T21, T12] = bcicp_refine_jaw(S1,S2,B1,B2,T21_ini, T12_ini,num_iter)

compute_coverage = @(T) length(unique(T))/length(T);
T12 = T12_ini; T21 = T21_ini;
if compute_coverage(T21) > 0.5 && compute_coverage(T12) > 0.5
    T21 = fix_pMap_outliers(T21,S2,S1);
    T12 = fix_pMap_outliers(T12,S1,S2);
end
for iter = 1:num_iter
    C12 = B2\B1(T21,:);
    C21 = B1\B2(T12,:);
    C12 = C21'*mat_projection(C21*C12);
    C21 = C12'*mat_projection(C12*C21);
    
    Y1 = [B1*C12',B1];
    Y2 = [B2, B2*C21'];
    
    d2 = dist_xy(Y1,Y2); % cost matrix S1 -> S2
    [~,T12] = min(d2,[],2);
    [~,T21] = min(d2',[],2);
    
    if compute_coverage(T21) > 0.5 && compute_coverage(T12) > 0.5
        T21 = fix_pMap_outliers(T21,S2,S1);
        T12 = fix_pMap_outliers(T12,S1,S2);
    end
    
    % bijective ICP
    C1 = B1\B1(T21(T12),:);
    C1 = mat_projection(C1);
    C2 = B2\B2(T12(T21),:);
    C2 = mat_projection(C2);
    
    Y2 = [B1(T21,:)*C1',B2];
    Y1 = [B1, B2(T12,:)*C2'];
    d2 = dist_xy(Y2,Y1); % cost matrix S2 -> S1
    %     d2 = K2*d2*K1;
    [~,T21] = min(d2,[],2);
    [~,T12] = min(d2',[],2);
    
    % smooth the complete map: slow if #vtx is large!
    if compute_coverage(T21) > 0.5 && compute_coverage(T12) > 0.5
        T21 = fix_pMap_outliers(T21,S2,S1);
        T12 = fix_pMap_outliers(T12,S1,S2);
    end
    
end
end


function [weight, err] = compute_weight_from_corres(S1,S2,X1,X2,T12)
[err1, err2] = compute_self_map_error(S1,S2,X1,X2);
err = err1 + err2(T12);
err = (err - min(err))/(max(err) - min(err));
tmp = exp(-err);
weight = (tmp - min(tmp))/(max(tmp) - min(tmp));
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
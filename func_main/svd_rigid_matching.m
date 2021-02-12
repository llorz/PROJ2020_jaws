function R = svd_rigid_matching(X,Z)
    [U,~,V] = svd(X*Z');
    R = V*U';
end
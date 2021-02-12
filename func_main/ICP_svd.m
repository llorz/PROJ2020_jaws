function [X_new] = ICP_svd(X1,X2,T12_ini)
if nargin < 3, T12_ini = knnsearch(X2,X1); end
T12 = T12_ini;
[~, ~, X_new] = svd_rigid_alignment(X1,X2,T12);

while norm(X1 - X_new) > 1e-8
    T12 = knnsearch(X2,X_new);
    X1 = X_new;
    [~, ~, X_new] = svd_rigid_alignment(X_new,X2,T12);
end
end

function [theta, t, X_new] = svd_rigid_alignment(X1,X2,T12) 
X = X1;
Y = X2(T12,:);
% demean
X_bar = X - mean(X);
Y_bar = Y - mean(Y);
%
H = X_bar'*Y_bar;
[U,~,V] = svd(H);
% global rotation
theta = U*V';
% global translation
t = mean(Y) - mean(X)*theta;
X_new = X*theta + t;
end
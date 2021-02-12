function [theta, t, X_new] = svd_rigid_alignment(X1,X2,T12) 
X = X1;
Y = X2(T12,:);
% demean
X_bar = X - mean(X);
Y_bar = Y - mean(Y);
%%
H = X_bar'*Y_bar;
[U,~,V] = svd(H);
%%
theta = V*U';
t = mean(Y) - mean(X)*theta;
%%
X_new = X*theta + t;
end
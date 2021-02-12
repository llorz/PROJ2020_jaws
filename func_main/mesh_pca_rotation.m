function [S_new,U] = mesh_pca_rotation(S)
X = S.surface.VERT;
X_bar = X - mean(X);
C = X_bar'*X_bar;
[U,~] = eig(C);
Y = X*U;

S_new = construct_mesh(Y,S.surface.TRIV,S.name);
end

function S = construct_mesh(VERT, TRIV, mesh_name)
if nargin < 3, mesh_name = 'mesh'; end;
assert(size(VERT,2) == 3,'Incorrect: vertex set size');
assert(size(TRIV,2) == 3,'Incorrect: face set size');

S = struct();
S.surface.VERT = VERT;
S.surface.TRIV = TRIV;
S.name = mesh_name;
S.surface.X = VERT(:,1);
S.surface.Y = VERT(:,2);
S.surface.Z = VERT(:,3);
end
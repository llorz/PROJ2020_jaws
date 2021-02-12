function [refined, Cmaps] = map_refine_fast(S1, S2, map12,dim_out,step, nv)
s1 = full(sum(sum(S1.A)));
s2 = full(sum(sum(S2.A)));
S1.evecs = S1.evecs*sqrt(s1);
S2.evecs = S2.evecs*sqrt(s2);
B1 = S1.evecs;
B2 = S2.evecs;
X1 = B1(euclidean_fps(S1.surface, nv), :);
X2 = B2(euclidean_fps(S2.surface, nv), :);

C21in = fmap_encode_nn(B2, B1, map12, 20, 20);

Cmaps = fmap_upsample_keep_all(X2, X1, C21in, dim_out, step);
Cout = Cmaps{end};

refined = fmap_decode_nn(B2, B1, Cout);
end


function all_Cs = fmap_upsample_keep_all(X1, X2, Cin, dim_out, step)
C = Cin;

all_Cs = {};
all_Cs{1} = C;
for dim=size(C,2)+1:step:dim_out
    C = fmap_encode_nn(X1,X2, fmap_decode_nn(X1,X2,C), dim, dim);
    all_Cs{end+1} = C;
end
end


function C12 = fmap_encode_nn(X1, X2, nn, dim_out1, dim_out2)
X1out = X1(:,1:dim_out1);
X2out = X2(:,1:dim_out2);

C12 = X2out\X1out(nn,:);
end

function nn = fmap_decode_nn(X1, X2, C12)
dim1 = size(C12,1);
dim2 = size(C12,2);
nn = knnsearch(X1(:,1:dim2)*C12', X2(:,1:dim1));
end
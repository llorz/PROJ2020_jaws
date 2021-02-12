function refined = map_refine_new(S1, S2, map12, para)
dim_in = para.k_init;
dim_out = para.k_final;
step = para.k_step;

B1 = S1.evecs;
B2 = S2.evecs;
C21in = fmap_encode_nn(B2, B1, map12, dim_in, dim_in);


Cmaps = fmap_upsample_keep_all(B2, B1, C21in, dim_out, step);
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
function [T12, T21, all_T12, all_T21] = my_zoomOut_bidirection(S1, S2, T12_ini, T21_ini, para)

T12 = T12_ini; T21 = T21_ini;

% all_T12 = {T12}; all_T21 = {T21};

for k = para.k_ini : para.k_step : para.k_final
    B1 = S1.evecs(:,1:k); B2 = S2.evecs(:,1:k);
    C12 = [B2; B2(T12,:)] \ [B1(T21,:); B1];
    C21 = [B1; B1(T21,:)] \ [B2(T12,:); B2];
   
    %T12 = knnsearch([B2, B2*C12], [B1*C21, B1]);
    %T21 = knnsearch([B1, B1*C21], [B2*C12, B2]);
    
    T12 = knnsearch([B2*C21', B2*C12], [B1, B1]);
    T21 = knnsearch([B1*C12', B1*C21], [B2, B2]);
    
%     all_T12{end+1} = T12;
%     all_T21{end+1} = T21;
end
end
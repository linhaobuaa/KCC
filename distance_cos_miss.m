function D = distance_cos_miss(U,C,weight,n,r,K,sumKi,binIDX,M)
%==========================================================================
% FUNCTION: D = distance_cos(U,C,weight,n,r,K,sumKi,binIDX)
% DESCRIPTION: This function performs point-to-centroid distance
%              calculation using cosine similarity on data set with missing
%              values
%
% INPUTS:   U = parameters for utility function
%               Para1: U_c, U_H, U_cos, U_Lp
%               Para2: 'std'-standard, 'norm'-normalized
%               Para3: If U_Lp, can be used to set p
%           C = centroid matrix
%           weight = a r-by-1 adjusted weight vector
%           n = number of data points
%           r = number of basic partitions
%           K = the prefered number of clusters in consensus clustering
%           sumKi = the starting index matrix for r basic partitions
%           binIDX = a sparse representation of binarization of IDX
%           M = input matrix with non-zero entries
%
% OUTPUT:   D = an n-by-K matrix for point-to-centroid distance
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================
    D = zeros(n,K);
    D1 = zeros(K,r);
    
    for i=1:r
        D1(:,i) = sqrt(sum((C(:,(sumKi(i)+1):sumKi(i+1))).^2,2));
    end
    
    for l=1:n
        idx = M(l,:);
        D(l,:) = (sum(weight(idx))-...
            (C(:,binIDX(l,idx))./D1(:,idx))*weight(idx))';
    end
            
end
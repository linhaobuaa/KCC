function D = distance_euc(U,C,weight,n,r,K,sumKi,binIDX)
%==========================================================================
% FUNCTION: D = distance_euc(U,C,weight,n,r,K,sumKi,binIDX)
% DESCRIPTION: This function performs point-to-centroid distance
%              calculation using euclidean distance
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
%
% OUTPUT:   D = an n-by-K matrix for point-to-centroid distance.
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================
    D = zeros(n, K); % distance matrix for storing point-to-centroid distance
    D1 = zeros(K, r); % temp matrix storing the sum square of each part of centroid
    
    for i=1:r
        D1(:,i) = sum((C(:,(sumKi(i)+1):sumKi(i+1))).^2,2);
    end
    
    for l=1:n
        D(l,:) = (sum(weight)+(D1-2*C(:,binIDX(l,:)))*weight)';
    end
end
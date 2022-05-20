function C = sCentroid(idx,K,r,sumKi)
%==========================================================================
% FUNCTION: C = sCentroid(idx,K,r,sumKi)
% DESCRIPTION: A function to initialize centoroid for each cluster 
%
% INPUTS:   idx = K randomly sampled rows from the n * r cluster label matrix, 
%                 rows correspond to observations,
%                 columns correspond to basic partitions
%           K = the prefered number of clusters in consensus clustering
%           r = number of basic partitions
%           sumKi = the starting index matrix for r basic partitions 
%
% OUTPUT:   C = initialized centroid matrix for K clusters 
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

    C = zeros(K,sumKi(r+1));
    for l = 1:K
        C(l,idx(l,:)+sumKi(1:r)') = 1;
    end    
end
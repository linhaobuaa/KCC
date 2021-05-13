function C = sCentroid_miss(idx,K,r,Ki,sumKi)
%==========================================================================
% FUNCTION: C = sCentroid_miss(idx,K,r,sumKi)
% DESCRIPTION: A function to initialize centoroid for each cluster on data
% set with missing values
%
% INPUTS:   idx = an n * r matrix of cluster labels for n data points from
%                 r basic partitions, rows of X correspond to observations; 
%                 columns correspond to basic partitions (with missing values)
%           K = the prefered number of clusters in consensus clustering
%           r = number of basic partitions
%           Ki = an 1-by-r row vector, each entry indicating the number of
%                clusters in that basic partition
%           sumKi = the starting index matrix for r basic partitions
%
% OUTPUT:   C = initialized centroid matrix for K clusters 
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

    C = zeros(K,sumKi(r+1));
    for l = 1:K
        for i = 1:r
            if idx(l,i)>0 % data point without missing value
                C(l,idx(l,i)+sumKi(i)) = 1;
            else % data point with missing value
                C(l,randsample(Ki(i),1)+sumKi(i)) = 1;
            end
        end
    end
    
end
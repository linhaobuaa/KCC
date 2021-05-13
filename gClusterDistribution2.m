function P = gClusterDistribution2(index,K,n)
%==========================================================================
% FUNCTION: P = gClusterDistribution2(index,K,n)
% DESCRIPTION: This function calculates cluster distribution for basic partitions
%
% INPUTS:   index = an n * 1 matrix of cluster labels for n data points
%           K = the prefered number of clusters in consensus clustering
%           n = number of data points
%
% OUTPUT:   P = a max(Ki)-by-r matrix, stores cluster distribution for basic partitions
%
% Note: This function can handle both complete and incomplete basic
%       partitions.
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

    counts = hist(index,0:K);
    counts = counts';
    P = counts(2:K+1,:)./repmat(n-counts(1,:),K,1); % P may contains zero value, but it doesn't matter.

end
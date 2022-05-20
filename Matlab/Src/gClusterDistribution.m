function P = gClusterDistribution(IDX,Ki,n)
%==========================================================================
% FUNCTION: P = gClusterDistribution(IDX,Ki,n)
% DESCRIPTION: This function calculates cluster distribution for basic partitions
%
% INPUTS:   IDX = an n * r matrix of cluster labels for n data points from
%                 r basic partitions, rows of X correspond to observations; 
%                 columns correspond to basic partitions
%           Ki = an 1-by-r row vector, each entry indicating the number of
%                clusters in that basic partition
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

    maxKi = max(Ki);
    counts = hist(IDX,0:maxKi);
    P = counts(2:maxKi+1,:)./repmat(n-counts(1,:),maxKi,1); % P may contains zero value, but it doesn't matter.

end
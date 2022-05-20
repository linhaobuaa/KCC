function IDX = BasicCluster_RFS(Data, r, K, dist, nFeature)
%==========================================================================
% FUNCTION: IDX = BasicCluster_RFS(Data, r, K, dist, nFeature)
% DESCRIPTION: This function generate basic partition results using K-means as 
%              a basic clustering algorithm with Random Feature Selection strategy.
%
% INPUTS:   Data = a dataset matrix, rows of Data correspond to observations; columns
%               correspond to variables (exclude class labels!!)
%           r = the predefined number of basic partitions in the ensemble
%           K = the predefined number of clusters in the basic partitions
%           dist = the distance measure for k-means clustering, in p-dimensional space
%           nFeature = the number of randomly selected partial features for RFS 
%
% OUTPUT:   IDX = the basic clustering matrix, rows of IDX correspond
%                 to observations, columns correspond to basic partitions.
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================
    
    [n, p] = size(Data);
    IDX = zeros(n, r);
    
    for i = 1:r
        IDX(:, i) = kmeans(Data(:,randsample(p, nFeature)), K,...
        'distance', dist, 'emptyaction', 'singleton', 'replicates', 1);
    end
    
end
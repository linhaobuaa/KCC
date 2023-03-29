function [Distortion, Silhouette, CH] = inMeasure(X, cluster, k)
%==========================================================================
% FUNCTION: [Distortion, Silhouette, CH] = inMeasure(X, cluster, k)
% DESCRIPTION: This function is used to internally assess and evaluate 
%              clustering quality of a KCC solution, without access 
%              to the ground truth cluster labels.
%
% INPUTS:   X = the input data matrix
%           cluster = the clustering decision matrix returned by KCC
%           k = number of clusters
%
%
% OUTPUT:   Distortion = the distortion score, i.e., the sum of the
%                        distance squared between the data objects and 
%                        the centroid of their assigned cluster.
%           Silhouette = the average silhouette coefficient value of all
%                        data objects
%           CH         = the Calinski and Harabasz (CH) index
%
%==========================================================================
% copyright (c) 2022 Hao Lin & Hongfu Liu & Junjie Wu

% Note that, part of the implementation of distortion score computation is 
% based on the following: Cai, Deng. "Litekmeans: the fastest matlab 
% implementation of kmeans." Software available at: http://www.zjucadcg.cn/
% dengcai/Data/Clustering.html 311 (2011).
% The implementation of CalinskiHarabasz is based on the repository in 
% https://github.com/ljchang/CosanlabToolbox/blob/master/Matlab/Stats/
% CalinskiHarabasz.m
%==========================================================================

    % call silhouette function from the Matlab Statistics and Machine Learning Toolbox
    distance_sih = 'sqEuclidean'; % distance function used in silhouette calculation
    S = silhouette(X, cluster, distance_sih); %disp(size(S)); % n * 1
    Silhouette = mean(S); %disp(Silhouette);

    Distortion = zeros(k,1); % use 'sqEuclidean' as the distance function
    n = size(X,1);
    E = sparse(1:n,cluster,1,n,k,n);  % transform label into indicator matrix
    center = full((E*spdiags(1./sum(E,1)',0,k,k))'*X);    % compute center of each cluster
    aa = full(sum(X.*X,2));
    bb = full(sum(center.*center,2));
    ab = full(X*center');
    D = bsxfun(@plus,aa,bb') - 2*ab;
    D(D<0) = 0;
    D = sqrt(D);
    for j = 1:k
        Distortion(j,1) = sum(D(cluster==j,j));
    end
    % disp(Distortion);
    Distortion = sum(Distortion);
    % disp(Distortion);

    CH = CalinskiHarabasz(X, cluster, center, Distortion);
end

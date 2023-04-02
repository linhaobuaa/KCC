function IDX = BasicCluster_RPS_missing(Data, r, K, dist, randKi, percent)
%==========================================================================
% FUNCTION: IDX = BasicCluster_RPS_missing(Data, r, K, dist, randKi, percent)
% DESCRIPTION: This function randomly removes data instances from a data set and then employs k-means on the incomplete data set
%
% INPUTS:   Data = input data matrix
%           r = number of basic partitions
%           K = the prefered number of clusters in consensus clustering
%           dist = the distance measure for k-means clustering
%           randKi = a r-by-1 vector, the i-th entry of randKi represents the number of clusters in the i-th basic partition
%                    0: Ki=K, 1: Ki=random,Vector: Ki=randKi
%           percent = missing rate, ranges in [0, 1]
%
% OUTPUT:   IDX = incomplete basic partition matrix
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

    [n, p] = size(Data);
    IDX = zeros(n, r);
    [n1, p1] = size(randKi);
    
    if n1>1
        Ki = randKi; % here randKi is the given Ki   
    elseif randKi==1 && sqrt(n) > K
        Ki = randsample(K: ceil(sqrt(n)), r, true); % here Ki is randomized
    else
        Ki = K * ones(r, 1); % here Ki is equal to K
    end
    
    num = ceil(n * percent);
    missing_n = randsample(n, num);
    norm_n = setdiff([1:n], missing_n);
    
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
    kmeansfunc = @kmeans;
    if isOctave==1
        kmeansfunc = @kmeans_octave;
    end
   
    for i = 1:r
        IDX(missing_n, i) = 0;
        IDX(norm_n, i) = feval(kmeansfunc, Data(norm_n, :), Ki(i), 'distance', dist,...
        'emptyaction', 'singleton', 'replicates', 1);
    end
    
end
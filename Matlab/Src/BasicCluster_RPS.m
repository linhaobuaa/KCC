function IDX = BasicCluster_RPS(Data, r, K, dist, randKi)
%==========================================================================
% FUNCTION: IDX = BasicCluster_RPS(Data, r, K, dist, randKi)
% DESCRIPTION: This function generate basic partition results using K-means as 
%              a base clustering algorithm with Random Parameter Selection strategy.
%
% INPUTS:   Data = a dataset matrix, rows of Data correspond to observations; columns
%               correspond to variables (exclude class labels!!)
%           r = the predefined number of basic partitions in the ensemble
%           K = the predefined number of clusters in the basic partitions
%           dist = the distance measure for k-means clustering, in p-dimensional space
%           randKi = the number-of-clusters parameter for different basic partitions
%                    1: Ki=randomly sampled vector; a r-by-1 vector: Ki=randKi; other values: Ki=K 
%
% OUTPUT:   IDX = the basic clustering matrix result, rows of IDX correspond
%                 to observations, columns correspond to basic partitions.
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
        Ki = randsample(K:ceil(sqrt(n)), r, true); % here Ki is randomized
    else
        Ki = K * ones(r, 1); % here Ki is equal to K
    end
    
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
    kmeansfunc = @kmeans;
    if isOctave==1
        kmeansfunc = @kmeans_octave;
    end
    
    for i=1:r
    % parfor i=1:r % using the parallel `for-loop' in Parallel Computing Toolbox
        IDX(:, i) = feval(kmeansfunc, Data, Ki(i), 'distance', dist, ...
        'emptyaction', 'singleton', 'replicates', 1);
    end
    
end
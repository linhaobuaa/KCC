function C = gCentroid_miss(IDX,index,K,n,r,sumKi,Ki)
%==========================================================================
% FUNCTION: C = gCentroid_miss(IDX,index,K,n,r,sumKi,Ki)
% DESCRIPTION: A function to update centoroid for each cluster on data set
% with missing values
%
% INPUTS:   IDX = an n * r matrix of cluster labels for n data points from
%                 r basic partitions, rows of X correspond to observations; 
%                 columns correspond to basic partitions (with missing values)
%           index = an n * 1 matrix of cluster labels for n data points
%           K = the prefered number of clusters in consensus clustering
%           n = number of data points
%           r = number of basic partitions
%           sumKi = the starting index matrix for r basic partitions 
%           Ki = an 1-by-r row vector, each entry indicating the number of
%                clusters in that basic partition
%
% OUTPUT:   C = updated centroid matrix for K clusters 
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

    C = zeros(K,sumKi(r+1));  % initialize centroid matrix
    num = zeros(K,1);         % initialize matrix storing number of data points for each cluster
    maxKi= max(Ki);           % calculate the maximum number of clusters in basic partitions
    
    for k=1:K
        members = (index==k); % vector indicating whether each data point belongs to the kth cluster or not
        
        if any(members) % if the kth cluster is not empty, update the centroid matrix.
            num(k) = sum(members); % calculate the number of data points in the kth cluster.
            idx = IDX(members,:); % get the values in the IDX matrix for members in the kth cluster
            counts = hist(idx,(0:maxKi)); % calculate cluster distribution of data points in basic partitions, 0 indicats the number of missing values in basic patitions
            if size(counts,1) == 1
                for i = 1:r
                    if idx(i)>0 % For data point without missing value
                        C(k,idx(i)+sumKi(i)) = 1;
                    else % For data point with missing value
                        C(k,randsample(Ki(i),1)+sumKi(i)) = 1;
                    end
                end
            else
                for i = 1:r
                    if counts(1,i)==num(k) % all members in ith basic partition is missing
                        C(k,randsample(Ki(i),1)+sumKi(i)) = 1;
                    else
                        C(k,sumKi(i)+1:sumKi(i+1)) = counts(2:Ki(i)+1,i)'/...
                            (num(k)-counts(1,i));
                    end
                end
            end
            
        else % if there is empty cluster, a random sample will be selected as the cluster centroid.
            C(k,:) = sCentroid_miss(IDX(randsample(n,1),:),1,r,Ki,sumKi);
        end
        
    end
end
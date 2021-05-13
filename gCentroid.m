function C = gCentroid(IDX,index,K,n,r,sumKi,Ki)
%==========================================================================
% FUNCTION: C = gCentroid(IDX,index,K,n,r,sumKi,Ki)
% DESCRIPTION: A function to update centoroid for each cluster
%
% INPUTS:   IDX = an n * r matrix of cluster labels for n data points from
%                 r basic partitions, rows of X correspond to observations; 
%                 columns correspond to basic partitions
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
            num(k) = sum(members); % calculate the number of data points in the kth cluster
            idx = IDX(members,:); % get the values in the IDX matrix for members in the kth cluster
            counts = hist(idx,(1:maxKi)); % calculate cluster distribution of data points in basic partitions
            if size(counts,1) == 1
                C(k,idx+sumKi(1:r)') = 1;
            else
                for i = 1:r
                    C(k,sumKi(i)+1:sumKi(i+1)) = counts(1:Ki(i),i)'/num(k);
                end
            end
            
        else % if the kth cluster is not empty, randomly sample a data point as its centroid.
            C(k,:) = sCentroid(IDX(randsample(n,1),:),1,r,sumKi);
        end
        
    end
end
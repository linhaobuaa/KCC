function [Ki,sumKi,binIDX,missFlag,missMatrix,distance,Pvector,weight]=...
        Preprocess(IDX, U, n, r, w, utilFlag)
%==========================================================================
% FUNCTION: [Ki,sumKi,binIDX,missFlag,missMatrix,distance,Pvector,weight]=...
%        Preprocess(IDX, U, n, r, w, utilFlag)
% DESCRIPTION: This function performs preprocessing for consensus clustering
%
% INPUTS:   IDX = an n * r matrix of cluster labels for n data points from
%                 r basic partitions, rows of X correspond to observations; 
%                 columns correspond to basic partitions
%           U = parameters for utility function
%               Para1: U_c, U_H, U_cos, U_Lp
%               Para2: 'std'-standard, 'norm'-normalized
%               Para3: If U_Lp, can be used to set p
%           n = number of data points
%           r = number of basic partitions
%           w = weight parameter vector for different basic partitions
%           utilFlag = a flag indicating whether to calcualte utility
%                      function during the iterative computation, 1-calculate; 0-not
%                      calculate
%
% OUTPUT:   Ki = an 1-by-r row vector, each entry indicating the number of
%                clusters in that basic partition
%           sumKi = the starting index matrix for r basic partitions
%           binIDX = a sparse representation of binarization of IDX
%           missFlag = indicating whether the input IDX matrix contains
%                      incomplete basic partitions, 0-miss;1-not miss
%           missMatrix = input matrix with non-zero entries
%           distance = indicator of the distance function correspondent to a specific utility function
%           Pvector = a 1-by-r constant vector calculated based on distributions of basic partitions
%           weight = a r-by-1 weight vector adjusted for distance computation
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

    Ki = max(IDX); % vector storing the number of clusters for each basic clustering
    sumKi = zeros(r+1,1); % a 1-by-r+1 row vector, sumKi(i) refers to the starting index of the ith basic partition for each data point
    for i=1:r 
        sumKi(i+1) = sumKi(i)+Ki(i);
    end
    binIDX = IDX+repmat(sumKi(1:r)',n,1); % binIDX indicates the offset position of the ones values in the binary data matrix
    
    if sum(any(IDX==0))>0  % if there is missing values in IDX matrix
        missFlag = 1; % indicates missing values
        missMatrix = IDX>0; % non-zero entries of IDX
    else % 
        missFlag = 0;
        missMatrix = [];
    end
    
    if missFlag == 1
        switch lower(U{1,1})
            case 'u_c'
                distance = @distance_euc_miss;
            case 'u_h'
                distance = @distance_kl_miss;
            case 'u_cos'
                distance = @distance_cos_miss;
            case 'u_lp'
                distance = @distance_lp_miss;
            otherwise
                error('Preprocess:UnknowUtilityFunction',...
                    'Currently only support U_c,U_H,U_cos,U_Lp.');
        end
    else 
        switch lower(U{1,1})
            case 'u_c'
                distance = @distance_euc;
            case 'u_h'
                distance = @distance_kl;
            case 'u_cos'
                distance = @distance_cos;
            case 'u_lp'
                distance = @distance_lp;
            otherwise
                error('Preprocess:UnknowUtilityFunction',...
                    'Currently only support U_c,U_H,U_cos,U_Lp.');
        end
    end
    
    if (strcmpi(U{1,2},'norm')==1 || utilFlag==1) % if normalized distance calculation and utility calculation are required
        P = gClusterDistribution(IDX,Ki,n); % calculate cluster distribution of basic partitions
        
        switch lower(U{1,1})
            case 'u_c'
                Pvector = sum(P.^2);
            case 'u_h'
                Pvector = -sum(P.*log2(P+eps));
            case 'u_cos'
                Pvector = sqrt(sum(P.^2));
            case 'u_lp'
                p = U{1,3};
                Pvector = (sum(P.^p)).^(1/p);
            otherwise
                error('Preprocess:UnknowUtilityFunction',...
                    'Currently only support U_c,U_H,U_cos,U_Lp.');
        end
    else
        Pvector = [];
    end
    
    switch lower(U{1,2}) % calculate weight in advance for accelerate distance calculation
        case 'std'
            weight = w; % no adjustment for weight
        case 'norm'
            weight = w./Pvector'; % adjust weight for distance calculation
        otherwise
             error('Preprocess:UnknownUtilityType',...
                'Only support two types of utility: std, norm');
    end
    
end
function util = UCompute(index,U,w,C,n,r,K,sumKi,Pvector)
%==========================================================================
% FUNCTION: util = UCompute(index,U,w,C,n,r,K,sumKi,Pvector)
% DESCRIPTION: This function performs utility calculating for consensus
%              clustering
%
% INPUTS:   index = an n * 1 matrix of cluster labels for n data points
%           U = parameters for utility function
%               Para1: U_c, U_H, U_cos, U_Lp
%               Para2: 'std'-standard, 'norm'-normalized
%               Para3: If U_Lp, can be used to set p
%           w = weight parameter vector for different basic partitions
%           C = centroid matrix
%           n = number of data points
%           r = number of basic partitions
%           K = the prefered number of clusters in consensus clustering
%           sumKi = the starting index matrix for r basic partitions
%           Pvector = a 1-by-r constant vector calculated based on distributions of basic partitions
%
% OUTPUT:   util = an 2-by-1 utility value
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================
    
    Pc = gClusterDistribution2(index,K,n); % calculate overall cluster distribution 
    Pci = repmat(Pc,1,r); % cluster distribution for each basic partition
    
    Cmatrix = zeros(K,r);
    util = zeros(2,1); % first value refers to utility gain or gain ratio, second value refers to adjusted utility
    
    switch lower(U{1,1}) % U{1,1} denotes the type of the utility function
        case 'u_c'
            for i=1:r
                tmp = C(:,(sumKi(i)+1):sumKi(i+1));
                Cmatrix(:,i) = sum(tmp.^2,2);
            end
            if strcmp(U{1,2},'std')==1 % U{1,2} indicates whether to use the normalized utility function
                util(1,1) = (sum(Pci.*Cmatrix)-Pvector)*w;
                util(2,1) = util(1,1)/sum(Pc.^2);
            else % normalized case
                util(1,1) = (sum(Pci.*Cmatrix)-Pvector)*(w./Pvector');
                util(2,1) = (sum(Pci.*Cmatrix)-Pvector)*(w./sqrt(Pvector'))/sqrt(sum(Pc.^2));
            end
        case 'u_h'
            for i=1:r
                tmp = C(:,(sumKi(i)+1):sumKi(i+1));
                Cmatrix(:,i) = sum(tmp.*log2(tmp+eps),2);
            end
             if strcmp(U{1,2},'std')==1
                 util(1,1) = (sum(Pci.*Cmatrix)-Pvector)*w;
                 util(2,1) = util(1,1)/(-sum(Pc.*log2(Pc)));
             else
                 util(1,1) = (sum(Pci.*Cmatrix)-Pvector)*(w./(-Pvector'));
                 util(2,1) = (sum(Pci.*Cmatrix)-Pvector)*(w./sqrt(-Pvector'))/sqrt(-sum(Pc.*log2(Pc)));
             end            
        case 'u_cos'
            for i=1:r
                tmp = C(:,(sumKi(i)+1):sumKi(i+1));
                Cmatrix(:,i) = sqrt(sum(tmp.^2,2));
            end
            if strcmp(U{1,2},'std')==1
                util(1,1) = (sum(Pci.*Cmatrix)-Pvector)*w;
                util(2,1) = util(1,1)/sqrt(sum(Pc.^2));
            else
                util(1,1) = (sum(Pci.*Cmatrix)-Pvector)*(w./Pvector');
                util(2,1) = (sum(Pci.*Cmatrix)-Pvector)*(w./sqrt(Pvector'))/sqrt(sqrt(sum(Pc.^2)));
            end            
        case 'u_lp'
            p = U{1,3};
            for i=1:r
                tmp = C(:,(sumKi(i)+1):sumKi(i+1));
                Cmatrix(:,i) = (sum(tmp.^p,2)).^(1/p);
            end
            if strcmp(U{1,2},'std')==1
                util(1,1) = (sum(Pci.*Cmatrix)-Pvector)*w;
                util(2,1) = util(1,1)/sum(Pc.^p)^(1/p);
            else
                util(1,1) = (sum(Pci.*Cmatrix)-Pvector)*(w./Pvector');
                util(2,1) = (sum(Pci.*Cmatrix)-Pvector)*(w./sqrt(Pvector'))/sqrt(sum(Pc.^p)^(1/p));
            end            
        otherwise
            error('UCompute:UnknowUtilityFunction',...
                'Currently only support U_c,U_H,U_cos,U_Lp.');
    end
end
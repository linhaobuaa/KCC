function [sumbest,index,converge,utility] = KCC(IDX, K, U, w, weight, ...
    distance, maxIter, minThres, utilFlag, missFlag, missMatrix, ...
    n, r, Ki, sumKi, binIDX, Pvector)
%==========================================================================
% FUNCTION: [sumbest,index,converge,] = KCC(IDX, K, U, w, weight, ...
%    distance, maxIter, minThres, utilFlag, missFlag, missMatrix, ...
%    n, r, Ki, sumKi, binIDX, Pvector)
% DESCRIPTION: This function performs consensus clustering with different 
% KCC utility functions
%
% INPUTS:   IDX = an n * r matrix of cluster labels for n data points from
%                 r basic partitions, rows of X correspond to observations; 
%                 columns correspond to basic partitions
%           K = the prefered number of clusters in consensus clustering
%           U = parameters for utility function
%               Para1: U_c, U_H, U_cos, U_Lp
%               Para2: 'std'-standard, 'norm'-normalized
%               Para3: If U_Lp, can be used to set p
%           w = weight parameter vector for different basic partitions
%           weight = a r-by-1 weight vector adjusted for distance computation
%           distance = indicator of the distance function correspondent to a specific utility function
%           maxIter = the maximum number of iterations for the convergence
%           minIter = the minimum number of iterations for the convergence
%           minThres = the minimum reduced threshold of objective function
%           utilFlag = a flag indicating whether to calcualte utility
%                      function during the iterative computation, 1-calculate; 0-not
%                      calculate
%           missFlag = indicating whether the input IDX matrix contains
%                      incomplete basic partitions, 0-miss;1-not miss
%           missMatrix = input matrix with non-zero entries
%           n = number of data points
%           r = number of basic partitions
%           Ki = an 1-by-r row vector, each entry indicating the number of
%                clusters in that basic partition
%           sumKi = the starting index matrix for r basic partitions
%           binIDX = a sparse representation of binarization of IDX
%           Pvector = a 1-by-r constant vector calculated based on distributions of basic partitions
%
% OUTPUT:   sumbest = the optimal value of objective function
%           index = the final clustering decision matrix for n data points
%           converge = the iterative values of objective function
%           utility = the final value of utility function
%
% Note: Under four different circumstances according to utilFlag and
%       missFlag, KCC invokes different auxiliary functions for distance
%       calculation and utility calculation, which accelerates computation.
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

if (utilFlag==1 && missFlag==1) % If calculating utility and there are missing values
    C = sCentroid_miss(IDX(randsample(n,K),:),K,r,Ki,sumKi); % initialize centroid matrix
    sumbest = inf;
    converge = zeros(100,1)-1;
    utility = zeros(100,2)-1;
            
    for i = 1:maxIter % first stop criteria for iteration
        D = feval(distance,U,C,weight,n,r,K,sumKi,binIDX,missMatrix);
        [d, idx] = min(D, [], 2); % assgin data points to nearest centroids
        totalsum = sum(d); 
        
        if abs(sumbest - totalsum) < minThres % second stop criteria for iteration
            break;           
        elseif totalsum < sumbest % if the value of objective function significantly decreases, continue iteration.
            index = idx; % store current cluster assginments
            C = gCentroid_miss(IDX,index,K,n,r,sumKi,Ki); % update centroid
            sumbest = totalsum; % store current value of objective function
            converge(i) = sumbest;
            utility(i,:) = (UCompute_miss(index,U,w,C,n,r,K,sumKi,Pvector,missMatrix))'; % calculate utility function 
        else % the value of objective function due to floating-point calculation, stop the iteration.
            warning('KCC:OptimizationException',...
                'The objective function value increases.');
            break;
        end 
    end
    
elseif  (utilFlag==1 && missFlag==0) % If calculating utility and there are no missing values
    C = sCentroid(IDX(randsample(n,K),:),K,r,sumKi); % initialize centroid matrix
    sumbest = inf;
    converge = zeros(100,1)-1;
    utility = zeros(100,2)-1;
            
    for i = 1:maxIter
        D = feval(distance,U,C,weight,n,r,K,sumKi,binIDX);
        [d, idx] = min(D, [], 2);
        totalsum = sum(d);
        
        if abs(sumbest - totalsum) < minThres
            break;           
        elseif totalsum < sumbest
            index = idx;
            C = gCentroid(IDX,index,K,n,r,sumKi,Ki);
            sumbest = totalsum; 
            converge(i) = sumbest; 
            utility(i,:) = (UCompute(index,U,w,C,n,r,K,sumKi,Pvector))';  
        else
            warning('KCC:OptimizationException',...
                'The objective function value increases.');
            break;
        end 
    end
    
elseif (utilFlag==0 && missFlag==1) % If not calculating utility and there are missing values
    C = sCentroid_miss(IDX(randsample(n,K),:),K,r,Ki,sumKi);
    sumbest = inf;
    converge = zeros(100,1)-1;
    utility = []; 
            
    for i = 1:maxIter
        D = feval(distance,U,C,weight,n,r,K,sumKi,binIDX,missMatrix);
        [d, idx] = min(D, [], 2); 
        totalsum = sum(d); 
        
        if abs(sumbest - totalsum) < minThres 
            break;           
        elseif totalsum < sumbest 
            index = idx; 
            C = gCentroid_miss(IDX,index,K,n,r,sumKi,Ki); 
            sumbest = totalsum; 
            converge(i) = sumbest; 
        else 
            warning('KCC:OptimizationException',...
                'The objective function value increases.');
            break;
        end 
    end
    
else %  % If not calculating utility and there are no missing values
    C = sCentroid(IDX(randsample(n,K),:),K,r,sumKi); 
    sumbest = inf;
    converge = zeros(100,1)-1;
    utility = [];
            
    for i = 1:maxIter
        D = feval(distance,U,C,weight,n,r,K,sumKi,binIDX);
        [d, idx] = min(D, [], 2); 
        totalsum = sum(d); 
        
        if abs(sumbest - totalsum) < minThres 
            break;           
        elseif totalsum < sumbest 
            index = idx; 
            C = gCentroid(IDX,index,K,n,r,sumKi,Ki); 
            sumbest = totalsum; 
            converge(i) = sumbest; 
        else 
            warning('KCC:OptimizationException',...
                'The objective function value increases.');
            break;
        end 
    end
    
end

end
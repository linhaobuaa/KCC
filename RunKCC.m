function [pi_sumbest,pi_index,pi_converge,pi_utility,t] = ...
    RunKCC(IDX,K,U,w,rep,maxIter,minThres,utilFlag)
%==========================================================================
% FUNCTION: [pi_sumbest,pi_index,pi_converge,pi_utility,t] = ...
%    RunKCC(IDX,K,U,w,rep,maxIter,minThres,utilFlag)
% DESCRIPTION: This function performs consensus clustering in 10 times run
%              to obtain the best result
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
%           rep = number of times of KCC experiments to obtain the best
%                 result
%           maxIter = the maximum number of iterations for the convergence
%           minThres = the minimum reduced threshold of objective function
%           utilFlag = a flag indicating whether to calcualte utility
%                      function during the iterative computation, 1-calculate; 0-not
%                      calculate
%
% OUTPUT:   pi_sumbest = the optimal value of objective function (best objective function of 10 times run)
%           pi_index = the final clustering decision matrix for n data
%                      points (best objective function of 10 times run)
%           pi_converge = the iterative values of objective function (best objective function of 10 times run)
%           pi_utility = the final value of utility function (best objective function of 10 times run)
%           t = the calculation time cost of the whole process
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================
    tic; % record computation time in seconds
        
    [n,r] = size(IDX);
    
    if nargin>8 % check input arguments
        error('RunKCC:TooManyInputs',...
            'At most 8 input arguments: IDX,U,K,w,rep,maxIter,minThres,utilFlag.');
    elseif nargin<8
		utilFlag = 0;
    elseif nargin<7
        minThres = E-5;
    elseif nargin<6
        maxIter = 20;
    elseif nargin<5
        rep = 5;
    elseif nargin<4
        w = ones(r,1);
    elseif nargin<3
        U = {'u_h','std'};
    elseif nargin<2
        error('RunKCC:TooFewInputs',...
            'At least 2 input arguments required: IDX,K.');
    end
    
    [Ki,sumKi,binIDX,missFlag,missMatrix,distance,Pvector,weight] = ...
        Preprocess(IDX,U,n,r,w,utilFlag); % preprocess for accelerating computation

    l_sumbest = zeros(1,rep); % vector storing value of objective function in each KCC experiment
    l_index = zeros(n,rep); % vector storing clustering decision in each KCC experiment
    l_converge = zeros(100,rep); 
        
    if utilFlag==1 % if calculating utility
        l_utility = zeros(100,2*rep);
   
        for p = 1:rep
            [sumbest,index,converge,utility] = KCC(IDX,K,U,w,weight,...
                distance,maxIter,minThres,utilFlag,missFlag,missMatrix,...
                n,r,Ki,sumKi,binIDX,Pvector); 
            l_sumbest(p) = sumbest;
            l_index(:,p) = index;
            l_converge(:,p) = converge;
            l_utility(:,(2*p-1):(2*p)) = utility;
        end
        
        [pi_sumbest,pos] = min(l_sumbest);
        pi_index = l_index(:,pos);
        pi_converge = l_converge(:,pos);
        pi_utility = l_utility(:,(2*pos-1):(2*pos));
        
    elseif utilFlag==0 % if not calculating utility  
        for p = 1:rep
            [sumbest,index,converge] = KCC(IDX,K,U,w,weight,...
                distance,maxIter,minThres,utilFlag,missFlag,missMatrix,...
                n,r,Ki,sumKi,binIDX,Pvector);
            l_sumbest(p) = sumbest;
            l_index(:,p) = index;
            l_converge(:,p) = converge;
        end    
        [pi_sumbest,pos] = min(l_sumbest);
        pi_index = l_index(:,pos);
        pi_converge = l_converge(:,pos);
        pi_utility = [];
        
    else
        error('RunKCC:UnknowUtilityFlag',...
                'utilFlag must be 1 or 0.');
        
    end

    t = toc;
end

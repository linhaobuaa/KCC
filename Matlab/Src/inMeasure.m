function [Distortion, Silhouette] = inMeasure(IDX, cluster, U)
%==========================================================================
% FUNCTION: [Distortion, Silhouette] = inMeasure(IDX, cluster, U)
% DESCRIPTION: This function is used to internally assess and evaluate 
%              clustering quality, without access to the ground truth 
%              cluster labels.
%
% INPUTS:   IDX = the input basic partition matrix for KCC
%           cluster = the clustering decision matrix returned by KCC
%           U = parameters for utility function
%               Para1: U_c, U_cos
%               Para2: 'std'-standard
%               Para3: If U_Lp, can be used to set p
%
%
% OUTPUT:   Distortion = the distortion score, i.e., the sum of the L2 
%                        distance squared between the data objects and 
%                        the centroid of their assigned cluster.
%           Silhouette = the average silhouette coefficient value of all
%                        data objects
%
%==========================================================================
% copyright (c) 2022 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================
    Distortion = 0;

    if sum(any(IDX==0))>0  % if there is missing values in IDX matrix
        missFlag = 1; % indicates missing values
        missMatrix = IDX>0; % non-zero entries of IDX
    else %
        missFlag = 0;
        missMatrix = [];
    end

    if missFlag == 1
        error('inMeasure:Input IDX contains missing values',...
            'Currently only support complete basic partitions');
    elseif strcmpi(U{1,2},'std')~=1 
        error('inMeasure:Unsupported utility type',...
            'Currently only support standard utility function');
    else
        switch lower(U{1,1})
            case 'u_c'
                distance = 'sqEuclidean';
            case 'u_cos'
                distance = 'cosine';
            otherwise
                error('inMeasure:UnknowUtilityFunction',...
                    'Currently only support U_c,U_cos.');
        end
    end

   [Silhouette, h] = silhouette(IDX, cluster, distance);
   %disp(size(Silhouette));
   Silhouette = mean(Silhouette);
   %disp(Silhouette);

end

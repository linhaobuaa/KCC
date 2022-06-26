function [Distortion, Silhouette] = inMeasure(IDX, cluster, U)
%==========================================================================
% FUNCTION: [Distortion, Silhouette] = inMeasure(IDX, cluster, U)
% DESCRIPTION: This function is used to internally assess and evaluate 
%              clustering quality of a KCC solution, without access 
%              to the ground truth cluster labels.
%
% INPUTS:   IDX = the input basic partition matrix for KCC
%           cluster = the clustering decision matrix returned by KCC
%           U = parameters for utility function
%               Para1: U_c, U_cos
%               Para2: 'std'-standard
%               Para3: If U_Lp, can be used to set p
%
%
% OUTPUT:   Distortion = the distortion score, i.e., the sum of the
%                        distance squared between the data objects and 
%                        the centroid of their assigned cluster.
%           Silhouette = the average silhouette coefficient value of all
%                        data objects
%
%==========================================================================
% copyright (c) 2022 Hao Lin & Hongfu Liu & Junjie Wu
% Note: part of the implementation of elbow method is based on the following:
% Sebastien De Landtsheer (2022). kmeans_opt 
% (https://www.mathworks.com/matlabcentral/fileexchange/65823-kmeans_opt), 
% MATLAB Central File Exchange. 
%==========================================================================

    if sum(any(IDX==0))>0  % if there is missing values in IDX matrix
        missFlag = 1; % indicates missing values
        missMatrix = IDX>0; % non-zero entries of IDX
    else %
        missFlag = 0;
        missMatrix = [];
    end

    distance_sih = 'sqEuclidean'; % distance function used in silhouette calculation
    distance_dist = @distance_euc; % distance function used in distortion calculation
    if missFlag == 1
        error('inMeasure:Input IDX contains missing values',...
            'Currently only support complete basic partitions');
    elseif strcmpi(U{1,2},'std')~=1 
        error('inMeasure:Unsupported utility type',...
            'Currently only support standard utility function');
    else
        switch lower(U{1,1})
            case 'u_c'
                distance_sih = 'sqEuclidean';
                distance_dist = @distance_euc;
            case 'u_cos'
                distance_sih = 'cosine';
                distance_dist = @distance_cos;
            otherwise
                error('inMeasure:UnknowUtilityFunction',...
                    'Currently only support U_c,U_cos.');
        end
    end

    % call silhouette function from the Matlab Statistics and Machine Learning Toolbox
    S = silhouette(IDX, cluster, distance_sih); %disp(size(S)); % n * 1
    Silhouette = mean(S); %disp(Silhouette);

    [n,r]=size(IDX);
    K = length(unique(cluster));
    Ki = max(IDX); % vector storing the number of basic paritions for each basic clustering
    sumKi = zeros(r+1,1); % a 1-by-r+1 row vector, sumKi(i) refers to the starting index of the ith basic partition for each data point
    for i=1:r 
        sumKi(i+1) = sumKi(i)+Ki(i);
    end
    binIDX = IDX+repmat(sumKi(1:r)',n,1); % binIDX indicates the offset position of the ones values in the binary data matrix

    C = gCentroid(IDX,cluster,K,n,r,sumKi,Ki);
    D = feval(distance_dist,U,C,ones(r,1),n,r,K,sumKi,binIDX);
    % disp(size(D)); % n * k
    % disp(D);
    Distortion = zeros(n, 1);
    for j=1:n
        Distortion(j, 1)=D(j,cluster(j, 1));
    end;
    Distortion = sum(Distortion);
    % disp(Distortion);
end

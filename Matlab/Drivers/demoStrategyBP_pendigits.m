function demoStrategyBP
%==========================================================================
% FUNCTION: demoStratgyBP
% DESCRIPTION: A function to illustrate KCC experiments with RFS
% strategy for basic partition generation
%
% Note: For each dataset and each nFeature, the function saves one result matrix for 
% clustering evaluation. Each result matrix contains the average value of Rn.
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

clear;

% add lib path
addpath ../Src/

%----------identify all input arguments----------

%%%% for ecoli dataset %%%%%
% datafile = 'ecoli';
% subfix = '.dat';
% K = 6;
% nFeature_array = [2 3 4 5 6 7]; % the number of features selected, for BasicCluster_RFS only, nFeature=2,3,...,7 for ecoli

%%%% for dermatology dataset %%%%%
% datafile = 'dermatology';
% subfix = '.dat';
% K = 6;
% nFeature_array = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33];

%%%% for wine dataset %%%%%
% datafile = 'wine';
% subfix = '.dat';
% K = 3;
% nFeature_array = [2 3 4 5 6 7 8 9 10 11 12 13];

%%%% for pendigits dataset %%%%%
datafile = 'pendigits';
subfix = '.dat';
K = 10;
nFeature_array = [2:16];

%%%% parameters of basic partitions %%%%
r = 100; % number of basic partitions
w = ones(r, 1); % the weight of each partitions


%%%% distance measure for basic clustering using K-means,
if strcmp(datafile, 'mm')
    dist_of_basic_cluster = 'cosine'; % for text data set like mm, reviews, la12, sports
elseif strcmp(datafile, 'reviews')
    dist_of_basic_cluster = 'cosine';
elseif strcmp(datafile, 'la12')
    dist_of_basic_cluster = 'cosine';
elseif strcmp(datafile, 'sports')
    dist_of_basic_cluster = 'cosine';
else
    dist_of_basic_cluster = 'sqEuclidean';
end

%%%% the number of KCC runs %%%%
rep = 10; 

%%%% the maximum iteration for KCC convergence %%%%
maxIter = 40;

%%%% the minimum reduced threshold of objective function %%%%
minThres = 1e-5;

%%%% whether to calcualte utility function %%%%
%%%% 1-calculate; 0-not calculate %%%%
utilFlag = 1;

%%%% utility functions.
U = {'U_H','std',[]};

%----------loading data----------
if strcmp(subfix,'.dat')
    data = load(strcat('data/',strcat(datafile,'.dat')));
elseif strcmp(subfix,'.mat')
    [sp_mtx, n, m, count] = load_sparse(strcat('data/',strcat(datafile,'.mat')));
    data = sp_mtx;
else
    error('start1:UnknownInputDataType','Only .dat and .mat data is supported.');
end
true_label = load(strcat('data/',strcat(datafile,'_rclass.dat'))); % load the true label

output_foldername='ResultDemoStrategyBP/';
mkdir ResultDemoStrategyBP;

for nFeature = nFeature_array
    %----------using RFS for generating basic partitions----------
    IDX = BasicCluster_RFS(data,r,K,dist_of_basic_cluster,nFeature);

    %----------performing consensus function----------
    %%%% repeat KCC in 10 times run to obtain average performance %%%%
    avgRn = 0; % average Rn
    for num = 1 : 10
        [pi_sumbest,pi_index,pi_converge,pi_utility,t] = RunKCC(IDX,K,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering
        [Acc, Rn, NMI, VIn, VDn, labelnum, ncluster, cmatrix] = exMeasure(pi_index, true_label); % evaluating clustering quality
        avgRn = avgRn + Rn;
    end
    avgRn = avgRn / num;
    filename = strcat([output_foldername '/' datafile],strcat('_',lower(U{1,1})));
    filename = strcat(filename,strcat('_',lower(U{1,2})));
    if ~isempty(U{1,3})
        filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
    end
    filename = strcat(filename,strcat('_',num2str(nFeature)));
    filename = strcat(filename,'.mat');
    save(filename,'avgRn'); % save average performance to result matrix
end
end
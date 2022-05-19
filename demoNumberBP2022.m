function demoNumberBP
%==========================================================================
% FUNCTION: demoNumberBP
% DESCRIPTION: A function to illustrate KCC experiments with increasing
% number of basic partitions
%
% Note: For each dataset and each r, the function saves 100 result matrixs for 
% clustering evaluation. Each result matrix corresponds to one sample of basic 
% partitions and each result matrix contains the average value of Rn.
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

%----------identify all input arguments----------
%%%% for breast_w dataset %%%%%
datafile = 'breast_w';
subfix = '.dat';
K = 2;

%%%% for mm dataset %%%%%
% datafile = 'mm';
% subfix = '.mat';
% K = 2;

%%%% for reviews dataset %%%%%
% datafile = 'reviews';
% subfix = '.mat';
% K = 5;

%%%% parameters of basic partitionings %%%%
r_array = [10 20 30 40 50 60 70 80 90]; % number of basic partitions sampled from 1000 basic partitions, r=10, 20, 30,...,90
sampletimes = 100; % repeated sampling times

%%%% distance measure for basic clustering using K-means,
%%%% dist_of_basic_cluster = 'cosine' for text data set like mm, reviews, la12, sports
dist_of_basic_cluster = 'sqEuclidean';

%%%% Select randKi for bp generation, for BasicCluster_RPS only
%%%% 0: Ki=K, 1: Ki=random,Vector: Ki=randKi
randKi = 1;

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
U = {'U_h','std',[]};

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

%----------generating 1000 basic partitions----------
IDX = BasicCluster_RPS(data, 1000, K, dist_of_basic_cluster, randKi);

%----------for each r, repeated sampling 100 times from 1000 basic partitions and do KCC on each sample----------
for r = r_array
    w = ones(r, 1); % the weight of each partitions
    for sampletime = 1: sampletimes
        newIDX = IDX(:, randsample(1000, r)); % sample from 1000 basic partitions

        %%%% on each sample, repeat KCC in 10 times run to obtain average performance %%%%
        avgRn = 0; % average Rn
        for num = 1 : 10
            [pi_sumbest,pi_index,pi_converge,pi_utility,t] = RunKCC(newIDX,K,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering
            [Acc, Rn, NMI, VIn, VDn, labelnum, ncluster, cmatrix] = exMeasure(pi_index, true_label); % evaluating clustering quality
            avgRn = avgRn + Rn;
        end
        avgRn = avgRn / num;
        filename = strcat(datafile,strcat('_',lower(U{1,1})));
        filename = strcat(filename,strcat('_',lower(U{1,2})));
        if ~isempty(U{1,3})
            filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
        end
        filename = strcat(strcat(filename,'_'),num2str(r));
        filename = strcat(strcat(filename,'_'),num2str(sampletime));
        filename = strcat(filename,'.mat');
        save(filename,'avgRn'); % save average performance to result matrix
    end
end
end
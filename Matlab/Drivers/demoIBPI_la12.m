function demoIBPI
%==========================================================================
% FUNCTION: demoStratgyIBPI
% DESCRIPTION: A function to illustrate KCC experiments with 
% strategy-I for generating incomplete basic partitions
%
% Note: For each dataset and each missing rate rr, the function saves one result matrix for 
% clustering evaluation. Each result matrix contains the average value of Rn.
%
%==========================================================================
% copyright (c) 2021 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

clear;

% add lib path
addpath ../Src/

%----------identify all input arguments----------
%%%% for breast_w dataset %%%%%
% datafile = 'breast_w';
% subfix = '.dat';
% K = 2;

%%%% for dermatology dataset %%%%%
% datafile = 'dermatology';
% subfix = '.dat';
% K = 6;

%%%% for wine dataset %%%%%
% datafile = 'wine';
% subfix = '.dat';
% K = 3;

%%%% for la12 dataset %%%%%
datafile = 'la12';
subfix = '.mat';
K = 6;

%%%% parameters of basic partitionings %%%%
r = 100; % number of basic partitions
w = ones(r, 1); % the weight of each partitions
percent_array = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]; % percent of missing rate for incomplete basic partitions

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

output_foldername='ResultDemoIBPI/';
mkdir ResultDemoIBPI;

%----------using Strategy-I for generating incomplete basic partitions and do KCC----------
for percent = percent_array
    IDX = BasicCluster_RPS_missing(data,r,K,dist_of_basic_cluster,randKi,percent);
    
    %%%% For each missing rate, repeat KCC in 10 times run to obtain average performance %%%%
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
    filename = strcat(strcat(filename,'_'),num2str(percent));
    filename = strcat(filename,'.mat');
    save(filename,'avgRn'); % save average performance to result matrix
end
end
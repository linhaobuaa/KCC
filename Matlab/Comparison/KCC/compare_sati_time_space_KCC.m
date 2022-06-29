clear;

% add lib path
addpath ../Src/

%----------identify all input arguments----------

%%%% for iris dataset %%%%%
% datafile = 'iris';
% subfix = '.dat';
% K = 3; % number of clusters for consensus clustering

%%%% for breast_w dataset %%%%%
% datafile = 'breast_w';
% subfix = '.dat';
% K = 2;

%%%% for ecoli dataset %%%%%
% datafile = 'ecoli';
% subfix = '.dat';
% K = 6;

%%%% for pendigits dataset %%%%%
% datafile = 'pendigits';
% subfix = '.dat';
% K = 10;

%%%% for satimage dataset %%%%%
datafile = 'satimage';
subfix = '.dat';
K = 6;

%%%% for dermatology dataset %%%%%
% datafile = 'dermatology';
% subfix = '.dat';
% K = 6;

%%%% for wine dataset %%%%%
% datafile = 'wine';
% subfix = '.dat';
% K = 3;

%%%% for mm dataset %%%%%
% datafile = 'mm';
% subfix = '.mat';
% K = 2;

%%%% for reviews dataset %%%%%
% datafile = 'reviews';
% subfix = '.mat';
% K = 5;

%%%% for la12 dataset %%%%%
% datafile = 'la12';
% subfix = '.mat';
% K = 6;

%%%% for sports dataset %%%%%
% datafile = 'sports';
% subfix = '.mat';
% K = 7;

%%%% parameters of basic partitionings %%%%
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

%%%% Select randKi for bp generation, for BasicCluster_RPS only
%%%% 0: Ki=K, 1: Ki=random,Vector: Ki=randKi
randKi = 1;

%%%% the number of KCC runs %%%%
rep = 1; 

%%%% the maximum iteration for KCC convergence %%%%
maxIter = 40;

%%%% the minimum reduced threshold of objective function %%%%
minThres = 1e-5;

%%%% whether to calcualte utility function %%%%
%%%% 1-calculate; 0-not calculate %%%%
utilFlag = 1;

%%%% utility functions.
%%%% Para1: U_c, U_H, U_cos, U_Lp
%%%% Para2: 'std'-standard, 'norm'-normalized
%%%% Para3: If U_Lp, can be used to set p
U_array = {{'U_H','std',[]} {'U_H','norm',[]} {'U_c','std',[]} {'U_c','norm',[]} {'U_cos','std',[]} {'U_cos','norm',[]} {'U_lp','std',[5]} {'U_lp','norm',[5]} {'U_lp','std',[8]} {'U_lp','norm',[8]}};
%U_array = {{'U_c','std',[]} {'U_cos','std',[]}};

%----------performing consensus function----------
for uidx = 1:length(U_array)
    start=tic; % record started computation time in seconds
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

    %----------using RPS for generating basic partitions----------
    IDX = BasicCluster_RPS(data, r, K, dist_of_basic_cluster, randKi);

    U = U_array{1,uidx};
    
    [pi_sumbest,pi_index,pi_converge,pi_utility,t] = RunKCC(IDX,K,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering
    [Acc, Rn, NMI, VIn, VDn, labelnum, ncluster, cmatrix] = exMeasure(pi_index, true_label); % evaluating clustering quality
    
    t = toc(start);
    filename = strcat(datafile,strcat('_',lower(U{1,1})));
    filename = strcat(filename,strcat('_',lower(U{1,2})));
    if ~isempty(U{1,3})
        filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
    end
    filename = strcat(filename,'_time.mat');
    save(filename, 't'); % save to result matrix
end

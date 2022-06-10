%----------identify all input arguments----------

%%%% for iris dataset %%%%%
datafile = 'iris';
subfix = '.dat';
K = 3; % number of clusters for consensus clustering

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
% datafile = 'satimage';
% subfix = '.dat';
% K = 6;

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
%%%% dist_of_basic_cluster = 'cosine' for text data set like mm, reviews, la12, sports
dist_of_basic_cluster = 'sqEuclidean';

%%%% Select randKi for bp generation, for BasicCluster_RPS only
%%%% 0: Ki=K, 1: Ki=random,Vector: Ki=randKi
randKi = 1;

%----------loading data----------
if strcmp(subfix,'.dat')
    data = load(strcat('../data/',strcat(datafile,'.dat')));
elseif strcmp(subfix,'.mat')
    [sp_mtx, n, m, count] = load_sparse(strcat('../data/',strcat(datafile,'.mat')));
    data = sp_mtx;
else
    error('start1:UnknownInputDataType','Only .dat and .mat data is supported.');
end
true_label = load(strcat('../data/',strcat(datafile,'_rclass.dat'))); % load the true label

%----------using RPS for generating basic partitions----------
IDX = BasicCluster_RPS(data, r, K, dist_of_basic_cluster, randKi);

%----------performing consensus function----------
cls = transpose(IDX);

avgAcc = 0; % average Classification Accuracy
avgRn = 0; % average Rn
avgNMI = 0; % average NMI
avgVIn = 0; % average VIn
avgVDn = 0; % average VDn
%avgt = 0; % average execution time
for num = 1 : 10
    pi_index = clusterensemble(cls, K);
    [Acc, Rn, NMI, VIn, VDn, labelnum, ncluster, cmatrix] = exMeasure(pi_index, true_label); % evaluating clustering quality
    avgAcc = avgAcc + Acc;
    avgRn = avgRn + Rn;
    avgNMI = avgNMI + NMI;
    avgVIn = avgVIn + VIn;
    avgVDn = avgVDn + VDn;
    %avgt = avgt + t;
end
avgAcc = avgAcc / num;
avgRn = avgRn / num;
avgNMI = avgNMI / num;
avgVIn = avgVIn / num;
avgVDn = avgVDn / num;
%avgt = avgt / num;
filename = strcat('clusterensemble_',strcat(datafile, '_result.mat'));
save(filename,'avgAcc', 'avgVIn', 'avgVDn', 'avgRn', 'avgNMI'); % save average performance to result matrix


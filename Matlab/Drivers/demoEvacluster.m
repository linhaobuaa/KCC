function demoEvacluster
%==========================================================================
% FUNCTION: demoEvacluster
% DESCRIPTION: A function to illustrate how to evaluate clustering solutions
% when there are no ground truth label information in consensus function
%
%==========================================================================
% copyright (c) 2022 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

% add lib path
addpath ../Src/

%----------identify all input arguments----------

%%%% for iris dataset %%%%%
datafile = 'iris';
subfix = '.dat';
K = 3; % ground truth number of clusters for consensus clustering

%%%% for breast_w dataset %%%%%
% datafile = 'breast_w';
% subfix = '.dat';
% K = 2;

%%%% for ecoli dataset %%%%%
% datafile = 'ecoli';
% subfix = '.dat';
% K = 6;

%%%% parameters of basic partitionings %%%%
r = 100; % number of basic partitions
w = ones(r, 1); % the weight of each partitions

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
U = {'U_c','std',[]};

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

[pi_sumbest,pi_index,pi_converge,pi_utility,t] = RunKCC(IDX,K,U,w,rep,maxIter,minThres,utilFlag);
[Distortion, Silhouette] = inMeasure(IDX, pi_index, U);

%{
%----------performing consensus function----------
MaxK = ceil(sqrt(size(data, 1))); % max number of clusters to choose from
Cutoff = 0.95;
[bestK,distortions,pi_sumbest,pi_index,pi_converge,pi_utility] = KCCBestK(IDX,MaxK,Cutoff,U,w,rep,maxIter,minThres,utilFlag);


figure('visible','off');
plot(1:MaxK,distortions,'LineWidth',2,'b');
xlabel('Number of clusters in the consensus function');
xlim([1 MaxK])
ylabel('Disortion score');
hold on;
plot([bestK bestK],[0 distortions(bestK,1)],'LineWidth',2,'r');
text(bestK,distortions(bestK,1),['\leftarrow best K=' num2str(bestK)],'Color','red')
set(gca,'linewidth',2,'fontsize',14,'color','none');
grid on;
filename = strcat(datafile,strcat('_',lower(U{1,1})));
filename = strcat(filename,strcat('_',lower(U{1,2})));
if ~isempty(U{1,3})
    filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
end
filename1 = strcat(filename, '_evacluster_disortionscore.pdf');
saveas(gcf, filename1)
%}

end

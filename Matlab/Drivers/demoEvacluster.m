function demoEvacluster
%==========================================================================
% FUNCTION: demoEvacluster
% DESCRIPTION: A function to illustrate how to evaluate clustering solutions
% when there are no ground truth label information in consensus function, and
% how to select the best number of clusters for the consensus function.
%
%==========================================================================
% copyright (c) 2022 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

clear;

% add lib path
addpath ../Src/

%----------identify all input arguments----------

%%%% for iris dataset %%%%%
datafile = 'iris';
subfix = '.dat';
K_BP = 3; % parameter denoting the number of clusters for basic partitions

%%%% for breast_w dataset %%%%%
% datafile = 'breast_w';
% subfix = '.dat';
% K_BP = 2;

%%%% for ecoli dataset %%%%%
% datafile = 'ecoli';
% subfix = '.dat';
% K_BP = 6;

%%%% parameters of basic partitionings %%%%
r = 100; % number of basic partitions
w = ones(r, 1); % the weight of each partitions

%%%% distance measure for basic clustering using K-means,
%%%% dist_of_basic_cluster = 'cosine' for text data set like mm, reviews, la12, sports
dist_of_basic_cluster = 'sqEuclidean';

%%%% Select randKi for bp generation, for BasicCluster_RPS only
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

%%%% cutoff parameter for elbow method
Cutoff = 0.95;

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
IDX = BasicCluster_RPS(data, r, K_BP, dist_of_basic_cluster, randKi);

%----------performing consensus function over different K----------
set(groot, 'DefaultFigureVisible', 'off')
MaxK = ceil(sqrt(size(data, 1))); % max number of clusters to choose from
distortions=zeros(MaxK, 1); % vectors storing the Distortion value for each K
silhouettes=zeros(MaxK, 1); % vectors storing the Silhouette value for each K
executiontimes=zeros(MaxK, 1); % vectors storing the execution time of running KCC
for K=1:MaxK % for each K
    tic; % record started computation time in seconds
    [pi_sumbest,pi_index,pi_converge,pi_utility,t] = RunKCC(IDX,K,U,w,rep,maxIter,minThres,utilFlag);
    t = toc;
    [Distortion, Silhouette] = inMeasure(IDX, pi_index, U);
    distortions(K,1) = Distortion;
    silhouettes(K,1) = Silhouette;
    executiontimes(K,1)=t;
end

%----------performing elbow method on the Distortion values to find best K---------- 
variance = distortions(1:end-1)-distortions(2:end); % calculate variance
PC = cumsum(variance)/(distortions(1)-distortions(end));
[kindex,~]=find(PC>Cutoff); % find the best index
bestK_elbow=1+kindex(1,1); % get the optimal number of clusters

%----------visualization of distortions with different K (Elbow Line)---------- 
figure('visible','off');
plot(1:MaxK,distortions,'b','LineWidth',2);
xlabel('Number of clusters in the consensus function');
xlim([1 MaxK])
ylabel('Distortion score');
hold on;
plot([bestK_elbow bestK_elbow],[0 distortions(bestK_elbow,1)],'r','LineWidth',2);
text(bestK_elbow,distortions(bestK_elbow,1),['\leftarrow best K=' num2str(bestK_elbow)],'Color','red')
set(gca,'linewidth',2,'fontsize',14,'color','none');
grid on;
set(gca,'GridLineStyle',':');
filename = strcat(datafile,strcat('_',lower(U{1,1})));
filename = strcat(filename,strcat('_',lower(U{1,2})));
if ~isempty(U{1,3})
    filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
end
filename1 = strcat(filename, '_evacluster_distortionscore.pdf');
saveas(gcf, filename1)

%----------Choose the K with the maximum silhouette coefficient as the best parameter-------------
[best_silhouette, kindex] = max(silhouettes);
%disp(kindex);
bestK_silhouette = kindex;

%----------visualization of silhouette coefficient with different K---------- 
figure('visible','off');
plot(1:MaxK,silhouettes,'b','LineWidth',2);
xlabel('Number of clusters in the consensus function');
xlim([1 MaxK])
ylabel('Silhouette coefficient');
hold on;
plot([bestK_silhouette bestK_silhouette],[0 silhouettes(bestK_silhouette,1)],'r','LineWidth',2);
text(bestK_silhouette,silhouettes(bestK_silhouette,1),['\leftarrow best K=' num2str(bestK_silhouette)],'Color','red')
set(gca,'linewidth',2,'fontsize',14,'color','none');
grid on;
set(gca,'GridLineStyle',':');
filename = strcat(datafile,strcat('_',lower(U{1,1})));
filename = strcat(filename,strcat('_',lower(U{1,2})));
if ~isempty(U{1,3})
    filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
end
filename2 = strcat(filename, '_evacluster_silhouettecoefficient.pdf');
saveas(gcf, filename2)

%----------visualization of running time with different K----------
figure('visible','off');
plot(1:MaxK,executiontimes,'b','LineWidth',2);
xlabel('Number of clusters in the consensus function');
xlim([1 MaxK])
ylabel('KCC Execution time (in seconds)');
set(gca,'linewidth',2,'fontsize',14,'color','none');
grid on;
set(gca,'GridLineStyle',':');
filename = strcat(datafile,strcat('_',lower(U{1,1})));
filename = strcat(filename,strcat('_',lower(U{1,2})));
if ~isempty(U{1,3})
    filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
end
filename3 = strcat(filename, '_evacluster_executiontime.pdf');
saveas(gcf, filename3)

end

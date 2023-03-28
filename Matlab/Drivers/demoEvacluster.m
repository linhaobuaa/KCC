function demoEvacluster
%==========================================================================
% FUNCTION: demoEvacluster
% DESCRIPTION: A function to illustrate how to evaluate clustering solutions
% when there are no ground truth label information in consensus function, and
% how to select the best number of clusters for the consensus function.
%
% Note: part of the implementation of elbow method is based on the following:
% Dmitry Kaplan (2023). Knee Point (https://www.mathworks.com/matlabcentral/
% fileexchange/35094-knee-point), MATLAB Central File Exchange
%==========================================================================
% copyright (c) 2022 Hao Lin & Hongfu Liu & Junjie Wu
%==========================================================================

clear;

% add lib path
addpath ../Src/

%----------identify all input arguments----------

%%%% for iris dataset %%%%%
% datafile = 'iris';
% subfix = '.dat';
% K_BP = 3; % parameter denoting the number of clusters for basic partitions

%%%% for breast_w dataset %%%%%
% datafile = 'breast_w';
% subfix = '.dat';
% K_BP = 2;

%%%% for ecoli dataset %%%%%
% datafile = 'ecoli';
% subfix = '.dat';
% K_BP = 6;

%%%% for pendigits dataset %%%%%
% datafile = 'pendigits';
% subfix = '.dat';
% K_BP = 10;

%%%% for satimage dataset %%%%%
% datafile = 'satimage';
% subfix = '.dat';
% K_BP = 6;

%%%% for dermatology dataset %%%%%
% datafile = 'dermatology';
% subfix = '.dat';
% K_BP = 6;

%%%% for wine dataset %%%%%
% datafile = 'wine';
% subfix = '.dat';
% K_BP = 3;

%%%% for mm dataset %%%%%
datafile = 'mm';
subfix = '.mat';
K_BP = 2;

%%%% parameters of basic partitionings %%%%
r = 100; % number of basic partitions
w = ones(r, 1); % the weight of each partitions

%%%% distance measure for basic clustering using K-means,
if strcmp(subfix,'.dat')
    dist_of_basic_cluster = 'sqEuclidean';
elseif strcmp(subfix,'.mat')
    dist_of_basic_cluster = 'cosine'; % for text data set like mm, reviews, la12, sports
else
    error('start1:UnknownInputDataType','Only .dat and .mat data is supported.');

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
Cutoff = 0.8;

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

output_foldername='ResultDemoEvacluster/';
mkdir ResultDemoEvacluster;

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
    [Distortion, Silhouette] = inMeasure(data, pi_index, K);
    distortions(K,1) = Distortion;
    silhouettes(K,1) = Silhouette;
    executiontimes(K,1)=t;
end

%----------performing elbow method on the Distortion values to find best K---------- 
[res_x, idx_of_result] = knee_pt(distortions,1:MaxK);
%disp(res_x);
%disp(idx_of_result);
bestK_elbow = res_x;

%----------visualization of distortions with different K (Elbow Line)---------- 
figure('visible','off');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0.25 2.5 8.0 6.0]);
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
filename = strcat([output_foldername '/' datafile],strcat('_',lower(U{1,1})));
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
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0.25 2.5 8.0 6.0]);
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
filename = strcat([output_foldername '/' datafile],strcat('_',lower(U{1,1})));
filename = strcat(filename,strcat('_',lower(U{1,2})));
if ~isempty(U{1,3})
    filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
end
filename2 = strcat(filename, '_evacluster_silhouettecoefficient.pdf');
saveas(gcf, filename2)

%----------visualization of running time with different K----------
figure('visible','off');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0.25 2.5 8.0 6.0]);
plot(1:MaxK,executiontimes,'b','LineWidth',2);
xlabel('Number of clusters in the consensus function');
xlim([1 MaxK])
ylabel('Execution time (in seconds)');
set(gca,'linewidth',2,'fontsize',14,'color','none');
grid on;
set(gca,'GridLineStyle',':');
filename = strcat([output_foldername '/' datafile],strcat('_',lower(U{1,1})));
filename = strcat(filename,strcat('_',lower(U{1,2})));
if ~isempty(U{1,3})
    filename = strcat(filename,strcat('_',num2str(lower(U{1,3}))));
end
filename3 = strcat(filename, '_evacluster_executiontime.pdf');
saveas(gcf, filename3)

end

function eva_clue

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
datafile = 'la12';
subfix = '.mat';
K = 6;

%%%% for sports dataset %%%%%
% datafile = 'sports';
% subfix = '.mat';
% K = 7;

%----------loading data----------
true_label = load(strcat('../data/',strcat(datafile,'_rclass.dat'))); % load the true label

num_experiments = 10;
Accarray = zeros(num_experiments, 1);
Rnarray = zeros(num_experiments, 1);
NMIarray = zeros(num_experiments, 1);
VInarray = zeros(num_experiments, 1);
VDnarray = zeros(num_experiments, 1);
for i = 1:num_experiments
    pi_index = getfield(load(strcat(strcat(strcat(strcat('clue_',datafile),'_consensusresult_'),num2str(i)),'.mat')), 'consensus');
    [Acc, Rn, NMI, VIn, VDn, labelnum, ncluster, cmatrix] = exMeasure(pi_index, true_label); % evaluating clustering quality
    Accarray(i, 1) = Acc;
    Rnarray(i, 1) = Rn;
    NMIarray(i, 1) = NMI;
    VInarray(i, 1) = VIn;
    VDnarray(i, 1) = VDn;
end
avgAcc = mean(Accarray);
avgRn = mean(Rnarray);
avgNMI = mean(NMIarray);
avgVIn = mean(VInarray);
avgVDn = mean(VDnarray);
stdAcc = std(Accarray);
stdRn = std(Rnarray);
stdNMI = std(NMIarray);
stdVIn = std(VInarray);
stdVDn = std(VDnarray);
filename = strcat(strcat('clue_',datafile),'_metrics.mat');
save(filename, 'avgAcc', 'avgVIn', 'avgVDn', 'avgRn', 'avgNMI', 'stdAcc', 'stdVIn', 'stdVDn', 'stdRn', 'stdNMI');
end

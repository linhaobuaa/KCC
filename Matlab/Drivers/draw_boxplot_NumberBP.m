
% read all .mat files in the results folder
Files = dir(fullfile('ResultDemoNumberBP/*.mat'));

LengthFiles = length(Files); % the number of all files
% disp(LengthFiles);

Rn_breast_w=zeros(100,9);
% disp(size(Rn_breast_w));
Rn_mm=zeros(100,9);
Rn_reviews=zeros(100,9);
for i=1:LengthFiles
    name=Files(i).name;
    % disp(name);
    s=strsplit(name,'_');
    % disp(s);
    datafile=char(s(1,1));
    % disp(datafile);
    percent=char(s(1,end-1));
    % disp(percent);
    percent_idx = str2num(percent) / 10;
    % disp(percent_idx);
    runs=strrep(char(s(1,end)),'.mat','');
    % disp(runs);
    runs_idx = str2num(runs);
    % disp(runs_idx);
    folder=Files(i).folder;
    % disp(folder);
    load([folder,'/',name]);
    % disp(class(datafile));
    if strcmp(datafile,'breast')
        Rn_breast_w(runs_idx,percent_idx)=avgRn;
    elseif strcmp(datafile,'mm')
        Rn_mm(runs_idx,percent_idx)=avgRn;
    elseif strcmp(datafile,'reviews')
        Rn_reviews(runs_idx,percent_idx)=avgRn;
    end
    % break;
end
% disp(Rn_breast_w);
% disp(Rn_mm);
% disp(Rn_reviews);

p1=Rn_breast_w;
%disp(p1);
p2=Rn_mm;
p3=Rn_reviews;

h1=figure('visible','off');
boxplot(p1); % 'widths',0.25
xlabel('#BPs');
ylabel('R_n');
xlim([0.5 9.5]);
xticks(1:9);
xticklabels([10:10:90]);
ylim([0 1.0]);
yticksvalues=[0, 2, 4, 6, 8, 10];
yticks(yticksvalues/10);
yticklabels([0:0.2:1.0]);
%set(gca,'Fontname','times new Roman','FontWeight','bold');
set(gca,'linewidth',2,'fontsize',14,'color','none');
format compact;
saveas(h1,'bp_breast_w.eps','epsc'); 

h2=figure('visible','off');
boxplot(p2); % ,'widths',0.25
xlabel('#BPs');
ylabel('R_n');
xlim([0.5 9.5]);
xticks(1:9);
xticklabels([10:10:90]);
ylim([0 1.0]);
yticksvalues=[0, 2, 4, 6, 8, 10];
yticks(yticksvalues/10);
yticklabels([0:0.2:1.0]);
%set(gca,'Fontname','times new Roman','FontWeight','bold');
set(gca,'linewidth',2,'fontsize',14,'color','none');
format compact;
saveas(h2,'bp_mm.eps','epsc'); 

h3=figure('visible','off');
boxplot(p3); % ,'widths',0.25
xlabel('#BPs');
ylabel('R_n');
xlim([0.5 9.5]);
xticks(1:9);
xticklabels([10:10:90]);
ylim([0 1.0]);
yticksvalues=[0, 2, 4, 6, 8, 10];
yticks(yticksvalues/10);
yticklabels([0:0.2:1.0]);
%set(gca,'Fontname','times new Roman','FontWeight','bold');
set(gca,'linewidth',2,'fontsize',14,'color','none');
format compact;
saveas(h3,'bp_reviews.eps','epsc');

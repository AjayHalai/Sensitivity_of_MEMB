%% multi-echo multi-band project 
%Halai, A; Henson, R; Correia, M

clear all

root = ['/imaging/projects/cbu/mr21005_memb/derivatives/'];
cd([root]);
folders = dir('./fmriprep/sub*');% not sure about using this yet
n=0;
for i=1:length(folders);
    if folders(i).isdir
        n=n+1;
        tmp{n}=folders(i,1).name;
    end
end
subcode = tmp;

%% rearrange behavioural data
%generated from eprime outputs and converted to .mat marticies
load('./behaviour/behaviour.mat');

for s=1:length(accuracy)
    %counterbalance across two parts eprime run and protocol order
    tmp=runorder(s,:);%sort by eprime run first
    x=accuracy{s}(:,tmp);
    tmp=scantype(s,:);
    %collate acc
    accuracy_reordered{s,:}=abs(x(:,tmp)-1); %sort by protocol and convert accuracy to 1
    
    %collate rt
    tmp=runorder(s,:);%sort by eprime run first
    x=rt{s}(:,tmp);
    tmp=scantype(s,:);
    xx=x(:,tmp);
    
    tmp=xx.*accuracy_reordered{s,:};%only keep correct trials
    tmp(tmp==0)=NaN;%convert wrong trials to nan
    rt_reordered{s,:}=tmp;
    
    %remove any implausible trials (i.e., rt<500ms)
    for j=1:4;
        tmp=rt_reordered{s,:}(:,j);
        x=find(tmp<500)
        tmp(x)=NaN;
        rt_reordered{s,:}(:,j)=tmp;
        tmp=accuracy_reordered{s,:}(:,j);
        tmp(x)=0;
        %find all NaNs in rt and change acc to failed
        [ind,val]=find(isnan(rt_reordered{s,:}(:,j)));
        tmp(ind)=0;       
        accuracy_reordered{s,:}(:,j)=tmp;
        
    end
    
    %convert to overall mean % correct and mean rt
    summary_acc(s,:)=sum(accuracy_reordered{s})./length(accuracy_reordered{s})*100;
    summary_rt(s,:)=nanmean(rt_reordered{s});
    
    %split by condition
    for i=1:2;
        tmp=cond(:,s);
        [ind, val]=find(tmp==i);
        tmp=accuracy_reordered{s}(ind,:);
        summary_acc_cond{i}(s,:)=sum(tmp)./length(tmp)*100;
        tmp=rt_reordered{s}(ind,:);
        summary_rt_cond{i}(s,:)=nanmean(tmp);
    end
       
end

%% identify outliers
%overall outliers
[TF,L,U,C] = isoutlier(mean(summary_acc,2));
%any case with less than 60% roughly cut off for binomial distribution for chance performance
tmp=sum(summary_acc<=60,2);
outlier=[TF+tmp];

%scrub outlier data
remove=find(outlier);
summary_acc(remove,:)=NaN;
summary_acc_cond{1}(remove,:)=NaN;
summary_acc_cond{2}(remove,:)=NaN;
summary_rt(remove,:)=NaN;
summary_rt_cond{1}(remove,:)=NaN;
summary_rt_cond{2}(remove,:)=NaN;

fprintf('Outlier detected: remove EPRIME ID %6.0f \n',remove);

%% repeated measures anova
%accuracy
t = table(summary_acc(:,1),summary_acc(:,2),summary_acc(:,3),summary_acc(:,4),...
'VariableNames',{'t1','t2','t3','t4'});
Meas = table([1 2 3 4]','VariableNames',{'Measurements'});
rm = fitrm(t,'t1-t4~1', 'WithinDesign',Meas);
accuracy_rmtbl=ranova(rm)

%acc by task
t = table(summary_acc_cond{1}(:,1),summary_acc_cond{1}(:,2),summary_acc_cond{1}(:,3),summary_acc_cond{1}(:,4),...
    summary_acc_cond{2}(:,1),summary_acc_cond{2}(:,2),summary_acc_cond{2}(:,3),summary_acc_cond{2}(:,4),...
    'VariableNames', {'S1', 'S2', 'S3', 'S4', 'C1', 'C2', 'C3', 'C4'});
w = table(categorical([1 1 1 1 2 2 2 2].'), categorical([1 2 3 4 1 2 3 4].'), 'VariableNames', {'Task', 'Protocol'}); % within-design
rm = fitrm(t, 'C4-S1 ~ 1', 'WithinDesign', w);
accuracy_cond_rmtbl=ranova(rm, 'withinmodel', 'Task*Protocol')

%rt
t = table(summary_rt(:,1),summary_rt(:,2),summary_rt(:,3),summary_rt(:,4),...
'VariableNames',{'t1','t2','t3','t4'});
Meas = table([1 2 3 4]','VariableNames',{'Measurements'});
rm = fitrm(t,'t1-t4~1', 'WithinDesign',Meas);
rt_rmtbl=ranova(rm)

%rt by task
t = table(summary_rt_cond{1}(:,1),summary_rt_cond{1}(:,2),summary_rt_cond{1}(:,3),summary_rt_cond{1}(:,4),...
    summary_rt_cond{2}(:,1),summary_rt_cond{2}(:,2),summary_rt_cond{2}(:,3),summary_rt_cond{2}(:,4),...
    'VariableNames', {'S1', 'S2', 'S3', 'S4', 'C1', 'C2', 'C3', 'C4'});
w = table(categorical([1 1 1 1 2 2 2 2].'), categorical([1 2 3 4 1 2 3 4].'), 'VariableNames', {'Task', 'Protocol'}); % within-design
rm = fitrm(t, 'C4-S1 ~ 1', 'WithinDesign', w);
rt_cond_rmtbl=ranova(rm, 'withinmodel', 'Task*Protocol')

%% plot figure
addpath('/group/mlr-lab/AH/Projects/toolboxes/Violinplot/');

a = table(summary_acc(:,1),summary_acc(:,2),summary_acc(:,3),summary_acc(:,4),...
    'VariableNames', {'SESB', 'SEMB', 'MESB', 'MEMB'});
aa = table(summary_rt(:,1),summary_rt(:,2),summary_rt(:,3),summary_rt(:,4),...
    'VariableNames', {'SESB', 'SEMB', 'MESB', 'MEMB'});
figure;subplot(2,1,1);violinplot(a);title('Task Acc');ylim([50 100]);xlim([0 5]);ylabel('Percentage')
subplot(2,1,2);violinplot(aa);title('Task RT');ylim([1000 3000]);xlim([0 5]);ylabel('Time (ms)')

a = table(summary_acc_cond{1}(:,1),summary_acc_cond{1}(:,2),summary_acc_cond{1}(:,3),summary_acc_cond{1}(:,4),...
    'VariableNames', {'SESB', 'SEMB', 'MESB', 'MEMB'});
aa = table(summary_acc_cond{2}(:,1),summary_acc_cond{2}(:,2),summary_acc_cond{2}(:,3),summary_acc_cond{2}(:,4),...
    'VariableNames', {'SESB', 'SEMB', 'MESB', 'MEMB'});
t = table(summary_rt_cond{1}(:,1),summary_rt_cond{1}(:,2),summary_rt_cond{1}(:,3),summary_rt_cond{1}(:,4),...
    'VariableNames', {'SESB', 'SEMB', 'MESB', 'MEMB'});
tt = table(summary_rt_cond{2}(:,1),summary_rt_cond{2}(:,2),summary_rt_cond{2}(:,3),summary_rt_cond{2}(:,4),...
    'VariableNames', {'SESB', 'SEMB', 'MESB', 'MEMB'});
figure;subplot(2,2,1);violinplot(a);title('Semantic Task Acc');ylim([50 100]);xlim([0 5]);ylabel('Percentage')
subplot(2,2,2);violinplot(aa);title('Control Task Acc');ylim([50 100]);xlim([0 5]);ylabel('Percentage')
subplot(2,2,3);violinplot(t);title('Semantic Task RT');ylim([1000 3000]);xlim([0 5]);ylabel('Time (ms)')
subplot(2,2,4);violinplot(tt);title('Control Task RT');ylim([1000 3000]);xlim([0 5]);ylabel('Time (ms)')

%% save outputs
save ./behaviour/behaviour_out.mat


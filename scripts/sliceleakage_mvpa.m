clear all
addpath('/group/mlr-lab/AH/Projects/spm12/');
addpath('/group/mlr-lab/AH/Projects/toolboxes/');
addpath('/imaging/projects/cbu/mr21005_memb/scripts/');

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

load('./behaviour/behaviour_out.mat','remove'); %load remove variable from previous analysis showing which cases had poor behavioural responses
goodsubj=subcode;
goodsubj([1;remove])=[];


%% MVPA analysis 
%%%%%%%%%%
cond={'SESB';'SEMB';'MESB';'MEMB'};
% Henson script
%beta images
imgs = cell(1,1);
con_mvpa = struct();

for s=1:length(goodsubj)
    
ROI = struct();
%note artefact ROIs were obtained first by warping MNI vATL peak to EPI space, calculating the artefact locations, then warping back to MNI and creating 8mm sphere around point in MNI space 
ROI.ROIfiles{1}=[root,'../work/ROIs/HumphreysPNAS2015/PNAS_semantic_sphere_8--42_-24_-27.nii'];% vATL seed Humphreys et al., 2015
ROI.ROIfiles{2}=[root,'../mc04/',goodsubj{s},'/',goodsubj{s},'_MEMB_MNI_Ag.nii'];%grappa artefact on seed
ROI.ROIfiles{3}=[root,'../mc04/',goodsubj{s},'/',goodsubj{s},'_MEMB_MNI_B.nii'];% MB artefact
ROI.ROIfiles{4}=[root,'../mc04/',goodsubj{s},'/',goodsubj{s},'_MEMB_MNI_Bg.nii'];% grappa artefact on MB artefact
ROI.ROIfiles{5}=[root,'../work/ROIs/HumphreysPNAS2015/PNAS_semantic_sphere_8--42_-24_-27.nii'];% vATL seed Humphreys et al., 2015
ROI.ROIfiles{6}=[root,'../mc04/',goodsubj{s},'/',goodsubj{s},'_SEMB_MNI_B.nii'];% MB artefact

%cycle through conditions - each time set up seperate field structure for
%inputs and roi_extract outputs
    for c=1:length(cond)
        clear imgs
        imgs{1}{1} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0001.nii'];
        imgs{1}{2} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0002.nii'];
        imgs{1}{3} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0003.nii'];
        imgs{1}{4} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0004.nii'];
        imgs{1}{5} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0005.nii'];
        imgs{1}{6} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0006.nii'];
        imgs{1}{7} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0007.nii'];
        imgs{1}{8} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0008.nii'];
        imgs{1}{9} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0009.nii'];
        imgs{1}{10} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0010.nii'];
        imgs{1}{11} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0011.nii'];
        imgs{1}{12} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0012.nii'];
        imgs{1}{13} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0013.nii'];
        imgs{1}{14} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0014.nii'];
        imgs{1}{15} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0015.nii'];
        imgs{1}{16} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0016.nii'];
        imgs{1}{17} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0017.nii'];
        imgs{1}{18} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0018.nii'];
        imgs{1}{19} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0019.nii'];
        imgs{1}{20} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0020.nii'];
        imgs{1}{21} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0021.nii'];
        imgs{1}{22} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0022.nii'];
        imgs{1}{23} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0023.nii'];
        imgs{1}{24} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0024.nii'];
        field = strcat(cond{c});
        con_mvpa.(field).Datafiles = imgs;
        %con_mvpa.(field).mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];
        con_mvpa.(field).output_raw = 1;
        con_mvpa.(field).ROIfiles=ROI.ROIfiles;
        con_mvpa.(field).ROI = roi_extract(con_mvpa.(field));
    end
 
collated{s}=con_mvpa;
end

%MVPA analyses
%remove NaN voxels from roi_extract matrix for every cell
for s=1:length(goodsubj)
    for c=1:length(cond)
        for n=1:length(ROI.ROIfiles)
            field = strcat(cond{c});
            x=isnan(collated{s}.(field).ROI(n).rawdata(1,:));
            ind=find(x);
            collated{s}.(field).ROI(n).rawdata(:,ind)=[];
            collated{s}.(field).ROI(n).XYZ(:,ind)=[];
        end
    end
end

%calculate pdist (default) between betas 
for s=1:length(goodsubj)
    for c=1:length(cond)
        for n=1:length(ROI.ROIfiles)
            field = strcat(cond{c});
            x=collated{s}.(field).ROI(n).rawdata;
            
            %calculate matrix distance, convert to matrix and take upper triangle
            collated{s}.(field).ROI(n).dissimilarity=triu(squareform(pdist(x,'cosine'))); %euclidean, cosine
            %convert zeros in matrix to NaN
            collated{s}.(field).ROI(n).dissimilarity(collated{s}.(field).ROI(n).dissimilarity==0)=nan;
            %median
            collated{s}.(field).ROI(n).mvpa_within_median=nanmedian([reshape(collated{s}.(field).ROI(n).dissimilarity([1:12],[1:12]),[],1);reshape(collated{s}.(field).ROI(n).dissimilarity([13:24],[13:24]),[],1)]);
            collated{s}.(field).ROI(n).mvpa_between_median=nanmedian(reshape(collated{s}.(field).ROI(n).dissimilarity([1:12],[13:24]),[],1));
            collated{s}.(field).ROI(n).mvpa_comparison_median=[collated{s}.(field).ROI(n).mvpa_within_median-collated{s}.(field).ROI(n).mvpa_between_median];
            %mean
            collated{s}.(field).ROI(n).mvpa_within_mean=nanmean([reshape(collated{s}.(field).ROI(n).dissimilarity([1:12],[1:12]),[],1);reshape(collated{s}.(field).ROI(n).dissimilarity([13:24],[13:24]),[],1)]);
            collated{s}.(field).ROI(n).mvpa_between_mean=nanmean(reshape(collated{s}.(field).ROI(n).dissimilarity([1:12],[13:24]),[],1));
            collated{s}.(field).ROI(n).mvpa_comparison_mean=[collated{s}.(field).ROI(n).mvpa_within_mean-collated{s}.(field).ROI(n).mvpa_between_mean];
          
        end
    end
end

% stepsize=[27,54,108,200,248];
% for aa=1:5
% for a=1:1000
%     ids=randperm(249);
%     r=con_mvpa.SESB.ROI(2, 1).rawdata(:,ids(1:stepsize(aa)));
%     rr=triu(squareform(pdist(r,'cosine')));
%     rr(rr==0)=nan;
%     c.within=nanmedian([reshape(rr([1:12],[1:12]),[],1);reshape(rr([13:24],[13:24]),[],1)]);
%     c.between=nanmedian(reshape(rr([1:12],[13:24]),[],1));
%     c.comparison=c.within-c.between;
%     cc(aa,a)=c.comparison;
% end
% end
% figure;
% for a=1:5;
%     subplot(1,5,a);hist(cc(a,:));
% end


%collate mvpa within minus between results into matrix 
for s=1:length(goodsubj)
    for c=1:length(cond)
        for n=1:length(ROI.ROIfiles)
            field = strcat(cond{c});
            con_mvpa_collate_median{n}(s,c)=collated{s}.(field).ROI(n).mvpa_comparison_median;
            con_mvpa_collate_mean{n}(s,c)=collated{s}.(field).ROI(n).mvpa_comparison_mean;
        end
    end
end

%preselect specific data columns 

MEMB_A=con_mvpa_collate_mean{1}(:,4);
MESB_A=con_mvpa_collate_mean{1}(:,3);
MEMB_Ag=con_mvpa_collate_mean{2}(:,4);
MESB_Ag=con_mvpa_collate_mean{2}(:,3);
MEMB_B=con_mvpa_collate_mean{3}(:,4);
MESB_B=con_mvpa_collate_mean{3}(:,3);
MEMB_Bg=con_mvpa_collate_mean{4}(:,4);
MESB_Bg=con_mvpa_collate_mean{4}(:,3);

ME_results=table(MEMB_A,MESB_A,MEMB_Ag,MESB_Ag,MEMB_B,MESB_B,MEMB_Bg,MESB_Bg);

SESB_A=con_mvpa_collate_mean{5}(:,1);
SEMB_A=con_mvpa_collate_mean{5}(:,2);
SESB_B=con_mvpa_collate_mean{6}(:,1);
SEMB_B=con_mvpa_collate_mean{6}(:,2);

SE_results=table(SESB_A,SEMB_A,SESB_B,SEMB_B);

%copy stats that Marta C did for univarate
[H,P,CI,STATS]=ttest(SESB_A,SEMB_A);pval(1,:)=P;tval(1,:)=STATS.tstat;
[H,P,CI,STATS]=ttest(SESB_B,SEMB_B);pval(2,:)=P;tval(2,:)=STATS.tstat;
[H,P,CI,STATS]=ttest(MEMB_A,MESB_A);pval(3,:)=P;tval(3,:)=STATS.tstat;
[H,P,CI,STATS]=ttest(MEMB_Ag,MESB_Ag);pval(4,:)=P;tval(4,:)=STATS.tstat;
[H,P,CI,STATS]=ttest(MEMB_B,MESB_B);pval(5,:)=P;tval(5,:)=STATS.tstat;
[H,P,CI,STATS]=ttest(MEMB_Bg,MESB_Bg);pval(6,:)=P;tval(6,:)=STATS.tstat;


figure;boxplot(table2array(ME_results));
figure;boxplot(table2array(SE_results));
figure;scatter(ones(16,1),table2array(ME_results(:,1)));
hold on
for i=2:size(ME_results,2);
    scatter(ones(16,1)*i,table2array(ME_results(:,i)));
end
  

save mvpa_sliceleakage SE_results ME_results collated con_mvpa* pval tval

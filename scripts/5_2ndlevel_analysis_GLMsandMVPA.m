clear all
addpath('/group/mlr-lab/AH/Projects/spm12/');
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

%% run group analysis for 'good subjects' based on objective cut offs

%% load variables and ROIs
%removed based on behaviour.m
load('./behaviour/behaviour_out.mat','remove'); %load remove variable from previous analysis showing which cases had poor behavioural responses
goodsubj=subcode;
goodsubj([1;remove])=[]; %remove the cases based on poor performance and subj 1 for poor FOV

%set up ROI structure
ROI = struct();
ROI.ROIfiles{1}=[root,'../work/ROIs/HumphreysPNAS2015/PNAS_semantic_sphere_8--3_57_-15.nii'];%frontal pole
ROI.ROIfiles{2}=[root,'../work/ROIs/HumphreysPNAS2015/PNAS_semantic_sphere_8--42_-24_-27.nii']; %vATL
ROI.ROIfiles{3}=[root,'../work/ROIs/HumphreysPNAS2015/PNAS_semantic_sphere_8--54_27_6.nii'];%IFGptri
ROI.ROIfiles{4}=[root,'../work/ROIs/HumphreysPNAS2015/PNAS_semantic_sphere_8--55_-43_-7.nii'];%pMTG
ROI.ROIfiles{5}=[root,'../work/ROIs/HumphreysPNAS2015/PNAS_semantic_sphere_8-45_-33_-21.nii'];%rITG

%% ANOVA Echo and Band SEMANTIC > CONTROL with con (model fit) images
% Henson script
%con images
imgs = cell(1,length(goodsubj));
S = struct();
for s=1:length(goodsubj)
 imgs{s}{1} = [root,'/GLM/first/',goodsubj{s},'/SESB/con_0003.nii']; 
 imgs{s}{2} = [root,'/GLM/first/',goodsubj{s},'/SEMB/con_0003.nii']; 
 imgs{s}{3} = [root,'/GLM/first/',goodsubj{s},'/MESB/con_0003.nii']; 
 imgs{s}{4} = [root,'/GLM/first/',goodsubj{s},'/MEMB/con_0003.nii']; 
 S.imgfiles{1}{s} = strvcat(imgs{s});
end
S.outdir = [root,'/GLM/second/con/effectofecho_band/S_gt_C'];
mkdir(S.outdir);
S.mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];

n=1;
S.contrasts{n}.c = [-1 -1 1 1]; %effect of echoes
S.contrasts{n}.name = 'ME>SE';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 1 -1 -1]; %effect of echoes
S.contrasts{n}.name = 'SE>ME';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 1 -1]; %effect of multi-band
S.contrasts{n}.name = 'SB>MB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 1 -1 1]; %effect of multi-band
S.contrasts{n}.name = 'MB>SB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 0 0 1]; %standard vs. most complex
S.contrasts{n}.name = 'MEMB>SESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 0 -1]; %standard vs. most complex
S.contrasts{n}.name = 'SESB>MEMB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 -1 1]; %interaction
S.contrasts{n}.name = 'Interaction';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [ones(1,4) ones(1,length(goodsubj))/length(goodsubj)]; % overall main effect
S.contrasts{n}.name = 'maineffect';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 0 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of SESB
S.contrasts{n}.name = 'SESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 1 0 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of SEMB
S.contrasts{n}.name = 'SEMB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 1 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of MESB
S.contrasts{n}.name = 'MESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 0 1 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of MEMB
S.contrasts{n}.name = 'MEMB';
S.contrasts{n}.type = 'T';
spm('defaults','fMRI');
batch_spm_anova(S);

%% repeat above with spmT images (model precision)
%spmT images
imgs = cell(1,length(goodsubj));
S = struct();
for s=1:length(goodsubj)
 imgs{s}{1} = [root,'/GLM/first/',goodsubj{s},'/SESB/spmT_0003.nii']; 
 imgs{s}{2} = [root,'/GLM/first/',goodsubj{s},'/SEMB/spmT_0003.nii']; 
 imgs{s}{3} = [root,'/GLM/first/',goodsubj{s},'/MESB/spmT_0003.nii']; 
 imgs{s}{4} = [root,'/GLM/first/',goodsubj{s},'/MEMB/spmT_0003.nii']; 
 S.imgfiles{1}{s} = strvcat(imgs{s});
end
S.outdir = '/imaging/projects/cbu/mr21005_memb/derivatives/GLM/second/spmT/effectofecho_band/S_gt_C';
mkdir(S.outdir);
S.mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];

n=1;
S.contrasts{n}.c = [-1 -1 1 1]; %effect of echoes
S.contrasts{n}.name = 'ME>SE';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 1 -1 -1]; %effect of echoes
S.contrasts{n}.name = 'SE>ME';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 1 -1]; %effect of multi-band
S.contrasts{n}.name = 'SB>MB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 1 -1 1]; %effect of multi-band
S.contrasts{n}.name = 'MB>SB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 0 0 1]; %standard vs. most complex
S.contrasts{n}.name = 'MEMB>SESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 0 -1]; %standard vs. most complex
S.contrasts{n}.name = 'SESB>MEMB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 -1 1]; %interaction
S.contrasts{n}.name = 'Interaction';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [ones(1,4) ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'maineffect';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 0 0 ones(1,length(goodsubj))/length(goodsubj)]; %s
S.contrasts{n}.name = 'SESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 1 0 0 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'SEMB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 1 0 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'MESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 0 1 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'MEMB';
S.contrasts{n}.type = 'T';
spm('defaults','fMRI');
batch_spm_anova(S);

%% ICA vs no-ICA main contrast
%con images
imgs = cell(1,length(goodsubj));
S = struct();
for s=1:length(goodsubj)
 imgs{s}{1} = [root,'/GLM/first/',goodsubj{s},'/MESB/con_0003.nii']; 
 imgs{s}{2} = [root,'/GLM/first/',goodsubj{s},'/MEMB/con_0003.nii']; 
 imgs{s}{3} = [root,'/GLM/first/',goodsubj{s},'/MESBdn/con_0003.nii']; 
 imgs{s}{4} = [root,'/GLM/first/',goodsubj{s},'/MEMBdn/con_0003.nii']; 
 S.imgfiles{1}{s} = strvcat(imgs{s});
end
S.outdir = [root,'/GLM/second/con/effectofdenoising/S_gt_C'];
mkdir(S.outdir);
S.mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];

n=1;
S.contrasts{n}.c = [-1 -1 1 1];
S.contrasts{n}.name = 'ICA>noICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 1 -1 -1];
S.contrasts{n}.name = 'noICA>ICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 1 -1];
S.contrasts{n}.name = 'SB>MB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 1 -1 1];
S.contrasts{n}.name = 'MB>SB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 0 1 0];
S.contrasts{n}.name = 'SBICA>SBnoICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 -1 0];
S.contrasts{n}.name = 'SBnoICA>SBICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 -1 0 1];
S.contrasts{n}.name = 'MBICA>MBnoICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 1 0 -1];
S.contrasts{n}.name = 'MBnoICA>MBICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 -1 1]; %interaction
S.contrasts{n}.name = 'Interaction';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [ones(1,4) ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'maineffect';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 0 0 ones(1,length(goodsubj))/length(goodsubj)]; %s
S.contrasts{n}.name = 'MESBnoICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 1 0 0 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'MEMBnoICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 1 0 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'MESBICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 0 1 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'MEMBICA';
S.contrasts{n}.type = 'T';
spm('defaults','fMRI');
batch_spm_anova(S);

%spmT images
imgs = cell(1,length(goodsubj));
S = struct();
for s=1:length(goodsubj)
 imgs{s}{1} = [root,'/GLM/first/',goodsubj{s},'/MESB/spmT_0003.nii']; 
 imgs{s}{2} = [root,'/GLM/first/',goodsubj{s},'/MEMB/spmT_0003.nii']; 
 imgs{s}{3} = [root,'/GLM/first/',goodsubj{s},'/MESBdn/spmT_0003.nii']; 
 imgs{s}{4} = [root,'/GLM/first/',goodsubj{s},'/MEMBdn/spmT_0003.nii']; 
 S.imgfiles{1}{s} = strvcat(imgs{s});
end
S.outdir = [root,'/GLM/second/spmT/effectofdenoising/S_gt_C'];
mkdir(S.outdir);
S.mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];

n=1;
S.contrasts{n}.c = [-1 -1 1 1];
S.contrasts{n}.name = 'ICA>noICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 1 -1 -1];
S.contrasts{n}.name = 'noICA>ICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 1 -1];
S.contrasts{n}.name = 'SB>MB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 1 -1 1];
S.contrasts{n}.name = 'MB>SB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 0 1 0];
S.contrasts{n}.name = 'SBICA>SBnoICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 -1 0];
S.contrasts{n}.name = 'SBnoICA>SBICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 -1 0 1];
S.contrasts{n}.name = 'MBICA>MBnoICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 1 0 -1];
S.contrasts{n}.name = 'MBnoICA>MBICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 -1 1]; %interaction
S.contrasts{n}.name = 'Interaction';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [ones(1,4) ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'maineffect';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 0 0 ones(1,length(goodsubj))/length(goodsubj)]; %s
S.contrasts{n}.name = 'MESBnoICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 1 0 0 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'MEMBnoICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 1 0 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'MESBICA';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 0 1 ones(1,length(goodsubj))/length(goodsubj)]; %
S.contrasts{n}.name = 'MEMBICA';
S.contrasts{n}.type = 'T';
spm('defaults','fMRI');
batch_spm_anova(S);

%% ANOVA for SESB MESB and SEMBodd MEMBodd 
% Henson script
%con images
imgs = cell(1,length(goodsubj));
S = struct();
for s=1:length(goodsubj)
 imgs{s}{1} = [root,'/GLM/first/',goodsubj{s},'/SESB/con_0003.nii']; 
 imgs{s}{2} = [root,'/GLM/first/',goodsubj{s},'/SEMBodd/con_0003.nii']; 
 imgs{s}{3} = [root,'/GLM/first/',goodsubj{s},'/MESB/con_0003.nii']; 
 imgs{s}{4} = [root,'/GLM/first/',goodsubj{s},'/MEMBodd/con_0003.nii']; 
 S.imgfiles{1}{s} = strvcat(imgs{s});
end
S.outdir = [root,'/GLM/second/con/effectofband/S_gt_C'];
mkdir(S.outdir);
S.mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];

n=1;
S.contrasts{n}.c = [-1 -1 1 1]; %effect of echoes
S.contrasts{n}.name = 'ME>SE';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 1 -1 -1]; %effect of echoes
S.contrasts{n}.name = 'SE>ME';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 1 -1]; %effect of multi-band
S.contrasts{n}.name = 'SB>MBodd';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 1 -1 1]; %effect of multi-band
S.contrasts{n}.name = 'MBodd>SB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 -1 1]; %interaction
S.contrasts{n}.name = 'Interaction';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [ones(1,4) ones(1,length(goodsubj))/length(goodsubj)]; % overall main effect
S.contrasts{n}.name = 'maineffect';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 0 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of SESB
S.contrasts{n}.name = 'SESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 1 0 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of SEMB
S.contrasts{n}.name = 'SEMBodd';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 1 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of MESB
S.contrasts{n}.name = 'MESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 0 1 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of MEMB
S.contrasts{n}.name = 'MEMBodd';
S.contrasts{n}.type = 'T';
spm('defaults','fMRI');
batch_spm_anova(S);

%spmT images
imgs = cell(1,length(goodsubj));
S = struct();
for s=1:length(goodsubj)
 imgs{s}{1} = [root,'/GLM/first/',goodsubj{s},'/SESB/spmT_0003.nii']; 
 imgs{s}{2} = [root,'/GLM/first/',goodsubj{s},'/SEMBodd/spmT_0003.nii']; 
 imgs{s}{3} = [root,'/GLM/first/',goodsubj{s},'/MESB/spmT_0003.nii']; 
 imgs{s}{4} = [root,'/GLM/first/',goodsubj{s},'/MEMBodd/spmT_0003.nii']; 
 S.imgfiles{1}{s} = strvcat(imgs{s});
end
S.outdir = [root,'/GLM/second/spmT/effectofband/S_gt_C'];
mkdir(S.outdir);
S.mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];

n=1;
S.contrasts{n}.c = [-1 -1 1 1]; %effect of echoes
S.contrasts{n}.name = 'ME>SE';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 1 -1 -1]; %effect of echoes
S.contrasts{n}.name = 'SE>ME';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 1 -1]; %effect of multi-band
S.contrasts{n}.name = 'SB>MBodd';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [-1 1 -1 1]; %effect of multi-band
S.contrasts{n}.name = 'MBodd>SB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 -1 -1 1]; %interaction
S.contrasts{n}.name = 'Interaction';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [ones(1,4) ones(1,length(goodsubj))/length(goodsubj)]; % overall main effect
S.contrasts{n}.name = 'maineffect';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [1 0 0 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of SESB
S.contrasts{n}.name = 'SESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 1 0 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of SEMB
S.contrasts{n}.name = 'SEMBodd';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 1 0 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of MESB
S.contrasts{n}.name = 'MESB';
S.contrasts{n}.type = 'T';
n=n+1;
S.contrasts{n}.c = [0 0 0 1 ones(1,length(goodsubj))/length(goodsubj)]; % main effect of MEMB
S.contrasts{n}.name = 'MEMBodd';
S.contrasts{n}.type = 'T';
spm('defaults','fMRI');
batch_spm_anova(S);

%% Load ALL data into one variable and perform ROI stats

imgs = cell(1,length(goodsubj));
con = struct();
for s=1:length(goodsubj)
 imgs{s}{1} = [root,'/GLM/first/',goodsubj{s},'/SESB/con_0003.nii']; 
 imgs{s}{2} = [root,'/GLM/first/',goodsubj{s},'/SEMB/con_0003.nii'];
 imgs{s}{3} = [root,'/GLM/first/',goodsubj{s},'/SEMBodd/con_0003.nii'];
 imgs{s}{4} = [root,'/GLM/first/',goodsubj{s},'/MESB/con_0003.nii']; 
 imgs{s}{5} = [root,'/GLM/first/',goodsubj{s},'/MEMB/con_0003.nii']; 
 imgs{s}{6} = [root,'/GLM/first/',goodsubj{s},'/MESBdn/con_0003.nii']; 
 imgs{s}{7} = [root,'/GLM/first/',goodsubj{s},'/MEMBdn/con_0003.nii']; 
 imgs{s}{8} = [root,'/GLM/first/',goodsubj{s},'/MEMBodd/con_0003.nii']; 
 imgs{s}{9} = [root,'/GLM/first/',goodsubj{s},'/MEMBodddn/con_0003.nii']; 
end

%ROI extraction
con.Datafiles = imgs;
con.mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];
con.output_raw = 1;
con.ROIfiles=ROI.ROIfiles;
con.ROI = roi_extract(con);

%remove NaN voxels from roi_extract matrix for every cell
for s=1:length(goodsubj)
    for c=1:length(imgs{1,1})
        for n=1:length(con.ROIfiles)
            x=isnan(con.ROI(n,s).rawdata(1,:));
            ind=find(x);
            con.ROI(n,s).rawdata(:,ind)=[];
            con.ROI(n,s).XYZ(:,ind)=[];
        end
    end
end

%collate values into matrix
for s=1:length(goodsubj)
    for n=1:length(con.ROIfiles)
        con_collate_median{n}(s,:)=con.ROI(n,s).median';
        con_collate_mean{n}(s,:)=con.ROI(n,s).mean';
    end
end

% %ROI plots
% roiname=[{'L FP'},{'L vATL'},{'L IFGpTri'},{'L pMTG'},{'R ITG'}];
% cond={'SESB';'SEMB';'SEMBo';'MESB';'MEMB';'MESBdn';'MEMBdn';'MEMBodn';'MEMBodn'};
% figure;
% for i=1:length(ROI.ROIfiles)
%     tmp=con_collate_median{1,i};
%     tmp=array2table(tmp,'VariableNames',cond);
%     subplot(2,3,i);violinplot(tmp);title(roiname{1,i});ylabel('con val')
% end

%anova
for i=1:length(con.ROIfiles)
 xx=table(con_collate_median{1,i}(:,1),con_collate_median{1,i}(:,2),con_collate_median{1,i}(:,4),con_collate_median{1,i}(:,5),'VariableNames',{'SESB','SEMB','MESB','MEMB'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'Echo', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMB-SESB ~ 1', 'WithinDesign', w);
 anova_con_res{i}=ranova(rm, 'withinmodel', 'Echo*Band');
end

%anova
for i=1:length(con.ROIfiles)
 xx=table(con_collate_median{1,i}(:,4),con_collate_median{1,i}(:,5),con_collate_median{1,i}(:,6),con_collate_median{1,i}(:,7),'VariableNames',{'MESB','MEMB','MESBdn','MEMBdn'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'ICA', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMBdn-MESB ~ 1', 'WithinDesign', w);
 anova_conICA_res{i}=ranova(rm, 'withinmodel', 'ICA*Band');
end

%anova
for i=1:length(con.ROIfiles)
 xx=table(con_collate_median{1,i}(:,1),con_collate_median{1,i}(:,4),con_collate_median{1,i}(:,3),con_collate_median{1,i}(:,8),'VariableNames',{'SESB','MEMB','SEMBodd','MEMBodd'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'Odd', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMBodd-SESB ~ 1', 'WithinDesign', w);
 anova_conodd_res{i}=ranova(rm, 'withinmodel', 'Odd*Band');
end

%collate anova results
for i=1:length(con.ROIfiles);
    collate_anova_con_p(:,i) =  [anova_con_res{i}.pValue(1,1),anova_con_res{i}.pValue(3,1),anova_con_res{i}.pValue(5,1),anova_con_res{i}.pValue(7,1)];
    collate_anova_conICA_p(:,i) =  [anova_conICA_res{i}.pValue(1,1),anova_conICA_res{i}.pValue(3,1),anova_conICA_res{i}.pValue(5,1),anova_conICA_res{i}.pValue(7,1)];
    collate_anova_conodd_p(:,i) =  [anova_conodd_res{i}.pValue(1,1),anova_conodd_res{i}.pValue(3,1),anova_conodd_res{i}.pValue(5,1),anova_conodd_res{i}.pValue(7,1)];
end

%posthoc comparisons - doing repeated non-parametric tests
%column labels [SESB;SEMB;SEMBodd;MESB;MEMB;MESBdn;MEMBdn;MEMBodd;MEMBodddn]
tail=[{'left'};{'right'}];
for j=1:2;
    side=tail{j};
for n=1:length(ROI.ROIfiles)
    %ME>SE
    a=[con_collate_median{1,n}(:,1),con_collate_median{1,n}(:,2)];
    b=[con_collate_median{1,n}(:,4),con_collate_median{1,n}(:,5)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_p_val{j}(1,n)=tmp2;
    %con_z_val{j}(1,n)=tmp3.zval;
    %MB>SB
    a=[con_collate_median{1,n}(:,1),con_collate_median{1,n}(:,4)];
    b=[con_collate_median{1,n}(:,2),con_collate_median{1,n}(:,5)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_p_val{j}(2,n)=tmp2;
    %con_z_val{j}(2,n)=tmp3.zval;
    %MEdn>ME
    a=[con_collate_median{1,n}(:,4),con_collate_median{1,n}(:,5)];
    b=[con_collate_median{1,n}(:,6),con_collate_median{1,n}(:,7)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_p_val{j}(3,n)=tmp2;
    %con_z_val{j}(3,n)=tmp3.zval;
    %MBodd vs SB
    a=[con_collate_median{1,n}(:,1),con_collate_median{1,n}(:,4)];
    b=[con_collate_median{1,n}(:,3),con_collate_median{1,n}(:,8)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_p_val{j}(4,n)=tmp2;
    %con_z_val{j}(4,n)=tmp3.zval;
    %MEdn vs SE
    a=[con_collate_median{1,n}(:,1),con_collate_median{1,n}(:,2)];
    b=[con_collate_median{1,n}(:,6),con_collate_median{1,n}(:,7)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_p_val{j}(5,n)=tmp2;
    %con_z_val{j}(5,n)=tmp3.zval;
    
end
end

%% spmT images
imgs = cell(1,length(goodsubj));
spmT = struct();
for s=1:length(goodsubj)
 imgs{s}{1} = [root,'/GLM/first/',goodsubj{s},'/SESB/spmT_0003.nii']; 
 imgs{s}{2} = [root,'/GLM/first/',goodsubj{s},'/SEMB/spmT_0003.nii'];
 imgs{s}{3} = [root,'/GLM/first/',goodsubj{s},'/SEMBodd/spmT_0003.nii'];
 imgs{s}{4} = [root,'/GLM/first/',goodsubj{s},'/MESB/spmT_0003.nii']; 
 imgs{s}{5} = [root,'/GLM/first/',goodsubj{s},'/MEMB/spmT_0003.nii']; 
 imgs{s}{6} = [root,'/GLM/first/',goodsubj{s},'/MESBdn/spmT_0003.nii']; 
 imgs{s}{7} = [root,'/GLM/first/',goodsubj{s},'/MEMBdn/spmT_0003.nii']; 
 imgs{s}{8} = [root,'/GLM/first/',goodsubj{s},'/MEMBodd/spmT_0003.nii']; 
 imgs{s}{9} = [root,'/GLM/first/',goodsubj{s},'/MEMBodddn/spmT_0003.nii']; 
end

%ROI extraction
spmT.Datafiles = imgs;
spmT.mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];
spmT.output_raw = 1;
spmT.ROIfiles=ROI.ROIfiles;
spmT.ROI = roi_extract(spmT);

%remove NaN voxels from roi_extract matrix for every cell
for s=1:length(goodsubj)
    for c=1:length(imgs{1,1})
        for n=1:length(spmT.ROIfiles)
            x=isnan(spmT.ROI(n,s).rawdata(1,:));
            ind=find(x);
            spmT.ROI(n,s).rawdata(:,ind)=[];
            spmT.ROI(n,s).XYZ(:,ind)=[];
        end
    end
end

for s=1:length(goodsubj)
    for n=1:length(ROI.ROIfiles)
        spmT_collate_median{n}(s,:)=spmT.ROI(n,s).median';
        spmT_collate_mean{n}(s,:)=spmT.ROI(n,s).mean';
    end
end

% %ROI plots
% roiname=[{'L FP'},{'L vATL'},{'L IFGpTri'},{'L pMTG'},{'R ITG'}];
% cond={'SESB';'SEMB';'SEMBo';'MESB';'MEMB';'MESBdn';'MEMBdn';'MESBodn';'MEMBodn'};
% figure;
% for i=1:length(ROI.ROIfiles)
%     tmp=spmT_collate_median{1,i};
%     tmp=array2table(tmp,'VariableNames',cond);
%     subplot(2,3,i);violinplot(tmp);title(roiname{1,i});ylabel('spmT val')
% end

%anova
for i=1:length(con.ROIfiles)
 xx=table(spmT_collate_median{1,i}(:,1),spmT_collate_median{1,i}(:,2),spmT_collate_median{1,i}(:,4),spmT_collate_median{1,i}(:,5),'VariableNames',{'SESB','SEMB','MESB','MEMB'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'Echo', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMB-SESB ~ 1', 'WithinDesign', w);
 anova_spmT_res{i}=ranova(rm, 'withinmodel', 'Echo*Band');
end

%anova
for i=1:length(con.ROIfiles)
 xx=table(spmT_collate_median{1,i}(:,4),spmT_collate_median{1,i}(:,5),spmT_collate_median{1,i}(:,6),spmT_collate_median{1,i}(:,7),'VariableNames',{'MESB','MEMB','MESBdn','MEMBdn'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'ICA', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMBdn-MESB ~ 1', 'WithinDesign', w);
 anova_spmTICA_res{i}=ranova(rm, 'withinmodel', 'ICA*Band');
end

%anova
for i=1:length(con.ROIfiles)
 xx=table(spmT_collate_median{1,i}(:,1),spmT_collate_median{1,i}(:,4),spmT_collate_median{1,i}(:,3),spmT_collate_median{1,i}(:,8),'VariableNames',{'SESB','MEMB','SEMBodd','MEMBodd'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'Odd', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMBodd-SESB ~ 1', 'WithinDesign', w);
 anova_spmTodd_res{i}=ranova(rm, 'withinmodel', 'Odd*Band');
end

%collate anova results
for i=1:length(con.ROIfiles);
    collate_anova_spmT_p(:,i) =  [anova_spmT_res{i}.pValue(1,1),anova_spmT_res{i}.pValue(3,1),anova_spmT_res{i}.pValue(5,1),anova_spmT_res{i}.pValue(7,1)];
    collate_anova_spmTICA_p(:,i) =  [anova_spmTICA_res{i}.pValue(1,1),anova_spmTICA_res{i}.pValue(3,1),anova_spmTICA_res{i}.pValue(5,1),anova_spmTICA_res{i}.pValue(7,1)];
    collate_anova_spmTodd_p(:,i) =  [anova_spmTodd_res{i}.pValue(1,1),anova_spmTodd_res{i}.pValue(3,1),anova_spmTodd_res{i}.pValue(5,1),anova_spmTodd_res{i}.pValue(7,1)];
end

%posthoc comparisons
%column labels [SESB;SEMB;SEMBodd;MESB;MEMB;MESBdn;MEMBdn;MEMBodd;MEMBodddn]
tail=[{'left'};{'right'}];
for j=1:2;
    side=tail{j};
for n=1:length(ROI.ROIfiles)
    %ME>SE
    a=[spmT_collate_median{1,n}(:,1),spmT_collate_median{1,n}(:,2)];
    b=[spmT_collate_median{1,n}(:,4),spmT_collate_median{1,n}(:,5)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    spmT_p_val{j}(1,n)=tmp2;
    %spmT_z_val{j}(1,n)=tmp3.zval;
    %MB>SB
    a=[spmT_collate_median{1,n}(:,1),spmT_collate_median{1,n}(:,4)];
    b=[spmT_collate_median{1,n}(:,2),spmT_collate_median{1,n}(:,5)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    spmT_p_val{j}(2,n)=tmp2;
    %spmT_z_val{j}(2,n)=tmp3.zval;
    %MEdn>ME
    a=[spmT_collate_median{1,n}(:,4),spmT_collate_median{1,n}(:,5)];
    b=[spmT_collate_median{1,n}(:,6),spmT_collate_median{1,n}(:,7)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    spmT_p_val{j}(3,n)=tmp2;
    %spmT_z_val{j}(3,n)=tmp3.zval;
    %MBodd vs SB
    a=[spmT_collate_median{1,n}(:,1),spmT_collate_median{1,n}(:,4)];
    b=[spmT_collate_median{1,n}(:,3),spmT_collate_median{1,n}(:,8)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    spmT_p_val{j}(4,n)=tmp2;
    %spmT_z_val{j}(4,n)=tmp3.zval;
    %MEdn vs SE
    a=[spmT_collate_median{1,n}(:,1),spmT_collate_median{1,n}(:,2)];
    b=[spmT_collate_median{1,n}(:,6),spmT_collate_median{1,n}(:,7)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    spmT_p_val{j}(5,n)=tmp2;
    %con_z_val{j}(5,n)=tmp3.zval;

end
end

%% MVPA analysis 
%%%%%%%%%%

condx={'SESB';'SEMB';'SEMBodd';'MESB';'MEMB';'MESBdn';'MEMBdn';'MEMBodd';'MEMBodddn'};
% Henson script
%beta images
imgs = cell(1,length(goodsubj));
con_mvpa = struct();

%cycle through conditions - each time set up seperate field structure for
%inputs and roi_extract outputs
for c=1:length(cond)
    for s=1:length(goodsubj)
     imgs{s}{1} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0001.nii'];
     imgs{s}{2} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0002.nii'];
     imgs{s}{3} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0003.nii'];
     imgs{s}{4} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0004.nii'];
     imgs{s}{5} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0005.nii'];
     imgs{s}{6} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0006.nii'];
     imgs{s}{7} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0007.nii'];
     imgs{s}{8} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0008.nii'];
     imgs{s}{9} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0009.nii'];
     imgs{s}{10} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0010.nii'];
     imgs{s}{11} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0011.nii'];
     imgs{s}{12} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0012.nii'];
     imgs{s}{13} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0013.nii'];
     imgs{s}{14} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0014.nii'];
     imgs{s}{15} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0015.nii'];
     imgs{s}{16} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0016.nii'];
     imgs{s}{17} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0017.nii'];
     imgs{s}{18} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0018.nii'];
     imgs{s}{19} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0019.nii'];
     imgs{s}{20} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0020.nii'];
     imgs{s}{21} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0021.nii'];
     imgs{s}{22} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0022.nii'];
     imgs{s}{23} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0023.nii'];
     imgs{s}{24} = [root,'/GLM/MVPA_first/',goodsubj{s},'/',cond{c},'/beta_0024.nii'];
    end
    field = strcat(cond{c});
    con_mvpa.(field).Datafiles = imgs;
    con_mvpa.(field).mask = [root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii'];
    con_mvpa.(field).output_raw = 1;
    con_mvpa.(field).ROIfiles=ROI.ROIfiles;
    con_mvpa.(field).ROI = roi_extract(con_mvpa.(field));
end

%MVPA analyses
%remove NaN voxels from roi_extract matrix for every cell
for s=1:length(goodsubj)
    for c=1:length(cond)
        for n=1:length(ROI.ROIfiles)
            field = strcat(cond{c});
            x=isnan(con_mvpa.(field).ROI(n,s).rawdata(1,:));
            ind=find(x);
            con_mvpa.(field).ROI(n,s).rawdata(:,ind)=[];
            con_mvpa.(field).ROI(n,s).XYZ(:,ind)=[];
        end
    end
end

%calculate pdist (default) between betas 
for s=1:length(goodsubj)
    for c=1:length(cond)
        for n=1:length(ROI.ROIfiles)
            field = strcat(cond{c});
            x=con_mvpa.(field).ROI(n,s).rawdata;
            
            %calculate matrix distance, convert to matrix and take upper triangle
            con_mvpa.(field).ROI(n,s).dissimilarity=triu(squareform(pdist(x,'cosine'))); %euclidean, cosine
            %convert zeros in matrix to NaN
            con_mvpa.(field).ROI(n,s).dissimilarity(con_mvpa.(field).ROI(n,s).dissimilarity==0)=nan;
            %median
            con_mvpa.(field).ROI(n,s).mvpa_within_median=nanmedian([reshape(con_mvpa.(field).ROI(n,s).dissimilarity([1:12],[1:12]),[],1);reshape(con_mvpa.(field).ROI(n,s).dissimilarity([13:24],[13:24]),[],1)]);
            con_mvpa.(field).ROI(n,s).mvpa_between_median=nanmedian(reshape(con_mvpa.(field).ROI(n,s).dissimilarity([1:12],[13:24]),[],1));
            con_mvpa.(field).ROI(n,s).mvpa_comparison_median=[con_mvpa.(field).ROI(n,s).mvpa_within_median-con_mvpa.(field).ROI(n,s).mvpa_between_median];
            %mean
            con_mvpa.(field).ROI(n,s).mvpa_within_mean=nanmean([reshape(con_mvpa.(field).ROI(n,s).dissimilarity([1:12],[1:12]),[],1);reshape(con_mvpa.(field).ROI(n,s).dissimilarity([13:24],[13:24]),[],1)]);
            con_mvpa.(field).ROI(n,s).mvpa_between_mean=nanmean(reshape(con_mvpa.(field).ROI(n,s).dissimilarity([1:12],[13:24]),[],1));
            con_mvpa.(field).ROI(n,s).mvpa_comparison_mean=[con_mvpa.(field).ROI(n,s).mvpa_within_mean-con_mvpa.(field).ROI(n,s).mvpa_between_mean];
            %meanlog
            con_mvpa.(field).ROI(n,s).mvpa_within_logmean=nanmean(log([reshape(con_mvpa.(field).ROI(n,s).dissimilarity([1:12],[1:12]),[],1);reshape(con_mvpa.(field).ROI(n,s).dissimilarity([13:24],[13:24]),[],1)]));
            con_mvpa.(field).ROI(n,s).mvpa_between_logmean=nanmean(log(reshape(con_mvpa.(field).ROI(n,s).dissimilarity([1:12],[13:24]),[],1)));
            con_mvpa.(field).ROI(n,s).mvpa_comparison_logmean=[con_mvpa.(field).ROI(n,s).mvpa_within_logmean-con_mvpa.(field).ROI(n,s).mvpa_between_logmean];
        end
    end
end

%collate mvpa within minus between results into matrix 
for s=1:length(goodsubj)
    for c=1:length(cond)
        for n=1:length(ROI.ROIfiles)
            field = strcat(cond{c});
            con_mvpa_collate_median{n}(s,c)=con_mvpa.(field).ROI(n,s).mvpa_comparison_median;
            con_mvpa_collate_mean{n}(s,c)=con_mvpa.(field).ROI(n,s).mvpa_comparison_mean;
            con_mvpa_collate_logmean{n}(s,c)=con_mvpa.(field).ROI(n,s).mvpa_comparison_logmean;
        end
    end
end

% %ROI plots
% roiname=[{'L FP'},{'L vATL'},{'L IFGpTri'},{'L pMTG'},{'R ITG'}];
% cond={'SESB';'SEMB';'SEMBo';'MESB';'MEMB';'MESBdn';'MEMBdn';'MESBodn';'MEMBodn'};
% figure;
% for i=1:length(ROI.ROIfiles)
%     tmp=con_mvpa_collate_mean{1,i};
%     tmp=array2table(tmp,'VariableNames',cond);
%     subplot(2,3,i);violinplot(tmp);title(roiname{1,i});ylabel('con mvpa')
% end

%anova
for i=1:length(ROI.ROIfiles)
 xx=table(con_mvpa_collate_median{1,i}(:,1),con_mvpa_collate_median{1,i}(:,2),con_mvpa_collate_median{1,i}(:,4),con_mvpa_collate_median{1,i}(:,5),'VariableNames',{'SESB','SEMB','MESB','MEMB'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'Echo', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMB-SESB ~ 1', 'WithinDesign', w);
 anova_mvpa_res{i}=ranova(rm, 'withinmodel', 'Echo*Band');
end

%anova
for i=1:length(con.ROIfiles)
 xx=table(con_mvpa_collate_median{1,i}(:,4),con_mvpa_collate_median{1,i}(:,5),con_mvpa_collate_median{1,i}(:,6),con_mvpa_collate_median{1,i}(:,7),'VariableNames',{'MESB','MEMB','MESBdn','MEMBdn'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'ICA', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMBdn-MESB ~ 1', 'WithinDesign', w);
 anova_mvpaICA_res{i}=ranova(rm, 'withinmodel', 'ICA*Band');
end

%anova
for i=1:length(con.ROIfiles)
 xx=table(con_mvpa_collate_median{1,i}(:,1),con_mvpa_collate_median{1,i}(:,4),con_mvpa_collate_median{1,i}(:,3),con_mvpa_collate_median{1,i}(:,8),'VariableNames',{'SESB','MEMB','SEMBodd','MEMBodd'});
 w = table(categorical([1 1 2 2].'), categorical([1 2 1 2].'), 'VariableNames', {'Odd', 'Band'}); % within-design
 rm = fitrm(xx, 'MEMBodd-SESB ~ 1', 'WithinDesign', w);
 anova_mvpaodd_res{i}=ranova(rm, 'withinmodel', 'Odd*Band');
end

%collate anova results
for i=1:length(con.ROIfiles);
    collate_anova_mvpa_p(:,i) =  [anova_mvpa_res{i}.pValue(1,1),anova_mvpa_res{i}.pValue(3,1),anova_mvpa_res{i}.pValue(5,1),anova_mvpa_res{i}.pValue(7,1)];
    collate_anova_mvpaICA_p(:,i) =  [anova_mvpaICA_res{i}.pValue(1,1),anova_mvpaICA_res{i}.pValue(3,1),anova_mvpaICA_res{i}.pValue(5,1),anova_mvpaICA_res{i}.pValue(7,1)];
    collate_anova_mvpaodd_p(:,i) =  [anova_mvpaodd_res{i}.pValue(1,1),anova_mvpaodd_res{i}.pValue(3,1),anova_mvpaodd_res{i}.pValue(5,1),anova_mvpaodd_res{i}.pValue(7,1)];
end

%posthoc comparisons
%column labels [SESB;SEMB;SEMBodd;MESB;MEMB;MESBdn;MEMBdn;MEMBodd;MEMBodddn]
tail=[{'left'};{'right'}];
for j=1:2;
    side=tail{j};
for n=1:length(ROI.ROIfiles)
    x=con_mvpa_collate_median;
    %ME>SE
    a=[x{1,n}(:,1),x{1,n}(:,2)];
    b=[x{1,n}(:,4),x{1,n}(:,5)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_mvpa_p_val{j}(1,n)=tmp2;
    %con_mvpa_z_val{j}(1,n)=tmp3.zval;
    %MB>SB
    a=[x{1,n}(:,1),x{1,n}(:,4)];
    b=[x{1,n}(:,2),x{1,n}(:,5)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_mvpa_p_val{j}(2,n)=tmp2;
    %con_mvpa_z_val{j}(2,n)=tmp3.zval;
    %MEdn>ME
    a=[x{1,n}(:,4),x{1,n}(:,5)];
    b=[x{1,n}(:,6),x{1,n}(:,7)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_mvpa_p_val{j}(3,n)=tmp2;
    %con_mvpa_z_val{j}(3,n)=tmp3.zval;
    %MBodd vs SB
    a=[x{1,n}(:,1),x{1,n}(:,4)];
    b=[x{1,n}(:,3),x{1,n}(:,8)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_mvpa_p_val{j}(4,n)=tmp2;
    %con_mvpa_z_val{j}(4,n)=tmp3.zval;
    %MEdn>SE
    a=[x{1,n}(:,1),x{1,n}(:,2)];
    b=[x{1,n}(:,6),x{1,n}(:,7)];
    [tmp1,tmp2,tmp3]=ttest(mean(a,2),mean(b,2),'tail',side);
    con_mvpa_p_val{j}(5,n)=tmp2;
    %con_z_val{j}(5,n)=tmp3.zval;

end
end

%save results in folder
save([root,'GLM/second/ROI_SgtC_results'])



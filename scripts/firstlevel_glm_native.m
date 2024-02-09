function [subcode] = firstlevel_glm_native(ids)

addpath('/group/mlr-lab/AH/Projects/spm12/');
addpath('/group/mlr-lab/AH/Projects/toolboxes/');
addpath('/imaging/projects/cbu/mr21005_memb/scripts/');

root = ['/imaging/projects/cbu/mr21005_memb/derivatives/'];
cd([root]);

subcode{1} = [ids]


%% run 1st level analysis for all subjects

cond={'SESB';'SEMB';'MESB';'MEMB'};
tr=[2;1;2;1];
nslices=[28;28;30;30];

for s=1:size(subcode,2)
    
    for c=1:size(cond,1)
    cd(root)
    outdir=([root,'/GLM/first_native/',subcode{s},'/',cond{c},'/'])
    datadir=([root,'SPM/',subcode{s}])
    mkdir(outdir);
    mkdir(datadir);
    delete([outdir,'/SPM.mat']);
    
    %if smoothed file is missing, run preprocessing - in case you want re-smooth data this will be need to be disabled/changed
    if isempty(dir([datadir,'/',subcode{s},'_task-',cond{c},'*EPI*.nii']))
        
    %load confounds file and extract 6 motion parameters, plus mean CSF and white matter signal
    %can be modified to include other/more confounds
    x=spm_load(['./fmriprep/',subcode{s},'/func/',subcode{s},'_task-',cond{c},'_run-01_desc-confounds_timeseries.tsv']);
    R=[x.rot_x,x.rot_y,x.rot_z,x.trans_x,x.trans_y,x.trans_z];
    save([datadir,'/motion',cond{c},'.mat'],'R');     
    
    %unzip func file to be used in SPM, switch behaviour for multi-echo labels
    if c<=2
        gunzip(['./fmriprep_native/',subcode{s},'/func/',subcode{s},'_task-',cond{c},'_*_bold.nii.gz'],[datadir,'/']);
    else
        gunzip(['./fmriprep_native/',subcode{s},'/func/',cond{c},'/desc-optcom_bold.nii.gz'],[datadir,'/']);
        movefile([datadir,'/desc-optcom_bold.nii'],[datadir,'/',subcode{s},'_task-',cond{c},'_rec-t2star_run-01_space-EPI_desc-preproc_bold.nii']);
    end
    
    end
    
    %select design matrix
    %note sub-001 had pseudo random design; sub-002 and sub-003 had ABAB design and all subsequent sub's had ABBA design
    if strcmp(subcode{s},'sub-001')
        des_mat=([root,'../sub-001_design_mat.mat']); %need to create with original eprime output
    elseif strcmp(subcode{s},'sub-002')
        des_mat=([root,'../ABAB.mat'])
    elseif strcmp(subcode{s},'sub-003') 
        des_mat=([root,'../ABAB.mat'])
    else
        des_mat=([root,'../ABBA.mat'])
    end

    %build GLM
    clear matlabbatch
    matlabbatch{1}.spm.stats.fmri_spec.dir = {outdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tr(c); %TR variable set above
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nslices(c); %slices variable set above
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = nslices(c)/2;
    if c >= 3
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',[datadir,'/'],['^*',cond{c},'_rec-t2star_run-01_space-EPI_desc-preproc_bold.*\.nii$'],[1:999])); %load smoothed data
    else
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',[datadir,'/'],['^*',cond{c},'_run-01_space-EPI_desc-preproc_bold.*\.nii$'],[1:999])); %load smoothed data  
    end

    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {[datadir,'/motion',cond{c},'.mat']}; %extracted from confounds file
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {des_mat}; % design matrix set above
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''}; %no brain mask
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128; %default
    
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;    
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'S';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'C';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'S>C';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'C>S';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'S+C';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [1 1];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
    spm_jobman('run',matlabbatch);
    
       
    end
    
    
end



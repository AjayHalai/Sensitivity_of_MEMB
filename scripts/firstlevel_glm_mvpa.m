function [subcode] = firstlevel_glm(ids)

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
    outdir=([root,'/GLM/MVPA_first/',subcode{s},'/',cond{c},'/'])
    datadir=([root,'SPM/',subcode{s}])
    mkdir(outdir);
    mkdir(datadir);
    delete([outdir,'/SPM.mat']);
    
    %select design matrix
    %note sub-001 had pseudo random design; sub-002 and sub-003 had ABAB design and all subsequent sub's had ABBA design
    if strcmp(subcode{s},'sub-001')
        des_mat=([root,'../sub-001_design_mat_mvpa.mat']); %need to create with original eprime output
    elseif strcmp(subcode{s},'sub-002')
        des_mat=([root,'../ABAB_mvpa.mat'])
    elseif strcmp(subcode{s},'sub-003') 
        des_mat=([root,'../ABAB_mvpa.mat'])
    else
        des_mat=([root,'../ABBA_mvpa.mat'])
    end

    %build GLM
    clear matlabbatch
    matlabbatch{1}.spm.stats.fmri_spec.dir = {outdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tr(c); %TR variable set above
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nslices(c); %slices variable set above
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = nslices(c)/2;
    if c >= 3
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',[datadir,'/'],['^*',cond{c},'_rec-t2star*.*\.nii$'],[1:999])); %load smoothed data
    else
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',[datadir,'/'],['^*',cond{c},'_run*.*\.nii$'],[1:999])); %load smoothed data  
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {[datadir,'/motion',cond{c},'.mat']}; %extracted from confounds file
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {des_mat}; % design matrix set above
    %matlabbatch{1}.spm.stats.fmri_spec.mask = {[root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii']}; %brain mask, same as template used by fMRIprep
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
    spm_jobman('run',matlabbatch);
    
    %if Multi-echo then also process the ICA-denoised datasets
    if c >= 3
        cd(root) 
        outdir=([root,'/GLM/MVPA_first/',subcode{s},'/',cond{c},'dn/'])
        datadir=([root,'SPM/',subcode{s}])
        mkdir(outdir);
        mkdir(datadir);
        delete([outdir,'/SPM.mat']);
        
        clear matlabbatch
        matlabbatch{1}.spm.stats.fmri_spec.dir = {outdir};
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tr(c);
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nslices(c);
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = nslices(c)/2;
        matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',[datadir,'/'],['^*',cond{c},'_rec-tedana*.*\.nii$'],[1:999])); %load smoothed data
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {[datadir,'/motion',cond{c},'dn.mat']}; % note motion parameters could be removed as ICA-denoising supposedly removes motion related noise
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {des_mat};
        %matlabbatch{1}.spm.stats.fmri_spec.mask = {[root,'../tpl-MNI152NLin2009cAsym_space-MNI_res-01_brainmask.nii']};
        matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;%note that high pass is effectively off as frequency anomalies removed during ICA-denoising

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
        spm_jobman('run',matlabbatch);
    end
    
    end
    
    
end



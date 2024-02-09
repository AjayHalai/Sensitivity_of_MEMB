function [subcode] = peaks_toMNI_ROIs(ids)

addpath('/group/mlr-lab/AH/Projects/spm12/');
addpath('/group/mlr-lab/AH/Projects/toolboxes/');
addpath('/imaging/projects/cbu/mr21005_memb/scripts/');
addpath('/imaging/local/software/spm_toolbox/marsbar/marsbar_v0.44/')

root = ['/imaging/projects/cbu/mr21005_memb/'];
cd([root]);

subcode{1} = [ids];

%% run 1st level analysis for all subjects

%hard coded but could read from json
cond={'SEMB';'MEMB'};
seeds{1}{1}=['A'];
seeds{1}{2}=['B'];
seeds{2}{1}=['A'];
seeds{2}{2}=['Ag'];
seeds{2}{3}=['B'];
seeds{2}{4}=['Bg'];


for cc=1:length(cond)
    
    for i=2:length(seeds{cc})
        
        tmp=spm_vol([root,'mc04/',subcode{1},'/',subcode{1},'_',cond{cc},'_MNIartefact.nii']);
        tt=spm_read_vols(tmp);
    
        [r,c,v] = ind2sub(size(tt),find(tt == i));
        mni=cor2mni([r(1),c(1),v(1)],tmp.mat);

        cen=[mni(1),mni(2),mni(3)];
        radius=8;
        o = maroi_sphere(struct('centre',cen,'radius',radius));
        mars_rois2img(o, [root,'mc04/',subcode{1},'/',subcode{1},'_',cond{cc},'_MNI_',seeds{cc}{i},'.nii'], spm_vol([root,'/work/MNI_largefov.nii.gz']));
        
    end
    delete([root,'mc04/',subcode{1},'/*labels.mat']);
end

end

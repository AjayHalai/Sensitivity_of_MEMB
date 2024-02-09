function AH_getpeak_voxel()

%add paths
addpath('/imaging/local/software/spm_cbu_svn/releases/spm12_latest/')
addpath(genpath('/imaging/projects/cbu/mr21005_memb/scripts/'));
addpath('/imaging/projects/cbu/mr21005_memb/mc04/')

dirp='/imaging/projects/cbu/mr21005_memb/mc04';

cd(dirp)

folders=dir('sub*');

cond=[{'SESB'},{'SEMB'},{'MESB'},{'MEMB'}];

for j=1:length(cond)
    save_filename = [pwd '/' cond{j} '_peak_voxels_AH'];
    
    for i=1:length(folders)
            
    tmp=spm_vol([folders(i).folder,'/',folders(i).name,'/',folders(i).name,'_task-',cond{j},'_space-EPI_peak.nii']);
    tmp_vol=spm_read_vols(tmp);
    
    [r,c,v] = ind2sub(size(tmp_vol),find(tmp_vol == max(unique(tmp_vol))));
    
    voxel(i,:) = [r,c,v];
    
    end
    
    save(save_filename,'voxel');
    clear voxel;
    
end

end
    
    

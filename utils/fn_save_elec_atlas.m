function fn_save_elec_atlas(SBJ, proc_id, view_space, reg_type, atlas_id, reref)
%% Plot a reconstruction with electrodes
% INPUTS:
%   SBJ [str] - subject ID to plot
%   proc_id [str] - name of analysis pipeline, used to pick elec file
%   view_space [str] - {'pat', 'mni'}
%   reg_type [str] - {'v', 's'} choose volume-based or surface-based registration
%   atlas_id [str] - {'DK','Dx','Yeo7','Yeo17'} are the only ones implemented so far
%   reref [0/1] - rereferenced positions (1) or original (0)

if exist('/home/knight/','dir');root_dir='/home/knight/';ft_dir=[root_dir 'hoycw/Apps/fieldtrip/'];
elseif exist('G:\','dir');root_dir='G:\';ft_dir='C:\Toolbox\fieldtrip\';
else root_dir='/Volumes/hoycw_clust/';ft_dir='/Users/colinhoy/Code/Apps/fieldtrip/';end
addpath(fullfile(root_dir,'emodynamics','scripts'));
addpath(fullfile(root_dir,'emodynamics','scripts','utils'));
addpath(ft_dir);
ft_defaults

SBJ_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_vars', [SBJ '_vars.m'])];
eval(SBJ_vars_cmd);

if strcmp(reg_type,'v') || strcmp(reg_type,'s')
    reg_suffix = ['_' reg_type];
else
    reg_suffix = '';
end
if ischar(reref); reref = str2num(reref); end
if reref
    error('WHY??? This should be run on orig positions then combined');
    % reref_suffix = '';
else
    reref_suffix = '_orig';
end

%% Load elec struct
load([SBJ_vars.dirs.recon,SBJ,'_elec_',proc_id,'_',view_space,reg_suffix,reref_suffix,'.mat']);

%% Load Atlas
atlas = fn_load_recon_atlas(SBJ,atlas_id);

%% Match elecs to atlas ROIs
elec = fn_atlas_lookup(elec,atlas,'min_qry_rng',1,'max_qry_rng',5);

%% Match elecs to atlas tissue compartments
if any(strcmp(atlas_id,{'DK','Dx'}))
    tiss = fn_atlas_lookup(elec,atlas,'min_qry_rng',5,'max_qry_rng',5);
    
    %% Convert atlas labels and probabilities to GM probability
    % usedqueryrange search sizes: 1 = 1; 3 = 7; 5 = 33
    tiss.tissue_labels = {'GM','WM','CSF','OUT'};
    tiss.tissue_prob = zeros([numel(tiss.label) numel(tiss.tissue_labels)]);
    
    % Assign atlas labels to tissue type
    tiss.tissue  = fn_atlas2roi_labels(tiss.atlas_lab,atlas_id,'tissue');
    tiss.tissue2 = cell(size(tiss.tissue));
    for e = 1:numel(tiss.label)
        % Compute Probability of Tissue Types {GM, WM, CSF, OUT}
        tiss.tissue_prob(e,strcmp(tiss.tissue{e},tiss.tissue_labels)) = ...
            tiss.tissue_prob(e,strcmp(tiss.tissue{e},tiss.tissue_labels)) + tiss.atlas_prob(e);
        
        % Check for secondary matches and add to total
        if ~isempty(tiss.atlas_lab2{e})
            tiss.tissue2{e} = fn_atlas2roi_labels(tiss.atlas_lab2{e},atlas_id,'tissue');
            for roi = 1:numel(tiss.tissue2{e})
                tiss.tissue_prob(e,strcmp(tiss.tissue2{e}{roi},tiss.tissue_labels)) = ...
                    tiss.tissue_prob(e,strcmp(tiss.tissue2{e}{roi},tiss.tissue_labels)) + tiss.atlas_prob2{e}(roi);
            end
        end
    end
    
    %% Add tissue info to atlas ROI elec struct
    elec.tissue_labels = tiss.tissue_labels;
    elec.tissue        = tiss.tissue;
    elec.tissue2       = tiss.tissue2;
    elec.tissue_prob   = tiss.tissue_prob;
end

%% Save elec strcut with atlas labels
out_fname = [SBJ_vars.dirs.recon,SBJ,'_elec_',proc_id,'_',view_space,reg_suffix,reref_suffix,'_',atlas_id,'.mat'];
fprintf('Saving %s\n',out_fname);
fprintf('==================================================================\n');
save(out_fname,'-v7.3','elec');

end
